import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:vedika_healthcare/firebase_options.dart';
import 'package:vedika_healthcare/shared/utils/AppLifecycleObserver.dart';

class AppInitializer {
  static Future<void> initCore() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initFirebase();
    await _configureFirebaseServices();
    _attachLifecycleObserver();
  }

  static Future<void> _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<void> _configureFirebaseServices() async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kReleaseMode);
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(!kDebugMode);
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void _attachLifecycleObserver() {
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  }
}


