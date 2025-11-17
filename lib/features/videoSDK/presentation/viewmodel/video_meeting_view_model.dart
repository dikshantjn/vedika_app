import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:videosdk/videosdk.dart';

class ChatMessage {
  final String senderName;
  final String text;
  final DateTime timestamp;
  const ChatMessage({required this.senderName, required this.text, required this.timestamp});
}

class VideoMeetingViewModel extends ChangeNotifier {
  VideoMeetingViewModel({
    required String displayName,
    required String role, // 'doctor' or 'patient'
  })  : _displayName = displayName,
        _role = role {
    // Generate a lightweight client id
    _clientId = 'c${DateTime.now().microsecondsSinceEpoch}${hashCode}';
  }

  // Room and participants
  Room? _room;
  final Map<String, Participant> _participants = <String, Participant>{};
  Map<String, Participant> get participants => Map.unmodifiable(_participants);
  bool _joined = false;
  bool get isJoined => _joined;

  // Notification callback for UI (Snackbars/Toasts)
  void Function(String message)? onNotify;

  // Local states
  bool _micEnabled = true;
  bool _camEnabled = true;
  bool _isFrontCamera = true;
  bool _isScreenShareEnabled = false;
  bool _admitted = true; // default true; can be controlled by waiting room logic
  bool get micEnabled => _micEnabled;
  bool get camEnabled => _camEnabled;
  bool get isFrontCamera => _isFrontCamera;
  bool get isScreenShareEnabled => _isScreenShareEnabled;
  bool get admitted => _admitted;
  String? _presenterId;
  String? get presenterId => _presenterId;

  // Role
  final String _role;
  bool get isDoctor => _role.toLowerCase() == 'doctor';

  // Display name
  final String _displayName;
  String get displayName => _displayName;

  // Meeting timer
  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;
  Timer? _timer;

  // Chat
  final List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool _chatSubscribed = false;
  late final String _clientId;
  final Set<String> _seenMessageIds = <String>{};

