package com.example.jadwali

import android.app.Activity
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.app.NotificationManager
import android.provider.Settings

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= 27) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "jadwali/store")
            .setMethodCallHandler { call, result ->
                val sp = getSharedPreferences("jadwali_store", Context.MODE_PRIVATE)
                when (call.method) {
                    "get" -> result.success(sp.getString("all", ""))
                    "set" -> {
                        val v = call.arguments as? String ?: ""
                        result.success(sp.edit().putString("all", v).commit())
                    }
                    "fsi" -> {
                        // إذن عرض التنبيه على شاشة القفل (أندرويد 14+)
                        var ok = true
                        if (Build.VERSION.SDK_INT >= 34) {
                            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                            ok = nm.canUseFullScreenIntent()
                            if (!ok) {
                                try {
                                    startActivity(
                                        Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT)
                                            .setData(Uri.parse("package:" + packageName))
                                    )
                                } catch (e: Exception) {
                                }
                            }
                        }
                        result.success(ok)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "jadwali/ringtone")
            .setMethodCallHandler { call, result ->
                if (call.method == "pick") {
                    pending = result
                    val i = Intent(RingtoneManager.ACTION_RINGTONE_PICKER)
                    i.putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
                    i.putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                    i.putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
                    startActivityForResult(i, 4711)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == 4711) {
            val r = pending
            pending = null
            if (resultCode == Activity.RESULT_OK && data != null) {
                val uri: Uri? = data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                if (uri != null) {
                    val title = RingtoneManager.getRingtone(this, uri)?.getTitle(this) ?: ""
                    r?.success(mapOf("uri" to uri.toString(), "title" to title))
                } else {
                    r?.success(null)
                }
            } else {
                r?.success(null)
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
