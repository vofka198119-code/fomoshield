package com.scanco.scanco

import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageInstaller
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        val insetsController = WindowInsetsControllerCompat(window, window.decorView)
        insetsController.isAppearanceLightStatusBars = true
        insetsController.isAppearanceLightNavigationBars = true
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            val insetsController = WindowInsetsControllerCompat(window, window.decorView)
            insetsController.isAppearanceLightStatusBars = true
            insetsController.isAppearanceLightNavigationBars = true
        }
    }

    // ── APK install channel (PackageInstaller Session API) ──────────────────
    // Robust Android self-update: installs the downloaded APK via the system
    // PackageInstaller — no FileProvider, no open_filex, no browser redirects.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "scanco/installer")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canInstall" -> result.success(canRequestPackageInstalls())
                    "installApk" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("bad_args", "Missing APK path", null)
                        } else {
                            installApk(path, result)
                        }
                    }
                    "openInstallSettings" -> {
                        openInstallSettings()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun installApk(path: String, result: MethodChannel.Result) {
        if (!canRequestPackageInstalls()) {
            result.success("permission_missing")
            return
        }
        val file = File(path)
        if (!file.exists()) {
            result.error("file_missing", "APK not found: $path", null)
            return
        }
        try {
            val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
            params.setAppPackageName(packageName)
            val sessionId = packageManager.packageInstaller.createSession(params)
            val session = packageManager.packageInstaller.openSession(sessionId)
            try {
                val out: OutputStream = session.openWrite("ScanCo", 0, file.length())
                FileInputStream(file).use { input ->
                    val buffer = ByteArray(128 * 1024)
                    var read: Int
                    while (input.read(buffer).also { read = it } != -1) {
                        out.write(buffer, 0, read)
                    }
                }
                out.close()
            } finally {
                session.close()
            }
            val intent = Intent("com.scanco.scanco.INSTALL_RESULT")
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            val sender = PendingIntent.getBroadcast(this, 0, intent, flags).intentSender
            packageManager.packageInstaller.commit(sessionId, sender)
            result.success("started")
        } catch (e: Exception) {
            result.error("install_failed", e.message ?: "Install failed", null)
        }
    }

    private fun openInstallSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(
                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:$packageName")
            )
        } else {
            Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
        }
        startActivity(intent)
    }
}
