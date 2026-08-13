package com.parsaapps.amoozesh_fandoghi

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import org.json.JSONObject
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * 🔐 Small Keystore-backed key/value store for high-value secrets that must
 * survive a plaintext file edit (premium entitlement, parent PIN hash).
 *
 * API 23+: AES-256/GCM key generated inside the Android Keystore. The key
 *          never leaves secure storage, so editing Hive/SharedPreferences
 *          files cannot forge these values.
 * API 21/22: documented fallback — light obfuscation in app-private prefs.
 *          Still not forgeable by editing Hive, but weaker than Keystore
 *          (a device with root could extract it). Devices this old are a
 *          tiny fraction of the audience in 2026.
 *
 * All values are cached in memory after the first read, so repeated calls
 * from Dart do not pay decryption cost.
 */
class SecureStore(private val context: Context) {

    private val keystoreAlias = "kudake_secure_store_v1"
    private val prefsName = "kudake_secure_store"
    private val blobKey = "blob"

    private var cache: MutableMap<String, String>? = null

    @Synchronized
    fun read(key: String): String? = load()?.get(key)

    @Synchronized
    fun write(key: String, value: String) {
        val map = load() ?: mutableMapOf()
        map[key] = value
        save(map)
    }

    @Synchronized
    fun delete(key: String) {
        val map = load() ?: return
        if (map.remove(key) != null) save(map)
    }

    private fun load(): MutableMap<String, String>? {
        cache?.let { return it }
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val payload = prefs.getString(blobKey, null) ?: return null
        val json = decrypt(payload) ?: return null
        val obj = JSONObject(json)
        val map = mutableMapOf<String, String>()
        val keys = obj.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            map[key] = obj.optString(key)
        }
        cache = map
        return map
    }

    private fun save(map: MutableMap<String, String>) {
        // JSONObject(Map) یک raw Java type است و Kotlin به‌صوت سخت‌گیرانه
        // MutableMap<String, String> را نمی‌پذیرد؛ پس فیلدها را صریح می‌گذاریم.
        val jsonObject = JSONObject()
        for ((key, value) in map) {
            jsonObject.put(key, value)
        }
        val payload = encrypt(jsonObject.toString()) ?: return
        cache = map
        context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putString(blobKey, payload)
            .apply()
    }

    private fun encrypt(plainText: String): String? {
        return try {
            if (Build.VERSION.SDK_INT >= 23) {
                encryptWithKeystore(plainText)
            } else {
                obfuscate(plainText.toByteArray(Charsets.UTF_8))
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun decrypt(payload: String): String? {
        return try {
            val decoded = Base64.decode(payload, Base64.NO_WRAP)
            if (Build.VERSION.SDK_INT >= 23) {
                decryptWithKeystore(decoded)
            } else {
                String(xorBytes(decoded), Charsets.UTF_8)
            }
        } catch (_: Exception) {
            null
        }
    }

    @SuppressLint("NewApi")
    private fun encryptWithKeystore(plainText: String): String? {
        val key = getOrCreateKey() ?: return null
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key)
        val cipherText = cipher.doFinal(plainText.toByteArray(Charsets.UTF_8))
        val combined = ByteArray(cipher.iv.size + cipherText.size)
        System.arraycopy(cipher.iv, 0, combined, 0, cipher.iv.size)
        System.arraycopy(cipherText, 0, combined, cipher.iv.size, cipherText.size)
        return Base64.encodeToString(combined, Base64.NO_WRAP)
    }

    @SuppressLint("NewApi")
    private fun decryptWithKeystore(decoded: ByteArray): String? {
        val key = getOrCreateKey() ?: return null
        if (decoded.size < 13) return null
        val iv = decoded.copyOfRange(0, 12)
        val cipherText = decoded.copyOfRange(12, decoded.size)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(128, iv))
        return String(cipher.doFinal(cipherText), Charsets.UTF_8)
    }

    @SuppressLint("NewApi")
    private fun getOrCreateKey(): SecretKey? {
        if (Build.VERSION.SDK_INT < 23) return null
        val ks = KeyStore.getInstance("AndroidKeyStore")
        ks.load(null as KeyStore.LoadStoreParameter?)
        (ks.getKey(keystoreAlias, null) as? SecretKey)?.let { return it }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        val spec = KeyGenParameterSpec.Builder(
            keystoreAlias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .build()
        generator.init(spec)
        return generator.generateKey()
    }

    private fun obfuscate(plain: ByteArray): String {
        return Base64.encodeToString(xorBytes(plain), Base64.NO_WRAP)
    }

    private fun xorBytes(input: ByteArray): ByteArray {
        val out = ByteArray(input.size)
        for (i in input.indices) {
            out[i] = (input[i].toInt() xor 0x5A).toByte()
        }
        return out
    }
}
