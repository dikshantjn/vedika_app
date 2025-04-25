import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'dart:math';
import 'dart:convert';

class JitsiMeetService {
  final jitsiMeet = JitsiMeet();
  
  // Constants for JaaS configuration
  static const String JAAS_SERVER_URL = "https://vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db.8x8.vc";
  static const String JAAS_TENANT = "vedika";

  // Utility method to extract room name from JWT
  String? extractRoomNameFromJwt(String jwtToken) {
    try {
      final parts = jwtToken.split('.');
      if (parts.length == 3) {
        final payloadJson = String.fromCharCodes(
          base64Url.decode(base64Url.normalize(parts[1]))
        );
        final payload = json.decode(payloadJson);
        if (payload.containsKey("room")) {
          final roomName = payload["room"];
          debugPrint("Extracted room name from JWT: $roomName");
          return roomName;
        }
      }
    } catch (e) {
      debugPrint("Error extracting room name from JWT: $e");
    }
    return null;
  }

  // Main method to join a meeting
  Future<void> joinMeeting({
    required String roomName,
    required String userDisplayName,
    String? userEmail,
    String? userAvatarUrl,
    String? jwtToken,
    VoidCallback? onConferenceTerminated,
    ValueChanged<String?>? onError,
  }) async {
    try {
      debugPrint("\n====== JOINING JITSI MEETING ======");
      
      // Clean and validate JWT token
      if (jwtToken != null) {
        jwtToken = jwtToken.trim();
        if (jwtToken.contains('#')) {
          jwtToken = jwtToken.split('#')[0];
        }
        if (jwtToken.contains('&')) {
          jwtToken = jwtToken.split('&')[0];
        }
        
        debugPrint("JWT Token length: ${jwtToken.length}");
        debugPrint("JWT Token prefix: ${jwtToken.substring(0, min(20, jwtToken.length))}...");
      }

      // Extract room name from JWT if available
      String finalRoomName = roomName;
      if (jwtToken != null && jwtToken.startsWith("ey")) {
        final jwtRoomName = extractRoomNameFromJwt(jwtToken);
        if (jwtRoomName != null) {
          debugPrint("Using room name from JWT: $jwtRoomName");
          finalRoomName = jwtRoomName;
        }
      }

      debugPrint("Final room name: $finalRoomName");
      debugPrint("Server URL: $JAAS_SERVER_URL");
      
      // Create conference options
      final options = JitsiMeetConferenceOptions(
        serverURL: JAAS_SERVER_URL,
        room: finalRoomName,
        token: jwtToken,
        userInfo: JitsiMeetUserInfo(
          displayName: userDisplayName,
          email: userEmail,
          avatar: userAvatarUrl,
        ),
        configOverrides: {
          // JaaS specific settings
          "disableDeepLinking": true,
          "enableLobby": false,
          "prejoinPageEnabled": false,
          "requireDisplayName": false,
          "enableInsecureRoomNameWarning": false,
          "p2p.enabled": true,
          
          // Disable unnecessary features
          "analytics.disabled": true,
          "disableThirdPartyRequests": true,
          "disableLocalVideoFlip": true,
          "startWithVideoMuted": false,
          "startWithAudioMuted": false,
          
          // JaaS specific settings
          "disableJWT": false,
          "enableInsecureRoomNameWarning": false,
          "enableLobby": false,
          "prejoinPageEnabled": false,
          "requireDisplayName": false,
          "p2p.enabled": true,
          "analytics.disabled": true,
          "disableThirdPartyRequests": true,
          "disableLocalVideoFlip": true,
          "startWithVideoMuted": false,
          "startWithAudioMuted": false,
          "tokenAuthUrl": jwtToken != null ? JAAS_SERVER_URL : null,
        },
        featureFlags: {
          // Disable unnecessary features
          "invite.enabled": false,
          "security-options.enabled": false,
          "lobby-mode.enabled": false,
          "unsaferoomwarning.enabled": false,
          "ios.recording.enabled": false,
          "recording.enabled": false,
          "live-streaming.enabled": false,
          "meeting-name.enabled": true,
          "call-integration.enabled": false,
        },
      );

      // Join the meeting
      await jitsiMeet.join(options, JitsiMeetEventListener(
        conferenceTerminated: (url, error) {
          debugPrint("Conference ended: $url, error: $error");
          onConferenceTerminated?.call();
        },
        conferenceJoined: (url) => debugPrint("Joined conference: $url"),
        participantJoined: (email, name, role, id) =>
            debugPrint("Participant joined: $name, role: $role"),
        participantLeft: (id) => debugPrint("Participant left"),
        readyToClose: () => debugPrint("Meeting ready to close"),
      ));

    } catch (e) {
      debugPrint("Join error: $e");
      onError?.call(e.toString());
    }
  }

