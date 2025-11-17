import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import '../viewmodel/video_meeting_view_model.dart';

class PipOverlay {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required VideoMeetingViewModel viewModel,
    required VoidCallback onTap,
  }) {
    hide();
    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;
    _entry = OverlayEntry(
      builder: (_) => _PipDraggable(
        child: _PipContent(viewModel: viewModel, onTap: onTap),
      ),
    );
    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _PipDraggable extends StatefulWidget {
  final Widget child;
  const _PipDraggable({required this.child});

  @override
  State<_PipDraggable> createState() => _PipDraggableState();
}

class _PipDraggableState extends State<_PipDraggable> {
  Offset _offset = const Offset(16, 16);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pipWidth = 220.0;
    final pipHeight = 140.0;
    return Positioned(
      left: size.width - pipWidth - _offset.dx,
      bottom: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final dx = (_offset.dx - details.delta.dx).clamp(0, size.width - pipWidth);
            final dy = (_offset.dy - details.delta.dy).clamp(0, size.height - pipHeight - 120);
            _offset = Offset(dx.toDouble(), dy.toDouble());
          });
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: pipWidth,
            height: pipHeight,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 6)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _PipContent extends StatefulWidget {
  final VideoMeetingViewModel viewModel;
  final VoidCallback onTap;
  const _PipContent({required this.viewModel, required this.onTap});

  @override
  State<_PipContent> createState() => _PipContentState();
}

// Public widget to reuse the same PiP design inside system PiP mode
class PipOverlayContent extends _PipContent {
  const PipOverlayContent({required super.viewModel, required super.onTap});
}

class _PipContentState extends State<_PipContent> {
  Participant? _participant;
  Stream? _videoStream;
  Stream? _shareStream;

  @override
  void initState() {
    super.initState();
    // Prefer local participant
    final participants = widget.viewModel.participants;
    if (participants.isNotEmpty) {
      _participant = participants.values.firstWhere(
        (p) => p.id == _getLocalId(),
        orElse: () => participants.values.first,
      );
      _setupStream();
    }
  }

  String? _getLocalId() {
    try {
      // local participant is often the first joined in our model
      return widget.viewModel.participants.values.first.id;
    } catch (_) {
      return null;
    }
  }

  void _setupStream() {
    if (_participant == null) return;
    _participant!.streams.forEach((_, Stream stream) {
      if (stream.kind == 'video') {
        _videoStream = stream;
      } else if (stream.kind == 'share') {
        _shareStream = stream;
      }
    });
    _participant!.on(Events.streamEnabled, (Stream stream) {
      if (!mounted) return;
      if (stream.kind == 'video') setState(() => _videoStream = stream);
      if (stream.kind == 'share') setState(() => _shareStream = stream);
    });
    _participant!.on(Events.streamDisabled, (Stream stream) {
      if (!mounted) return;
      if (stream.kind == 'video') setState(() => _videoStream = null);
      if (stream.kind == 'share') setState(() => _shareStream = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onTap,
            child: (_shareStream ?? _videoStream) != null
                ? RTCVideoView(
                    (_shareStream ?? _videoStream)!.renderer as RTCVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.videocam_off, color: Colors.white54, size: 28),
                    ),
                  ),
          ),
        ),
        // Header
        Positioned(
          right: 6,
          top: 6,
          child: Row(
            children: [
              _chip(_shareStream != null ? 'Sharing' : 'PiP'),
              const SizedBox(width: 6),
              if (widget.viewModel.isScreenShareEnabled)
                _iconBtn(
                  icon: Icons.stop_screen_share,
                  tooltip: 'Stop Share',
                  onTap: () {
                    widget.viewModel.toggleScreenShare();
                  },
                ),
              const SizedBox(width: 6),
              _iconBtn(
                icon: Icons.close,
                tooltip: 'Close & End',
                onTap: () {
                  PipOverlay.hide();
                  vm.leave();
                },
              ),
            ],
          ),
        ),
        // Controls
        Positioned(
          left: 6,
          right: 6,
          bottom: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatefulBuilder(
                    builder: (context, setSt) {
                      return Row(
                        children: [
                          _iconBtn(
                            icon: vm.micEnabled ? Icons.mic : Icons.mic_off,
                            activeColor: vm.micEnabled ? Colors.white : Colors.redAccent,
                            tooltip: vm.micEnabled ? 'Mute' : 'Unmute',
                            onTap: () {
                              vm.toggleMic();
                              setSt(() {});
                            },
                          ),
                          const SizedBox(width: 6),
                          _iconBtn(
                            icon: vm.camEnabled ? Icons.videocam : Icons.videocam_off,
                            activeColor: vm.camEnabled ? Colors.white : Colors.redAccent,
                            tooltip: vm.camEnabled ? 'Camera Off' : 'Camera On',
                            onTap: () {
                              vm.toggleCam();
                              setSt(() {});
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  _iconBtn(
                    icon: Icons.open_in_full,
                    tooltip: 'Expand',
                    onTap: widget.onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _iconBtn({required IconData icon, Color activeColor = Colors.white, required String tooltip, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 18, color: activeColor),
      ),
    );
  }
}


