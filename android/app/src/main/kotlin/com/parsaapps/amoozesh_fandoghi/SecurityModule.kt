package com.parsaapps.amoozesh_fandoghi

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import java.io.File
import java.net.InetSocketAddress
import java.net.Socket
import java.security.MessageDigest

/**
 * 🔐 Anti-tamper & anti-instrumentation module (native side).
 *
 * Answers "is this APK the official release, running on a device that can be
 * trusted?" for the Dart security layer. Every check is cheap, never throws
 * and never blocks the UI thread for long.
 *
 * What each check protects against:
 *  - signatureMatch      : repackaged APK (re-signed with a different cert)
 *  - debuggable          : debug-signed release impostor
 *  - debuggerConnected   : attached debugger / Android Studio session
 *  - frida/xposed        : dynamic instrumentation frameworks (runtime hooks)
 *  - rooted              : su/Magisk present (used to edit app data files)
 *  - emulator            : sandboxed analysis environments
 */
class SecurityModule(private val context: Context) {

    fun snapshot(): Map<String, Any?> {
        val isDebuggable = (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        val debuggerConnected = Debug.isDebuggerConnected() || Debug.waitingForDebugger()
        val expected = BuildConfig.EXPECTED_SIGNING_SHA256.lowercase()
        val actual = signingCertificateSha256().lowercase()
        return mapOf(
            "debuggable" to isDebuggable,
            "debuggerConnected" to debuggerConnected,
            "rooted" to detectRoot(),
            "customRom" to detectCustomRom(),
            "fridaDetected" to detectFrida(),
            "xposedDetected" to detectXposed(),
            "emulator" to detectEmulator(),
            "signatureSha256" to actual,
            "expectedSignatureSha256" to expected,
            // When no expected digest is configured (CI verification builds)
            // the check is not applicable and reports true.
            "signatureMatch" to (expected.isEmpty() || (actual.isNotEmpty() && expected == actual)),
            "installerPackage" to (context.packageManager.getInstallerPackageName(context.packageName) ?: ""),
        )
    }

    /** Well-known root indicator files/binaries. */
    private fun detectRoot(): Boolean {
        val indicators = listOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/system/app/Superuser.apk",
            "/system/etc/init.d/99SuperSUDaemon",
            "/system/xbin/which",
            "/data/adb/magisk",
            "/sbin/.magisk",
            "/sbin/magisk",
        )
        return indicators.any { File(it).exists() }
    }

    /** Custom ROMs (test-keys builds) are a soft signal, reported separately. */
    private fun detectCustomRom(): Boolean = Build.TAGS?.contains("test-keys") == true

    /** Frida server / gadget / linjector presence. */
    private fun detectFrida(): Boolean {
        // 1) Default Frida server ports.
        if (tcpPortOpen(27042, 250)) return true
        if (tcpPortOpen(27043, 250)) return true
        // 2) Injected libraries visible in this process's memory map.
        try {
            val maps = File("/proc/self/maps").readText()
            if (maps.contains("frida") || maps.contains("linjector") || maps.contains("gadget")) {
                return true
            }
        } catch (_: Exception) {
            // /proc not readable — treat as clean; other signals still apply.
        }
        // 3) Frida server binaries in /data/local/tmp.
        try {
            val files = File("/data/local/tmp").listFiles() ?: emptyArray()
            if (files.any { it.name.contains("frida") || it.name.contains("linjector") }) {
                return true
            }
        } catch (_: Exception) {
            // Directory not accessible — ignore.
        }
        return false
    }

    /** Xposed framework presence. */
    private fun detectXposed(): Boolean {
        val indicators = listOf(
            "/system/lib/libxposed_art.so",
            "/system/lib64/libxposed_art.so",
            "/system/framework/XposedBridge.jar",
            "/data/data/de.robv.android.xposed.installer",
        )
        if (indicators.any { File(it).exists() }) return true
        return try {
            File("/proc/self/maps").readText().contains("xposed")
        } catch (_: Exception) {
            false
        }
    }

    /** Common emulator fingerprints (best-effort, avoids cheap-device FPs). */
    private fun detectEmulator(): Boolean {
        val fingerprint = Build.FINGERPRINT ?: ""
        val model = Build.MODEL ?: ""
        val manufacturer = Build.MANUFACTURER ?: ""
        val hardware = Build.HARDWARE ?: ""
        val product = Build.PRODUCT ?: ""
        val brand = Build.BRAND ?: ""
        return fingerprint.contains("generic") ||
            fingerprint.contains("emulator") ||
            model.contains("Emulator") ||
            model.contains("Android SDK built for") ||
            manufacturer.contains("Genymotion") ||
            hardware.contains("goldfish") ||
            hardware.contains("ranchu") ||
            product.contains("sdk_gphone") ||
            product.contains("sdk_google") ||
            brand.startsWith("generic")
    }

    private fun tcpPortOpen(port: Int, timeoutMs: Int): Boolean {
        return try {
            Socket().use { socket ->
                socket.connect(InetSocketAddress("127.0.0.1", port), timeoutMs)
                true
            }
        } catch (_: Exception) {
            false
        }
    }

    /** SHA-256 (hex, lowercase) of the signing certificate of the installed APK. */
    private fun signingCertificateSha256(): String {
        return try {
            val pm = context.packageManager
            val info = pm.getPackageInfo(
                context.packageName,
                if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES
                else @Suppress("DEPRECATION") PackageManager.GET_SIGNATURES,
            )
            val signerBytes: ByteArray? = if (Build.VERSION.SDK_INT >= 28) {
                info.signingInfo?.apkContentsSigners?.firstOrNull()?.toByteArray()
            } else {
                @Suppress("DEPRECATION")
                info.signatures?.firstOrNull()?.toByteArray()
            } ?: return ""
            val digest = MessageDigest.getInstance("SHA-256").digest(signerBytes)
            digest.joinToString("") { byte -> String.format("%02x", byte) }
        } catch (_: Exception) {
            ""
        }
    }
}