  // Method to join directly from a meeting URL
  Future<void> joinFromUrl({
    required String meetingUrl,
    required String userDisplayName,
    String? userEmail,
    String? userAvatarUrl,
    VoidCallback? onConferenceTerminated,
    ValueChanged<String?>? onError,
  }) async {
    try {
      debugPrint("\n====== JOINING FROM URL ======");
      debugPrint("Meeting URL: $meetingUrl");

      // Extract room name and JWT from URL
      String? roomName;
      String? jwtToken;

      // Handle URL with fragment (#jwt=)
      if (meetingUrl.contains('#jwt=')) {
        final parts = meetingUrl.split('#jwt=');
        final urlPart = parts[0];
        jwtToken = parts[1];

        // Extract room name from URL
        if (urlPart.contains('/')) {
          roomName = urlPart.split('/').last;
        }
      }

      if (roomName == null) {
        throw Exception("Could not extract room name from URL");
      }

      // Join using the extracted information
      await joinMeeting(
        roomName: roomName,
        userDisplayName: userDisplayName,
        userEmail: userEmail,
        userAvatarUrl: userAvatarUrl,
        jwtToken: jwtToken,
        onConferenceTerminated: onConferenceTerminated,
        onError: onError,
      );

    } catch (e) {
      debugPrint("URL join error: $e");
      onError?.call(e.toString());
    }
  }

  // Method to hang up the current meeting
  Future<void> hangUp() async {
    try {
      await jitsiMeet.hangUp();
    } catch (e) {
      debugPrint("Hangup error: $e");
    }
  }

  String _sanitizeRoomName(String roomName) {
    // Jitsi can be sensitive to room names - sanitize to alphanumeric and hyphens only
    String sanitized = roomName.trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .toLowerCase();
    
    debugPrint("Original room name: $roomName");
    debugPrint("Sanitized room name: $sanitized");
    
    return sanitized;
  }
  
  String _ensureTenantPrefix(String roomName) {
    // For 8x8.vc, room names should be prefixed with tenant ID
    // Example: if tenant is "vedika", room should be "vedika/roomName"
    const String tenant = "vedika"; // Replace with your actual tenant ID
    
    // Check if room already has tenant prefix
    if (roomName.startsWith("$tenant/")) {
      return roomName;
    }
    
    // Add tenant prefix
    return "$tenant/$roomName";
  }

  // New method for joining without JWT
  Future<void> joinWithoutToken({
    required String roomName,
    required String userDisplayName,
    String? userEmail,
    String? userAvatarUrl,
    required String serverUrl,
    bool audioMuted = false,
    bool videoMuted = false,
    VoidCallback? onConferenceTerminated,
    ValueChanged<String?>? onError,
  }) async {
    try {
      // Sanitize the room name to ensure it's compatible
      final sanitizedRoomName = _sanitizeRoomName(roomName);
      
      debugPrint("Joining room WITHOUT token: $sanitizedRoomName");
      debugPrint("Server URL: $serverUrl");
      
      // Use 8x8.vc URL if serverUrl is the default meet.jit.si
      if (serverUrl == "https://meet.jit.si") {
        debugPrint("Switching from meet.jit.si to 8x8.vc URL");
        serverUrl = "https://vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db.8x8.vc";
      }
      
      // Create minimal conference options without token
      final options = JitsiMeetConferenceOptions(
        serverURL: serverUrl,
        room: sanitizedRoomName,
        userInfo: JitsiMeetUserInfo(
          displayName: userDisplayName,
          email: userEmail,
          avatar: userAvatarUrl,
        ),
      );
      
      // Join the meeting
      await jitsiMeet.join(options, JitsiMeetEventListener(
        conferenceTerminated: (url, error) {
          debugPrint("Conference ended: $url, error: $error");
          onConferenceTerminated?.call();
        },
        conferenceJoined: (url) => debugPrint("Joined: $url"),
        participantJoined: (email, name, role, id) =>
            debugPrint("Participant joined: $name, role: $role"),
        participantLeft: (id) => debugPrint("Participant left"),
        readyToClose: () => debugPrint("Meeting ready to close"),
      ));
      
      if (audioMuted) await jitsiMeet.setAudioMuted(true);
      if (videoMuted) await jitsiMeet.setVideoMuted(true);
    } catch (e) {
      debugPrint("Join error (without token): $e");
      onError?.call(e.toString());
    }
  }
  
