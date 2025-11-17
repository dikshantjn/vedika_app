import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import '../viewmodel/video_meeting_view_model.dart';
import '../widgets/bottom_control_bar.dart';
import '../widgets/participant_tile.dart';
import '../widgets/meeting_timer.dart';
import '../widgets/waiting_room_banner.dart';
import '../widgets/connection_status_badge.dart';
import '../pip/pip_overlay.dart';
import '../pip/pip_platform.dart';
import 'package:vedika_healthcare/shared/services/GlobalKeys.dart';
import '../widgets/screen_share_view.dart';
import '../meeting_session.dart';
import 'package:flutter/services.dart';

class MeetingPage extends StatefulWidget {
  final String meetingId;
  final String token;
  final String displayName;
  final String role; // 'doctor' or 'patient'
  final bool enableWaitingRoom;
  final VideoMeetingViewModel? existingViewModel;
  const MeetingPage({
    super.key,
    required this.meetingId,
    required this.token,
    required this.displayName,
    required this.role,
    this.enableWaitingRoom = true,
    this.existingViewModel,
  });

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> with WidgetsBindingObserver {
  late VideoMeetingViewModel _vm;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showParticipants = false;
  bool _showChat = false;
  bool _chatSheetOpen = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PipPlatform.setMeetingScreen(true);
    PipPlatform.setActionHandlers(
      onMic: () => _vm.toggleMic(),
      onCam: () => _vm.toggleCam(),
      onEnd: () => _vm.leave(),
      onExpand: () {},
    );
    if (widget.existingViewModel != null) {
      _vm = widget.existingViewModel!;
      _vm.onRoomLeft = () {
        if (mounted) Navigator.of(context).pop();
      };
      MeetingSession.start(
        vm: _vm,
        id: widget.meetingId,
        t: widget.token,
        name: widget.displayName,
        r: widget.role,
        waiting: widget.enableWaitingRoom,
      );
      // Do NOT call startMeeting again if already joined
      if (!_vm.isJoined) {
        _vm.setWaitingRoomEnabled(widget.enableWaitingRoom && !(_vm.isDoctor));
        _vm.startMeeting(meetingId: widget.meetingId, token: widget.token);
      }
    } else {
      _vm = VideoMeetingViewModel(displayName: widget.displayName, role: widget.role)
        ..onRoomLeft = () {
          if (mounted) Navigator.of(context).pop();
        };
      _vm.setWaitingRoomEnabled(widget.enableWaitingRoom && !(_vm.isDoctor));
      _vm.startMeeting(meetingId: widget.meetingId, token: widget.token);
      MeetingSession.start(
        vm: _vm,
        id: widget.meetingId,
        t: widget.token,
        name: widget.displayName,
        r: widget.role,
        waiting: widget.enableWaitingRoom,
      );
    }
    _lastMessageCount = _vm.messages.length;
    _initMeetingNotifHandler();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }

