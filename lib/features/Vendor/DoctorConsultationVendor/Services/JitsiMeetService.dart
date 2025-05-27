import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiMeetService {
  static const String SERVER_URL = 'https://meet.jit.si';
  final JitsiMeet jitsiMeet = JitsiMeet();

  Future<void> joinMeeting({
    required String roomName,
    required String userDisplayName,
    String? userEmail,
    String? avatarUrl,
    String? jwtToken,
    bool isAudioMuted = false,
    bool isVideoMuted = false,
  }) async {
    try {
      debugPrint("\n🔍 JITSI MEET SERVICE DEBUG");
      debugPrint("1. Input Parameters:");
      debugPrint("   - Room Name: $roomName");
      debugPrint("   - Display Name: $userDisplayName");
      debugPrint("   - Email: $userEmail");
      debugPrint("   - JWT Token: ${jwtToken != null ? 'Present (${jwtToken.substring(0, min(20, jwtToken.length))}...)' : 'Not Present'}");
      debugPrint("   - Server URL: $SERVER_URL");

      // Define user info
      var userInfo = JitsiMeetUserInfo(
        displayName: userDisplayName,
        email: userEmail,
        avatar: avatarUrl,
      );

      debugPrint("\n2. User Info Created:");
      debugPrint("   - Display Name: ${userInfo.displayName}");
      debugPrint("   - Email: ${userInfo.email}");
      debugPrint("   - Avatar: ${userInfo.avatar}");

      // Define meeting options
      var options = JitsiMeetConferenceOptions(
        serverURL: SERVER_URL,
        room: roomName,
        token: jwtToken,
        userInfo: userInfo,
        configOverrides: {
          "serverURL": SERVER_URL,
          "startWithAudioMuted": isAudioMuted,
          "startWithVideoMuted": isVideoMuted,
          "subject": "Vedika Health Consultation",
          "prejoinPageEnabled": false,
          "disableDeepLinking": true,
          "enableLobby": false,
          "requireDisplayName": false,
          "enableInsecureRoomNameWarning": false,
          "p2p.enabled": true,
        },
        featureFlags: {
          "welcomepage.enabled": false,
          "invite.enabled": false,
          "calendar.enabled": false,
          "call-integration.enabled": false,
          "security-options.enabled": false,
          "lobby-mode.enabled": false,
          "unsaferoomwarning.enabled": false,
          "ios.recording.enabled": false,
          "recording.enabled": false,
          "live-streaming.enabled": false,
          "meeting-name.enabled": true,
        },
      );

      debugPrint("\n3. Conference Options Created:");
      debugPrint("   - Server URL: ${options.serverURL}");
      debugPrint("   - Room: ${options.room}");
      debugPrint("   - Token: ${options.token != null ? 'Present' : 'Not Present'}");
      debugPrint("   - Config Overrides: ${options.configOverrides}");
      debugPrint("   - Feature Flags: ${options.featureFlags}");

      debugPrint("\n4. Attempting to join meeting...");
      await jitsiMeet.join(options);
      debugPrint("✅ Meeting joined successfully!");

    } catch (e, stackTrace) {
      debugPrint("\n❌ ERROR JOINING MEETING");
      debugPrint("Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      rethrow;
    }
  }
}