  // Join a public test room with a random name
  Future<void> joinTestRoom({
    required String userDisplayName,
    String? userEmail,
    VoidCallback? onConferenceTerminated,
    ValueChanged<String?>? onError,
  }) async {
    final testRoomName = "vedika-test-${DateTime.now().millisecondsSinceEpoch}";
    
    try {
      debugPrint("Creating public test room: $testRoomName");
      
      // Create simple conference options
      final options = JitsiMeetConferenceOptions(
        serverURL: "https://vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db.8x8.vc",
        room: testRoomName,
        userInfo: JitsiMeetUserInfo(
          displayName: userDisplayName,
          email: userEmail,
        ),
      );
      
      // Join the meeting
      await jitsiMeet.join(options, JitsiMeetEventListener(
        conferenceTerminated: (url, error) {
          debugPrint("Test room ended: $url, error: $error");
          onConferenceTerminated?.call();
        },
        conferenceJoined: (url) => debugPrint("Joined test room: $url"),
      ));
    } catch (e) {
      debugPrint("Test room error: $e");
      onError?.call(e.toString());
    }
  }

  // Join a public test room with random name (useful for testing)
  Future<void> joinPublicRoom({
    required String userDisplayName,
    String? userEmail,
    VoidCallback? onConferenceTerminated,
    ValueChanged<String?>? onError,
  }) async {
    // Generate a random room name
    final String randomRoom = "vedika-test-${DateTime.now().millisecondsSinceEpoch}";
    
    try {
      debugPrint("Creating public test room: $randomRoom");
      
      // Ensure room has tenant prefix for 8x8.vc
      final roomWithPrefix = _ensureTenantPrefix(randomRoom);
      debugPrint("Room with tenant prefix: $roomWithPrefix");
      
      // Create configuration with settings to bypass JWT verification
      final options = JitsiMeetConferenceOptions(
        serverURL: "https://8x8.vc/vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db",
        room: roomWithPrefix,
        configOverrides: {
          // Disable JWT verification
          "disableJWT": true,
          
          // Other helpful settings
          "enableLobby": false,
          "requireDisplayName": false,
          "prejoinPageEnabled": false,
          "p2p.enabled": true,
        },
        featureFlags: {
          // Disable security features
          "invite.enabled": false,
          "security-options.enabled": false,
          "lobby-mode.enabled": false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: userDisplayName,
          email: userEmail,
        ),
      );
      
      debugPrint("Joining public room with JWT verification disabled");
      
      // Join
      await jitsiMeet.join(options, JitsiMeetEventListener(
        conferenceTerminated: (url, error) {
          debugPrint("Test room ended: $url, error: $error");
          onConferenceTerminated?.call();
        },
        conferenceJoined: (url) => debugPrint("Joined test room: $url"),
      ));
    } catch (e) {
      debugPrint("Public room error: $e");
      onError?.call(e.toString());
    }
  }