  @override
  void dispose() {
    PipPlatform.setMeetingScreen(false);
    WidgetsBinding.instance.removeObserver(this);
    PipPlatform.setActionHandlers(onMic: null, onCam: null, onEnd: null, onExpand: null);
    MeetingSession.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // User backgrounded the app; request Android system PiP
      if (!PipPlatform.inScreenShareFlow) {
        PipPlatform.enterPiPMode();
      }
    }
  }

  static const MethodChannel _meetingNotifChannel = MethodChannel('meeting_notification');
  void _initMeetingNotifHandler() {
    _meetingNotifChannel.setMethodCallHandler((call) async {
      if (call.method == 'onOpenMeeting') {
        MeetingSession.reopenIfPossible();
      }
      return null;
    });
  }

  void _toggleSpeaker() {
    // Placeholder: Best implemented via platform audio routing if desired
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Speaker toggle is device-dependent.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PipPlatform.isInAndroidPip,
      builder: (context, inSystemPip, __) {
        // While in Android system PiP, render only PiP overlay design
        if (inSystemPip) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: SizedBox(
                width: 220,
                height: 140,
                child: PipOverlayContent(
                  viewModel: _vm,
                  onTap: () {}, // system PiP tap expands app; no-op here
                ),
              ),
            ),
          );
        }
        // Hook notifications to SnackBar (when not in PiP)
        _vm.onNotify ??= (msg) {
          final messenger = scaffoldMessengerKey.currentState;
          messenger?.showSnackBar(SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(seconds: 2),
          ));
        };
        return AnimatedBuilder(
          animation: _vm,
          builder: (context, _) {
            // New message preview when chat is closed and not in PiP
            final currentCount = _vm.messages.length;
            if (!inSystemPip && !_chatSheetOpen && currentCount > _lastMessageCount) {
              final m = _vm.messages.last;
              // Defer snackbar to next frame; calling during build is not allowed
              _lastMessageCount = currentCount;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
                  content: Text('${m.senderName}: ${m.text}', overflow: TextOverflow.ellipsis),
                  duration: const Duration(seconds: 2),
                ));
              });
            } else {
              _lastMessageCount = currentCount;
            }
            return WillPopScope(
              onWillPop: () async {
                // Show in-app PiP overlay and pop back to previous screen
                _showInAppPip();
                return true;
              },
              child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
            title: const Text('Video Consultation', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(child: MeetingTimer(elapsed: _vm.elapsed)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(child: ConnectionStatusBadge(participantCount: _vm.participants.length)),
              ),
            ],
              ),
              body: Column(
                children: [
              _vm.isDoctor
                  ? WaitingRoomBanner(visible: !_vm.admitted)
                  : const SizedBox.shrink(),
                  if (_vm.presenterId != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Screen sharing', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ScreenShareView(
                            participant: _vm.participants[_vm.presenterId],
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildGrid(),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: BottomControlBar(
                micEnabled: _vm.micEnabled,
                camEnabled: _vm.camEnabled,
                isScreenShareEnabled: _vm.isScreenShareEnabled,
                onToggleMic: _vm.toggleMic,
                onToggleCam: _vm.toggleCam,
                onToggleScreenShare: _handleToggleScreenShare,
                onLeave: _vm.leave,
                onMoreOptions: _openMoreOptions,
              ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGrid() {
    final items = _vm.participants.values.toList(growable: false);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Joining meeting...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }
    // Two participant optimized layout
    if (items.length == 1) {
      final p = items.first;
      return Padding(
        padding: const EdgeInsets.all(4),
        child: ParticipantTile(
          key: Key(p.id),
          participant: p,
        ),
      );
    }
    if (items.length == 2) {
      return OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ParticipantTile(
                      key: Key(items[0].id),
                      participant: items[0],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ParticipantTile(
                      key: Key(items[1].id),
                      participant: items[1],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ParticipantTile(
                      key: Key(items[0].id),
                      participant: items[0],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ParticipantTile(
                      key: Key(items[1].id),
                      participant: items[1],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      );
    }
    // Fallback for more participants if ever occurs
    final crossAxisCount = MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final p = items[index];
        return ParticipantTile(
          key: Key(p.id),
          participant: p,
        );
      },
    );
  }

  void _openMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                _moreItem(
                  icon: Icons.group_outlined,
                  label: 'Participants',
                  onTap: () {
                    Navigator.pop(context);
                    _showParticipantsSheet();
                  },
                ),
                _moreItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  onTap: () {
                    Navigator.pop(context);
                    _showChatSheet();
                  },
                ),
                _moreItem(
                  icon: Icons.cameraswitch,
                  label: 'Switch Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _vm.switchCamera();
                  },
                ),
                _moreItem(
                  icon: Icons.volume_up,
                  label: 'Speaker / Earpiece',
                  onTap: () {
                    Navigator.pop(context);
                    _toggleSpeaker();
                  },
                ),
                if (_vm.isDoctor)
                  _moreItem(
                    icon: Icons.how_to_reg,
                    label: 'Admit All',
                    onTap: () {
                      Navigator.pop(context);
                      _vm.admitAll();
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _moreItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showParticipantsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Participants', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _vm.participants.length,
                      itemBuilder: (context, index) {
                        final p = _vm.participants.values.elementAt(index);
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(p.displayName ?? 'Guest', style: const TextStyle(color: Colors.white)),
                          subtitle: Text(p.id, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          trailing: _vm.isDoctor
                              ? IconButton(
                                  icon: const Icon(Icons.how_to_reg, color: Colors.white),
                                  onPressed: () => _vm.admitParticipant(p.id),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChatSheet() {
    final TextEditingController controller = TextEditingController();
    _chatSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final ScrollController listController = ScrollController();
        void _scrollToBottom() {
          if (listController.hasClients) {
            listController.animateTo(
              listController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        }
        return SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _vm,
            builder: (context, __) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
              return Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 380),
                    child: ListView.separated(
                      controller: listController,
                      reverse: false,
                      itemCount: _vm.messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final m = _vm.messages[index];
                        final isMe = m.senderName == _vm.displayName;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.white10,
                                  child: const Icon(Icons.person, size: 14, color: Colors.white70),
                                ),
                              ),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isMe ? const Color(0xFF2E7D32) : const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: Radius.circular(isMe ? 12 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 12),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        m.senderName,
                                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    Text(
                                      m.text,
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        _formatTime(m.timestamp),
                                        style: const TextStyle(color: Colors.white60, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(color: Colors.white),
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Message...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) {
                              final text = controller.text.trim();
                              if (text.isNotEmpty) {
                                _vm.sendChatMessage(text);
                                controller.clear();
                                _scrollToBottom();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            _vm.sendChatMessage(text);
                            controller.clear();
                            _scrollToBottom();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      _chatSheetOpen = false;
    });
  }

  void _showInAppPip() {
    if (!mounted) return;
    final meetingId = widget.meetingId;
    final token = widget.token;
    final displayName = widget.displayName;
    final role = widget.role;
    final enableWaitingRoom = widget.enableWaitingRoom;
    PipOverlay.show(
      context: context,
      viewModel: _vm,
      onTap: () {
        PipOverlay.hide();
        final nav = navigatorKey.currentState;
        nav?.push(MaterialPageRoute(
          builder: (_) => MeetingPage(
            meetingId: meetingId,
            token: token,
            displayName: displayName,
            role: role,
            enableWaitingRoom: enableWaitingRoom,
            existingViewModel: _vm,
          ),
        ));
      },
    );
  }

  void _handleToggleScreenShare() {
    // Suppress PiP trigger during media projection transition
    PipPlatform.setScreenShareFlow(true);
    _vm.toggleScreenShare();
    Future.delayed(const Duration(milliseconds: 1800), () {
      PipPlatform.setScreenShareFlow(false);
    });
  }
}


