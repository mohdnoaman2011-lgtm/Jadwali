package com.example.jadwali

import android.app.Activity
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
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
