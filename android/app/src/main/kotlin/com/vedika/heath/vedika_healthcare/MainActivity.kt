package com.vedika.heath.vedika_healthcare

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val controlChannelName = "native_speech/control"
    private val eventChannelName = "native_speech/events"

    private var eventSink: EventChannel.EventSink? = null
    private var receiverRegistered = false

    private val speechReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent == null) return
            when (intent.action) {
                NativeSpeechService.ACTION_RESULT -> {
                    val text = intent.getStringExtra(NativeSpeechService.EXTRA_TEXT) ?: ""
                    val isFinal = intent.getBooleanExtra(NativeSpeechService.EXTRA_FINAL, false)
                    eventSink?.success(mapOf("type" to "result", "text" to text, "final" to isFinal))
                }
                NativeSpeechService.ACTION_STATUS -> {
                    val status = intent.getStringExtra(NativeSpeechService.EXTRA_STATUS) ?: ""
                    eventSink?.success(mapOf("type" to "status", "status" to status))
                }
                NativeSpeechService.ACTION_ERROR -> {
                    val err = intent.getStringExtra(NativeSpeechService.EXTRA_ERROR) ?: "unknown"
                    eventSink?.success(mapOf("type" to "error", "error" to err))
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, controlChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val intent = Intent(this, NativeSpeechService::class.java).apply {
                            action = NativeSpeechService.ACTION_START
                        }
                        ContextCompat.startForegroundService(this, intent)
                        result.success(true)
                    }
                    "stop" -> {
                        stopService(Intent(this, NativeSpeechService::class.java))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    if (!receiverRegistered) {
                        val filter = IntentFilter().apply {
                            addAction(NativeSpeechService.ACTION_RESULT)
                            addAction(NativeSpeechService.ACTION_STATUS)
                            addAction(NativeSpeechService.ACTION_ERROR)
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            registerReceiver(speechReceiver, filter, Context.RECEIVER_EXPORTED)
                        } else {
                            registerReceiver(speechReceiver, filter)
                        }
                        receiverRegistered = true
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    if (receiverRegistered) {
                        unregisterReceiver(speechReceiver)
                        receiverRegistered = false
                    }
                }
            })
    }
}
