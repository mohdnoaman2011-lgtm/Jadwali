package com.example.jadwali

import android.app.Activity
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "jadwali/ringtone")
            .setMethodCallHandler { call, result ->
                if (call.method == "pick") {
                    if (pending != null) {
                        result.error("busy", "picker already open", null)
                        return@setMethodCallHandler
                    }
                    pending = result
                    val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER)
                    intent.putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALL)
                    intent.putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                    intent.putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
                    val cur = call.argument<String>("current")
                    if (!cur.isNullOrEmpty()) {
                        intent.putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, Uri.parse(cur))
                    }
                    startActivityForResult(intent, 4711)
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
                @Suppress("DEPRECATION")
                val uri: Uri? = if (Build.VERSION.SDK_INT >= 33)
                    data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI, Uri::class.java)
                else
                    data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                val title = if (uri != null) RingtoneManager.getRingtone(this, uri)?.getTitle(this) else null
                r?.success(mapOf("uri" to (uri?.toString() ?: ""), "title" to (title ?: "")))
            } else {
                r?.success(null)
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}