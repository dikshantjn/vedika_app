import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiMeetScreen extends StatefulWidget {
  final String roomName;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final String? jwtToken;

  const JitsiMeetScreen({
    Key? key,
    required this.roomName,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.jwtToken,
  }) : super(key: key);

  @override
  State<JitsiMeetScreen> createState() => _JitsiMeetScreenState();
}

class _JitsiMeetScreenState extends State<JitsiMeetScreen> {
  final _jitsiMeet = JitsiMeet();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  @override
  void dispose() {
    _jitsiMeet.hangUp();
    super.dispose();
  }

  Future<void> _joinMeeting() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      var options = JitsiMeetConferenceOptions(
        serverURL: "https://meet.vedika.health",
        room: widget.roomName,
        token: widget.jwtToken,
        userInfo: JitsiMeetUserInfo(
          displayName: widget.displayName,
          email: widget.email,
          avatar: widget.avatarUrl,
        ),
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
          "subject": "Vedika Health Consultation",
        },
        featureFlags: {
          "welcomepage.enabled": false,
          "invite.enabled": false,
          "calendar.enabled": false,
          "call-integration.enabled": false,
        },
      );

      await _jitsiMeet.join(
        options,
        JitsiMeetEventListener(
          conferenceJoined: (url) {
            debugPrint("Conference joined: url: $url");
            setState(() {
              _isLoading = false;
            });
          },
          conferenceTerminated: (url, error) {
            debugPrint("Conference terminated: url: $url, error: $error");
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          conferenceWillJoin: (url) {
            debugPrint("Conference will join: url: $url");
          },
          participantJoined: (email, name, role, participantId) {
            debugPrint("Participant joined: email: $email, name: $name, role: $role, participantId: $participantId");
          },
          participantLeft: (participantId) {
            debugPrint("Participant left: participantId: $participantId");
          },
          audioMutedChanged: (muted) {
            debugPrint("Audio muted changed: muted: $muted");
          },
          videoMutedChanged: (muted) {
            debugPrint("Video muted changed: muted: $muted");
          },
          readyToClose: () {
            debugPrint("Ready to close");
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      );

    } catch (e) {
      debugPrint("Error joining meeting: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Joining video consultation...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Failed to join meeting',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _joinMeeting,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
    );
  }
}