  // Callbacks
  VoidCallback? onRoomLeft;
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = _elapsed + const Duration(seconds: 1);
      notifyListeners();
    });
  }

  Future<void> startMeeting({
    required String meetingId,
    required String token,
  }) async {
    // Create room
    final room = VideoSDK.createRoom(
      roomId: meetingId,
      token: token,
      displayName: _displayName,
      micEnabled: _micEnabled,
      camEnabled: _camEnabled,
      defaultCameraIndex: kIsWeb ? 0 : 1,
    );
    _bindRoom(room);
    room.join();
  }

  void _bindRoom(Room room) {
    _room = room;
    // Events
    // Room state changes
    try {
      room.on(Events.roomStateChanged, (dynamic state) {
        onNotify?.call(_describeRoomState(state));
      });
    } catch (_) {}

    room.on(Events.roomJoined, () {
      _participants.putIfAbsent(room.localParticipant.id, () => room.localParticipant);
      _attachParticipantEvents(room.localParticipant);
      _joined = true;
      _startTimer();
      notifyListeners();
      // Show ongoing meeting notification
      try {
        MethodChannel('meeting_notification').invokeMethod('showOngoing', {
          'title': 'Meeting in progress',
          'text': 'Tap to return to the meeting',
        });
      } catch (_) {}
      _subscribeChatIfNeeded();
    });

    room.on(Events.participantJoined, (Participant participant) {
      _participants.putIfAbsent(participant.id, () => participant);
      _attachParticipantEvents(participant);
      onNotify?.call('${participant.displayName ?? 'Participant'} joined');
      notifyListeners();
    });

    // Newer SDKs include reason map; keep dynamic args to be safe
    room.on(Events.participantLeft, (dynamic participantId, [dynamic _]) {
      final id = participantId is String ? participantId : participantId?.toString();
      if (id != null && _participants.containsKey(id)) {
        final name = _participants[id]?.displayName ?? 'Participant';
        _participants.remove(id);
        onNotify?.call('$name left');
        notifyListeners();
      }
    });

    // Camera/Mic request events
    try {
      room.on(Events.cameraRequested, (dynamic data) {
        onNotify?.call('Host requested to turn ON camera');
      });
    } catch (_) {}
    try {
      room.on(Events.micRequested, (dynamic data) {
        onNotify?.call('Host requested to unmute mic');
      });
    } catch (_) {}

    room.on(Events.roomLeft, () {
      _participants.clear();
      _timer?.cancel();
      _joined = false;
      try {
        MethodChannel('meeting_notification').invokeMethod('cancelOngoing');
      } catch (_) {}
      _presenterId = null;
      onRoomLeft?.call();
      notifyListeners();
    });

    // Lightweight in-call notifications via pubsub
    try {
      // Waiting room - doctor admits
      room.pubSub.subscribe('ADMIT', (PubSubMessage pubSubMessage) {
        final payload = pubSubMessage.message;
        if (payload == 'ALL' || payload == room.localParticipant.id) {
          _admitted = true;
          notifyListeners();
        }
      });
    } catch (_) {
      // PubSub may not be available on some platforms or SDK versions
    }
  }

  void _subscribeChatIfNeeded() {
    if (_room == null || _chatSubscribed) return;
    try {
      _chatSubscribed = true;
      _room!.pubSub.subscribe('CHAT', _onChatMessage).then((PubSubMessages? store) {
        if (store != null) {
          for (final PubSubMessage m in store.messages) {
            _appendChatFromPubSubMessage(m);
          }
          notifyListeners();
        }
      });
    } catch (_) {}
  }

  void _onChatMessage(PubSubMessage pubSubMessage) {
    _appendChatFromPubSubMessage(pubSubMessage);
    notifyListeners();
  }

  void _appendChatFromPubSubMessage(PubSubMessage pubSubMessage) {
    final raw = pubSubMessage.message;
    String sender = pubSubMessage.senderName ?? 'Participant';
    String text = '';
    String? id;
    String? fromClient;
    if (raw is String) {
      try {
        final decoded = json.decode(raw);
        if (decoded is Map) {
          final s = decoded['sender'];
          final t = decoded['text'];
          final i = decoded['id'];
          final c = decoded['clientId'];
          if (s is String && s.isNotEmpty) sender = s;
          if (t is String) text = t;
          if (i is String && i.isNotEmpty) id = i;
          if (c is String && c.isNotEmpty) fromClient = c;
        } else {
          text = raw;
        }
      } catch (_) {
        text = raw;
      }
    } else {
      text = raw.toString();
    }
    // De-duplicate echo/self messages using id
    if (id != null) {
      if (_seenMessageIds.contains(id)) return;
      _seenMessageIds.add(id!);
    } else if (fromClient == _clientId && sender == _displayName) {
      // If no id present, avoid double add for our own echoed message
      return;
    }
    if (text.isNotEmpty) {
      _messages.add(ChatMessage(senderName: sender, text: text, timestamp: DateTime.now()));
    }
  }

  String _describeRoomState(dynamic state) {
    final raw = state?.toString().toLowerCase() ?? '';
    if (raw.contains('connecting')) return 'Connecting to the call...';
    if (raw.contains('connected')) return 'You’re now in the call';
    if (raw.contains('reconnecting')) return 'Connection lost. Reconnecting...';
    if (raw.contains('disconnected')) return 'Call ended';
    return 'Status updated';
  }

  void _attachParticipantEvents(Participant participant) {
    try {
      participant.on(Events.streamEnabled, (Stream stream) {
        final who = participant.displayName ?? 'Participant';
        onNotify?.call('${stream.kind} enabled by $who');
        if (stream.kind == 'share') {
          if (_room != null && participant.id == _room!.localParticipant.id) {
            _isScreenShareEnabled = true;
          }
          _presenterId = participant.id;
          notifyListeners();
        }
      });
      participant.on(Events.streamDisabled, (Stream stream) {
        final who = participant.displayName ?? 'Participant';
        onNotify?.call('${stream.kind} disabled by $who');
        if (stream.kind == 'share') {
          if (_room != null && participant.id == _room!.localParticipant.id) {
            _isScreenShareEnabled = false;
          }
          // If presenter stopped, clear presenterId
          if (_presenterId == participant.id) {
            _presenterId = null;
          }
          notifyListeners();
        }
      });
      // Room-level presenter change event
      _room?.on(Events.presenterChanged, (String? presenterId) {
        _presenterId = presenterId;
        notifyListeners();
      });
    } catch (_) {}
  }

  Future<void> leave() async {
    _timer?.cancel();
    try {
      _room?.pubSub.unsubscribe('CHAT', _onChatMessage);
    } catch (_) {}
    _chatSubscribed = false;
    try {
      await _room?.leave();
    } catch (_) {
      // ignore
    } finally {
      _room = null;
    }
  }

  void toggleMic() {
    if (_room == null) return;
    if (_micEnabled) {
      _room!.muteMic();
    } else {
      _room!.unmuteMic();
    }
    _micEnabled = !_micEnabled;
    notifyListeners();
  }

  void toggleCam() {
    if (_room == null) return;
    if (_camEnabled) {
      _room!.disableCam();
    } else {
      _room!.enableCam();
    }
    _camEnabled = !_camEnabled;
    notifyListeners();
  }

  void switchCamera() {
    if (_room == null) return;
    // The current VideoSDK Room may not expose a switchCamera API across platforms.
    // Keep UI state toggle only; device switching can be implemented via platform channels if needed.
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }

  void toggleScreenShare() {
    if (_room == null) return;
    try {
      if (_isScreenShareEnabled) {
        _room!.disableScreenShare();
      } else {
        if (!kIsWeb && Platform.isAndroid) {
          _room!.enableScreenShare(enableAudio: true);
        } else {
          _room!.enableScreenShare();
        }
      }
      _isScreenShareEnabled = !_isScreenShareEnabled;
      notifyListeners();
    } catch (_) {
      // Screenshare support may vary
    }
  }

  // Doctor admits a participant or everyone
  void admitParticipant(String participantId) {
    if (!isDoctor || _room == null) return;
    try {
      _room!.pubSub.publish('ADMIT', participantId);
    } catch (_) {}
  }

  void admitAll() {
    if (!isDoctor || _room == null) return;
    try {
      _room!.pubSub.publish('ADMIT', 'ALL');
    } catch (_) {}
  }

  // Patient can be in waiting room until admitted
  void setWaitingRoomEnabled(bool enabled) {
    _admitted = !enabled || isDoctor; // Doctors are always admitted
    notifyListeners();
  }

  void sendChatMessage(String text) {
    if (text.trim().isEmpty || _room == null) return;
    try {
      final id = 'm${DateTime.now().microsecondsSinceEpoch}${_messages.length}';
      // Mark seen to prevent echo duplication
      _seenMessageIds.add(id);
      final payload = json.encode({'id': id, 'clientId': _clientId, 'sender': _displayName, 'text': text.trim()});
      _room!.pubSub.publish(
        'CHAT',
        payload,
        const PubSubPublishOptions(persist: true),
      );
      // Also add locally for immediate feedback
      _messages.add(ChatMessage(
        senderName: _displayName,
        text: text.trim(),
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    } catch (_) {
      // Fallback to local append
      _messages.add(ChatMessage(
        senderName: _displayName,
        text: text.trim(),
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }
}


