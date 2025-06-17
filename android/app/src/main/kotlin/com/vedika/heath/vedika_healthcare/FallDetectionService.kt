package com.vedika.heath.vedika_healthcare

import android.app.*
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*
import java.net.HttpURLConnection
import java.net.URL

class FallDetectionService : Service(), SensorEventListener {

    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private val threshold = 15.0 // Adjust sensitivity here

    // Cooldown to prevent multiple rapid calls
    private var lastFallTime = 0L
    private val cooldownMillis = 5000 // 5 seconds

    private val apiUrl = ApiConstants.fallAlert

    override fun onCreate() {
        super.onCreate()
        Log.d("FallDetectionService", "Service created")

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        startForegroundService()
    }

    private fun startForegroundService() {
        val notificationChannelId = "fall_detection_channel"
        val channel = NotificationChannel(
            notificationChannelId,
            "Fall Detection Service",
            NotificationManager.IMPORTANCE_LOW
        )
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .createNotificationChannel(channel)

        val notification = NotificationCompat.Builder(this, notificationChannelId)
            .setContentTitle("Fall Detection Active")
            .setContentText("Monitoring for falls in the background.")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()

        startForeground(1, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("FallDetectionService", "Service started")
        accelerometer?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
        return START_STICKY
    }

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onSensorChanged(event: SensorEvent?) {
        event?.let {
            val x = it.values[0]
            val y = it.values[1]
            val z = it.values[2]
            val magnitude = Math.sqrt((x * x + y * y + z * z).toDouble())

            if (magnitude > threshold) {
                val currentTime = System.currentTimeMillis()
                if (currentTime - lastFallTime > cooldownMillis) {
                    lastFallTime = currentTime
                    Log.d("FallDetectionService", "Fall detected: $magnitude")
                    sendFallAlert()
                }
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private fun sendFallAlert() {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val url = URL(apiUrl)
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json")
                conn.doOutput = true
                conn.connectTimeout = 5000
                conn.readTimeout = 5000

                val jsonBody = "{}" // Customize with payload if needed
                conn.outputStream.write(jsonBody.toByteArray())
                conn.outputStream.flush()
                conn.outputStream.close()

                val responseCode = conn.responseCode
                Log.d("FallDetectionService", "API response code: $responseCode")

                conn.inputStream.close()
                conn.disconnect()
            } catch (e: Exception) {
                Log.e("FallDetectionService", "API call failed", e)
            }
        }
    }
}
