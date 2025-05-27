import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';

class JitsiMeetService {
  static final JitsiMeetService _instance = JitsiMeetService._internal();
  final _jitsiMeet = JitsiMeet();

  factory JitsiMeetService() {
    return _instance;
  }

  JitsiMeetService._internal();

  Future<void> joinMeeting({
    required String roomName,
    required String displayName,
    String? email,
    String? avatarUrl,
    String? jwtToken,
    String serverUrl = 'https://meet.vedika.health',
    required bool isDoctor,
  }) async {
    try {
      var options = JitsiMeetConferenceOptions(
        serverURL: serverUrl,
        room: roomName,
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
          "subject": "Vedika Consultation",
          if (jwtToken != null && jwtToken.isNotEmpty)
            "jwt": jwtToken,
          "prejoinPageEnabled": false,
          "disableDeepLinking": true,
          "disablePolls": true,
          "disableReactions": true,
          "disableSelfView": false,
          "enableClosePage": true,
          "enableWelcomePage": true,
          "enableLobby": true,
          "enableNoAudioDetection": true,
          "enableNoisyMicDetection": true,
          "enablePrejoinPage": false,
          "enableP2P": true,
          "p2p": {
            "enabled": true,
            "preferH264": true,
            "disableH264": false,
            "useStunTurn": true,
          },
          "startWithVideoMuted": !isDoctor,
          "startWithAudioMuted": !isDoctor,
          "filmstrip": {
            "enabled": true,
          },
          "toolbarButtons": isDoctor ? [
            "microphone",
            "camera",
            "closedcaptions",
            "desktop",
            "fullscreen",
            "fodeviceselection",
            "hangup",
            "profile",
            "chat",
            "recording",
            "livestreaming",
            "etherpad",
            "sharedvideo",
            "settings",
            "raisehand",
            "videoquality",
            "filmstrip",
            "feedback",
            "stats",
            "shortcuts",
            "tileview",
            "select-background",
            "download",
            "help",
            "mute-everyone",
            "security"
          ] : [
            "microphone",
            "camera",
            "closedcaptions",
            "desktop",
            "fullscreen",
            "fodeviceselection",
            "hangup",
            "profile",
            "chat",
            "raisehand",
            "videoquality",
            "filmstrip",
            "feedback",
            "stats",
            "shortcuts",
            "tileview",
            "select-background",
            "download",
            "help"
          ],
        },
        featureFlags: {
          "ios-recording-enabled": false,
          "recording-enabled": false,
          "live-streaming-enabled": false,
          "tile-view-enabled": true,
          "call-integration-enabled": false,
          "conference-timer-enabled": true,
          "welcome-page-enabled": true,
          "raise-hand-enabled": true,
          "close-page-enabled": isDoctor,
          "invite-enabled": isDoctor,
          "tile-view-enabled": true,
          "toolbox-enabled": true,
          "settings-enabled": isDoctor,
          "pip-enabled": true,
          "fullscreen-enabled": true,
          "overflow-menu-enabled": true,
          "chat-enabled": true,
          "raise-hand-enabled": true,
          "recording-enabled": false,
          "live-streaming-enabled": false,
          "call-integration-enabled": false,
          "conference-timer-enabled": true,
          "welcome-page-enabled": true,
          "moderator-enabled": isDoctor,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: displayName,
          email: email,
          avatar: avatarUrl,
        ),
      );

      await _jitsiMeet.join(options);
    } catch (error) {
      debugPrint("Error joining meeting: $error");
      rethrow;
    }
  }

  void hangUp() {
    _jitsiMeet.hangUp();
  }
}

class JitsiMeetScreen extends StatefulWidget {
  final String roomName;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final String? jwtToken;
  final String serverUrl;
  final bool isDoctor;

  const JitsiMeetScreen({
    Key? key,
    required this.roomName,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.jwtToken,
    this.serverUrl = 'https://meet.vedika.health',
    this.isDoctor = false,
  }) : super(key: key);

  @override
  State<JitsiMeetScreen> createState() => _JitsiMeetScreenState();
}

class _JitsiMeetScreenState extends State<JitsiMeetScreen> {
  final _jitsiMeetService = JitsiMeetService();
  bool _isLoading = true;
  bool _isMeetingEnded = false;

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  void _joinMeeting() async {
    try {
      await _jitsiMeetService.joinMeeting(
        roomName: widget.roomName,
        displayName: widget.displayName,
        email: widget.email,
        avatarUrl: widget.avatarUrl,
        jwtToken: widget.jwtToken,
        serverUrl: widget.serverUrl,
        isDoctor: widget.isDoctor,
      );
      setState(() => _isLoading = false);
    } catch (error) {
      debugPrint("Error joining meeting: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining meeting: $error'),
            backgroundColor: DoctorConsultationColorPalette.errorRed,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _handleMeetingEnd() {
    if (!_isMeetingEnded && mounted) {
      setState(() => _isMeetingEnded = true);
      _jitsiMeetService.hangUp();
      Navigator.pop(context); // This will return to the previous screen
    }
  }

  @override
  void dispose() {
    if (!_isMeetingEnded) {
      _jitsiMeetService.hangUp();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleMeetingEnd();
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: DoctorConsultationColorPalette.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Joining meeting...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
} 