package com.vedika.heath.vedika_healthcare

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "fall_detection_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d("MainActivity", "Flutter engine configured")
        val serviceIntent = Intent(this, FallDetectionService::class.java)
        val canStart = packageManager.resolveService(serviceIntent, 0) != null
        Log.d("MainActivity", "Can resolve service: $canStart")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                Log.d("MainActivity", "Method call received: ${call.method}")

                if (call.method == "startFallDetectionService") {
                    try {
                        Log.d("MainActivity", "Starting FallDetectionService...")
                        val intent = Intent(this, FallDetectionService::class.java)
                        startForegroundService(intent)
                        Log.d("MainActivity", "FallDetectionService started via intent")
                        result.success("Fall detection service started")
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Failed to start service", e)
                        result.error("SERVICE_ERROR", "Could not start service", e.message)
                    }
                } else {
                    Log.w("MainActivity", "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
    }
}
