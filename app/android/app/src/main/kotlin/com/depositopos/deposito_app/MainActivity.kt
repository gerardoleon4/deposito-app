package com.depositopos.deposito_app

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.anaquel/pantalla"
        ).setMethodCallHandler { call, result ->
            if (call.method == "mantenerEncendida") {
                val activa = call.argument<Boolean>("activa") ?: false
                runOnUiThread {
                    if (activa) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
