import 'package:flutter/material.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  static bool isInBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Print the lifecycle state for debugging
    print("AppLifecycleState: $state");

    if (state == AppLifecycleState.paused) {
      isInBackground = true;
      print("App is in background");
    } else if (state == AppLifecycleState.resumed) {
      isInBackground = false;
      print("App is in foreground");
    }
  }
}
