package com.vedika.heath.vedika_healthcare

import android.app.PictureInPictureParams
import android.app.PendingIntent
import android.app.RemoteAction
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import android.util.Rational
import android.graphics.drawable.Icon
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val controlChannelName = "native_speech/control"
    private val eventChannelName = "native_speech/events"
    private val pipChannelName = "pip_channel"
    private val meetingNotifChannelName = "meeting_notification"

    private var eventSink: EventChannel.EventSink? = null
    private var receiverRegistered = false
    private var isInMeetingScreen: Boolean = false
    private var pipChannel: MethodChannel? = null
    private var inScreenShareFlow: Boolean = false
    private var meetingNotifChannel: MethodChannel? = null
    private val ACTION_OPEN_MEETING = "com.vedika.heath.vedika_healthcare.OPEN_MEETING"

    private val ACTION_PIP_MIC = "com.vedika.heath.vedika_healthcare.PIP_MIC"
    private val ACTION_PIP_CAM = "com.vedika.heath.vedika_healthcare.PIP_CAM"
    private val ACTION_PIP_END = "com.vedika.heath.vedika_healthcare.PIP_END"
    private val ACTION_PIP_EXPAND = "com.vedika.heath.vedika_healthcare.PIP_EXPAND"

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

        // PiP channel
        pipChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannelName)
        pipChannel?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "enterPiPMode" -> {
                        startPiPMode()
                        result.success(null)
                    }
                    "setMeetingScreen" -> {
                        val flag = call.arguments as? Boolean ?: false
                        isInMeetingScreen = flag
                        result.success(null)
                    }
                    "setScreenShareFlow" -> {
                        val flag = call.arguments as? Boolean ?: false
                        inScreenShareFlow = flag
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Meeting notification channel
        meetingNotifChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, meetingNotifChannelName)
        meetingNotifChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "showOngoing" -> {
                    val args = call.arguments as? Map<*, *>
                    val title = args?.get("title") as? String ?: "Meeting in progress"
                    val text = args?.get("text") as? String ?: "Tap to return to the meeting"
                    showOngoingMeetingNotification(title, text)
                    result.success(true)
                }
                "cancelOngoing" -> {
                    cancelOngoingMeetingNotification()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onPictureInPictureRequested(): Boolean {
        Log.d("MainActivity", "onPictureInPictureRequested: $isInMeetingScreen")
        return if (isInMeetingScreen) {
            startPiPMode()
            true
        } else {
            super.onPictureInPictureRequested()
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode)
        if (isInPictureInPictureMode) {
            updatePipActions()
        }
        try {
            pipChannel?.invokeMethod("onPipChanged", isInPictureInPictureMode)
        } catch (_: Throwable) {
        }
    }

    override fun onUserLeaveHint() {
        // Trigger PiP when user presses Home/Recents from meeting screen
        if (isInMeetingScreen && !inScreenShareFlow) {
            startPiPMode()
        } else {
            super.onUserLeaveHint()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        when (intent.action) {
            ACTION_PIP_MIC -> {
                try { pipChannel?.invokeMethod("onPipAction", "mic") } catch (_: Throwable) {}
            }
            ACTION_PIP_CAM -> {
                try { pipChannel?.invokeMethod("onPipAction", "cam") } catch (_: Throwable) {}
            }
            ACTION_PIP_END -> {
                try { pipChannel?.invokeMethod("onPipAction", "end") } catch (_: Throwable) {}
            }
            ACTION_PIP_EXPAND -> {
                // Bringing activity to foreground will automatically expand from PiP
                // Nothing else needed; still notify Flutter in case UI needs refresh
                try { pipChannel?.invokeMethod("onPipAction", "expand") } catch (_: Throwable) {}
            }
            ACTION_OPEN_MEETING -> {
                try { meetingNotifChannel?.invokeMethod("onOpenMeeting", null) } catch (_: Throwable) {}
            }
        }
    }

    private fun updatePipActions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            else
                PendingIntent.FLAG_UPDATE_CURRENT

            val micIntent = Intent(this, MainActivity::class.java).apply { action = ACTION_PIP_MIC }
            val camIntent = Intent(this, MainActivity::class.java).apply { action = ACTION_PIP_CAM }
            val endIntent = Intent(this, MainActivity::class.java).apply { action = ACTION_PIP_END }
            val expandIntent = Intent(this, MainActivity::class.java).apply { action = ACTION_PIP_EXPAND }

            val micPending = PendingIntent.getActivity(this, 1001, micIntent, flags)
            val camPending = PendingIntent.getActivity(this, 1002, camIntent, flags)
            val endPending = PendingIntent.getActivity(this, 1003, endIntent, flags)
            val expandPending = PendingIntent.getActivity(this, 1004, expandIntent, flags)

            val actions = arrayListOf(
                RemoteAction(
                    Icon.createWithResource(this, android.R.drawable.ic_btn_speak_now),
                    "Mic", "Toggle Mic", micPending
                ),
                RemoteAction(
                    Icon.createWithResource(this, android.R.drawable.ic_menu_camera),
                    "Cam", "Toggle Camera", camPending
                ),
                RemoteAction(
                    Icon.createWithResource(this, android.R.drawable.ic_menu_close_clear_cancel),
                    "End", "End Call", endPending
                ),
                RemoteAction(
                    Icon.createWithResource(this, android.R.drawable.ic_menu_view),
                    "Expand", "Expand", expandPending
                )
            )

            val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(16, 9))
                .setActions(actions)
                .build()
            try {
                setPictureInPictureParams(params)
            } catch (_: Throwable) {}
        }
    }

    private fun startPiPMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val aspect = Rational(16, 9)
                updatePipActions()
                val params = PictureInPictureParams.Builder().setAspectRatio(aspect).build()
                enterPictureInPictureMode(params) // params used here, then actions applied above
            } catch (t: Throwable) {
                Log.e("MainActivity", "Failed to enter PiP", t)
            }
        }
    }

    // Notification support
    private fun ensureMeetingNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
            val channelId = "meeting_ongoing"
            if (mgr.getNotificationChannel(channelId) == null) {
                val channel = android.app.NotificationChannel(
                    channelId,
                    "Meeting Status",
                    android.app.NotificationManager.IMPORTANCE_LOW
                )
                channel.description = "Shows when a meeting is ongoing"
                mgr.createNotificationChannel(channel)
            }
        }
    }

    private fun showOngoingMeetingNotification(title: String, text: String) {
        val context = this
        ensureMeetingNotificationChannel(context)
        val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        val channelId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) "meeting_ongoing" else ""
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        else
            PendingIntent.FLAG_UPDATE_CURRENT

        val openIntent = Intent(context, MainActivity::class.java).apply { action = ACTION_OPEN_MEETING }
        val contentPending = PendingIntent.getActivity(context, 2001, openIntent, flags)

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            android.app.Notification.Builder(context, channelId)
        } else {
            @Suppress("DEPRECATION")
            android.app.Notification.Builder(context)
        }
        val notif = builder
            .setSmallIcon(android.R.drawable.stat_sys_phone_call)
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setContentIntent(contentPending)
            .build()
        mgr.notify(2011, notif)
    }

    private fun cancelOngoingMeetingNotification() {
        val context = this
        val mgr = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        mgr.cancel(2011)
    }
}
