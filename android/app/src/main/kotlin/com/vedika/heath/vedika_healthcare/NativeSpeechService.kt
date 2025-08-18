package com.vedika.heath.vedika_healthcare

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.IBinder
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.core.app.NotificationCompat
import android.content.pm.ServiceInfo
import androidx.core.content.ContextCompat
import android.Manifest
import android.content.pm.PackageManager

class NativeSpeechService : Service() {

    companion object {
        const val ACTION_START = "native_speech.action.START"
        const val ACTION_STOP = "native_speech.action.STOP"

        const val ACTION_RESULT = "native_speech.action.RESULT"
        const val ACTION_STATUS = "native_speech.action.STATUS"
        const val ACTION_ERROR = "native_speech.action.ERROR"

        const val EXTRA_TEXT = "text"
        const val EXTRA_FINAL = "final"
        const val EXTRA_STATUS = "status"
        const val EXTRA_ERROR = "error"

        private const val NOTIFICATION_ID = 101
        private const val CHANNEL_ID = "native_speech_channel"
    }

    private var speechRecognizer: SpeechRecognizer? = null
    private var recognizerIntent: Intent? = null
    private var isListening = false
    private val handler = Handler(Looper.getMainLooper())
    // Allow longer overall session so user can speak naturally
    private val maxSessionMs = 120_000L
    // Allow up to ~3 seconds of pause before considering speech complete
    private val silenceMs = 3_000L
    // Reduce minimum speech input length for faster first token
    private val minInputMs = 300L
    private val sessionTimeoutRunnable = Runnable {
        stopListening()
        stopSelf()
    }

    override fun onCreate() {
        super.onCreate()
        initSpeechRecognizer()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotification()

        when (intent?.action) {
            ACTION_START -> startListening()
            ACTION_STOP -> stopListening()
        }
        return START_STICKY
    }

    override fun onDestroy() {
        stopListening()
        speechRecognizer?.destroy()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun initSpeechRecognizer() {
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            sendError("Speech recognition not available on this device")
            stopSelf()
            return
        }

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
            )
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, silenceMs)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, silenceMs)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, minInputMs)
        }

        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                sendStatus("ready")
            }

            override fun onBeginningOfSpeech() {
                sendStatus("listening")
            }

            override fun onRmsChanged(rmsdB: Float) {}

            override fun onBufferReceived(buffer: ByteArray?) {}

            override fun onEndOfSpeech() {
                sendStatus("processing")
            }

            override fun onError(error: Int) {
                val message = when (error) {
                    SpeechRecognizer.ERROR_NETWORK -> "Network error"
                    SpeechRecognizer.ERROR_NO_MATCH -> "No match found"
                    SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "No speech input"
                    SpeechRecognizer.ERROR_AUDIO -> "Audio recording error"
                    SpeechRecognizer.ERROR_CLIENT -> "Client side error"
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Insufficient permissions"
                    else -> "Error code: $error"
                }
                sendError(message)
                stopListening()
                stopSelf()
            }

            override fun onResults(results: Bundle?) {
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                val candidate = matches?.firstOrNull() ?: ""
                val text = cleanText(candidate)
                sendResult(text, true)
                stopListening()
                stopSelf()
            }

            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                val candidate = matches?.firstOrNull() ?: ""
                val text = cleanText(candidate)
                sendResult(text, false)
            }

            override fun onEvent(eventType: Int, params: Bundle?) {}
        })
    }

    private fun startListening() {
        if (isListening) return
        speechRecognizer?.startListening(recognizerIntent)
        isListening = true
        handler.removeCallbacks(sessionTimeoutRunnable)
        handler.postDelayed(sessionTimeoutRunnable, maxSessionMs)
    }

    private fun restartListening() {
        if (!isListening) return
        // Briefly cancel and restart to extend session without tearing down service
        speechRecognizer?.cancel()
        handler.postDelayed({
            speechRecognizer?.startListening(recognizerIntent)
        }, 150L)
    }

    private fun stopListening() {
        if (!isListening) return
        speechRecognizer?.stopListening()
        stopForeground(true)
        isListening = false
        handler.removeCallbacks(sessionTimeoutRunnable)
        sendStatus("stopped")
    }

    private fun createNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Speech Recognition",
                NotificationManager.IMPORTANCE_LOW
            )
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(channel)
        }

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Listening for speech…")
            .setContentText("Speak now")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)

        val notification: Notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            builder.setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
                .build()
        } else {
            builder.build()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun sendResult(text: String, isFinal: Boolean) {
        val intent = Intent(ACTION_RESULT).apply {
            putExtra(EXTRA_TEXT, text)
            putExtra(EXTRA_FINAL, isFinal)
        }
        sendBroadcast(intent)
    }

    private fun sendStatus(status: String) {
        val intent = Intent(ACTION_STATUS).apply {
            putExtra(EXTRA_STATUS, status)
            setPackage(packageName)
        }
        sendBroadcast(intent)
    }

    private fun sendError(error: String) {
        val intent = Intent(ACTION_ERROR).apply {
            putExtra(EXTRA_ERROR, error)
        }
        sendBroadcast(intent)
    }

    // Reduce duplicate phrases like "nearest hospital nearest hospital"
    private fun cleanText(raw: String): String {
        if (raw.isEmpty()) return raw
        val parts = raw.trim().split(" ")
        if (parts.size < 2) return raw
        val builder = StringBuilder()
        var prev = ""
        for (p in parts) {
            if (!p.equals(prev, ignoreCase = true)) {
                if (builder.isNotEmpty()) builder.append(' ')
                builder.append(p)
            }
            prev = p
        }
        return builder.toString()
    }
}
