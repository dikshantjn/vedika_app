import 'package:vedika_healthcare/shared/services/GlobalKeys.dart';
import 'package:flutter/material.dart';
import 'view/meeting_page.dart';
import 'viewmodel/video_meeting_view_model.dart';

class MeetingSession {
  static VideoMeetingViewModel? currentVm;
  static String? meetingId;
  static String? token;
  static String? displayName;
  static String? role;
  static bool enableWaitingRoom = true;

  static void start({
    required VideoMeetingViewModel vm,
    required String id,
    required String t,
    required String name,
    required String r,
    required bool waiting,
  }) {
    currentVm = vm;
    meetingId = id;
    token = t;
    displayName = name;
    role = r;
    enableWaitingRoom = waiting;
  }

  static void clear() {
    currentVm = null;
    meetingId = null;
    token = null;
    displayName = null;
    role = null;
    enableWaitingRoom = true;
  }

  static void reopenIfPossible() {
    final vm = currentVm;
    final id = meetingId;
    final t = token;
    final n = displayName;
    final r = role;
    if (vm == null || id == null || t == null || n == null || r == null) return;
    final nav = navigatorKey.currentState;
    nav?.push(MaterialPageRoute(
      builder: (_) => MeetingPage(
        meetingId: id,
        token: t,
        displayName: n,
        role: r,
        enableWaitingRoom: enableWaitingRoom,
        existingViewModel: vm,
      ),
    ));
  }
}