  // New method that uses the URL directly with minimal parsing
  Future<void> joinWithDirectUrl({
    required String meetingUrl,
    required String userDisplayName,
    String? userEmail,
    String? userAvatarUrl,
    VoidCallback? onConferenceTerminated,
    ValueChanged<String?>? onError,
  }) async {
    try {
      debugPrint("\n====== DIRECT URL JOIN METHOD ======");
      debugPrint("URL: $meetingUrl");
      
      // The URL format should be like:
      // https://8x8.vc/vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db/roomName?jwt=token
      // or
      // https://8x8.vc/vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db/roomName#jwt=token
      
      // Split URL into parts to handle it properly
      final String urlWithoutFragment = meetingUrl.split("#")[0];
      final Uri uri = Uri.parse(urlWithoutFragment);
      
      // Extract the base server URL without path
      final baseServer = "${uri.scheme}://${uri.host}";
      
      // For 8x8.vc URLs, we need to keep the magic cookie part in the server URL
      String serverUrl = baseServer;
      String roomName = "";
      String magicCookiePart = "";
      
      // Get the path segments
      if (uri.pathSegments.isNotEmpty) {
        if (uri.pathSegments.length >= 2) {
          // Format: /vpaas-magic-cookie-XXX/roomName
          // We need both the cookie part and room name
          magicCookiePart = uri.pathSegments[0];
          roomName = uri.pathSegments[1];
          
          // If there's a magic cookie in the URL, include it in the server URL
          if (magicCookiePart.startsWith("vpaas-magic-cookie")) {
            serverUrl = "$baseServer/$magicCookiePart";
            debugPrint("Extracted magic cookie: $magicCookiePart");
          }
        } else {
          // If only one segment, it's likely just the room name
          roomName = uri.pathSegments[0];
        }
      }
      
      // Get JWT token from fragment or query parameter
      String? jwtToken;
      if (meetingUrl.contains("#jwt=")) {
        jwtToken = meetingUrl.split("#jwt=")[1].trim();
        // Remove any URL encoding
        jwtToken = Uri.decodeComponent(jwtToken);
        debugPrint("Extracted JWT token from fragment");
      } else if (uri.queryParameters.containsKey("jwt")) {
        jwtToken = uri.queryParameters["jwt"];
        debugPrint("Extracted JWT token from query parameter");
      }
      
      debugPrint("Server URL: $serverUrl");
      debugPrint("Original Room Name: $roomName");
      
      // IMPORTANT: To fix "Room and token mismatched" error:
      // 1. Check if we have a JWT token and extract the room from it
      String? jwtRoomName;
      if (jwtToken != null && jwtToken.startsWith("ey")) {
        try {
          // Try to decode JWT payload to extract room name
          final parts = jwtToken.split('.');
          if (parts.length == 3) {
            final payloadJson = String.fromCharCodes(
              base64Url.decode(base64Url.normalize(parts[1]))
            );
            final payload = json.decode(payloadJson);
            if (payload.containsKey("room")) {
              jwtRoomName = payload["room"];
              debugPrint("Room name from JWT: $jwtRoomName");
              
              // Use room name from JWT instead of URL if they differ
              if (jwtRoomName != roomName && jwtRoomName != "*") {
                debugPrint("Using room name from JWT instead of URL to fix Room/Token mismatch");
                roomName = jwtRoomName!;
              } else if (jwtRoomName == "*") {
                debugPrint("JWT has wildcard room (*), can be used with any room");
              }
            }
          }
        } catch (e) {
          debugPrint("Error decoding JWT payload: $e");
        }
      }
      
      debugPrint("Final Room Name: $roomName");
      debugPrint("Has JWT: ${jwtToken != null}");
      if (jwtToken != null) {
        debugPrint("JWT token prefix: ${jwtToken.length > 10 ? jwtToken.substring(0, 10) : jwtToken}...");
      }
      
      // Create options with room name that matches JWT token
      final options = JitsiMeetConferenceOptions(
        serverURL: serverUrl,
        room: roomName,
        token: jwtToken,
        userInfo: JitsiMeetUserInfo(
          displayName: userDisplayName,
          email: userEmail,
          avatar: userAvatarUrl,
        ),
        configOverrides: {
          "prejoinPageEnabled": false,
          "disableJWT": false,
          // Add more settings to prevent room/token mismatch
          "enableInsecureRoomNameWarning": false,
        },
      );
      
      // Join with minimal configuration
      await jitsiMeet.join(options, JitsiMeetEventListener(
        conferenceTerminated: (url, error) {
          debugPrint("Conference ended: $url, error: $error");
          onConferenceTerminated?.call();
        },
        conferenceJoined: (url) => debugPrint("Joined conference: $url"),
      ));
    } catch (e) {
      debugPrint("Direct URL join error: $e");
      onError?.call(e.toString());
    }
  }

  // Method to join with specific JWT payload
  Future<void> joinWithJwtPayload({
    required String jwtToken,
    required String userDisplayName,
    String? userEmail,
    String? userAvatarUrl,
    VoidCallback? onConferenceTerminated,
    ValueChanged<String?>? onError,
  }) async {
    try {
      debugPrint("\n====== JOIN WITH SPECIFIC JWT PAYLOAD ======");
      
      // Decode the JWT payload to extract room and other info
      if (jwtToken != null && jwtToken.startsWith("ey")) {
        try {
          // Decode JWT to extract payload
          final parts = jwtToken.split('.');
          if (parts.length == 3) {
            final payloadJson = String.fromCharCodes(
              base64Url.decode(base64Url.normalize(parts[1]))
            );
            final payload = json.decode(payloadJson);
            
            // Extract necessary info from the payload
            final String serverUrl = "https://8x8.vc/vpaas-magic-cookie-8162f5c330b748ceb26b57660afbf8db";
            String roomName = "vedika-meeting";
            
            // Use room from JWT
            if (payload.containsKey("room")) {
              roomName = payload["room"];
              debugPrint("Using room name from JWT: $roomName");
            }
            
            // Create conference options
            final options = JitsiMeetConferenceOptions(
              serverURL: serverUrl,
              room: roomName,
              token: jwtToken,
              userInfo: JitsiMeetUserInfo(
                displayName: userDisplayName,
                email: userEmail,
                avatar: userAvatarUrl,
              ),
              configOverrides: {
                "prejoinPageEnabled": false,
                "enableInsecureRoomNameWarning": false,
              },
            );
            
            // Join the meeting
            await jitsiMeet.join(options, JitsiMeetEventListener(
              conferenceTerminated: (url, error) {
                debugPrint("Conference ended: $url, error: $error");
                onConferenceTerminated?.call();
              },
              conferenceJoined: (url) => debugPrint("Joined conference: $url"),
            ));
          } else {
            throw "Invalid JWT token format - must have 3 parts";
          }
        } catch (e) {
          debugPrint("Error decoding JWT: $e");
          onError?.call("JWT decode error: $e");
        }
      } else {
        throw "Invalid JWT format - must start with 'ey'";
      }
    } catch (e) {
      debugPrint("JWT payload join error: $e");
      onError?.call(e.toString());
    }
  }
}
