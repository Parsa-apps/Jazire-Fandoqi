package com.parsaapps.amoozesh_fandoghi

import android.util.Base64
import org.json.JSONObject
import java.security.KeyFactory
import java.security.Signature
import java.security.spec.X509EncodedKeySpec

/**
 * Re-check the signed store JSON, not an SDK success flag or a cached token.
 * The same check is used for live purchases, inventory and offline receipts.
 * SHA1withRSA is the receipt format used by both store SDKs, not a choice of
 * algorithm made by the application. No receipt or token is logged.
 */
internal class StoreReceiptVerifier(
    private val packageName: String,
    private val publicKeys: Map<StoreVendor, String>,
    private val decodeBase64: (String) -> ByteArray = {
        Base64.decode(it, Base64.DEFAULT)
    },
) {
    fun verify(
        store: StoreVendor,
        signedData: String?,
        signature: String?,
        expectedProductId: String,
    ): BillingOutcome {
        val key = publicKeys[store]
        if ((expectedProductId == ProductionBillingPolicy.FULL_VERSION_PRODUCT_ID &&
                store != StoreVendor.MYKET) ||
            store == StoreVendor.UNKNOWN || key.isNullOrBlank() ||
            signedData.isNullOrBlank() || signature.isNullOrBlank() ||
            expectedProductId.isBlank()
        ) {
            return BillingOutcome.invalidReceipt()
        }
        return try {
            val publicKey = KeyFactory.getInstance("RSA").generatePublic(
                X509EncodedKeySpec(decodeBase64(key)),
            )
            val verifier = Signature.getInstance("SHA1withRSA")
            verifier.initVerify(publicKey)
            verifier.update(signedData.toByteArray(Charsets.UTF_8))
            if (!verifier.verify(decodeBase64(signature))) {
                return BillingOutcome.invalidReceipt()
            }
            val receipt = JSONObject(signedData)
            val productId = receipt.opt("productId") as? String
            val receiptPackage = receipt.opt("packageName") as? String
            val state = receipt.opt("purchaseState")
            val token = (receipt.opt("token") as? String)
                ?.takeIf { it.isNotBlank() }
                ?: (receipt.opt("purchaseToken") as? String)
            if (productId != expectedProductId || receiptPackage != packageName ||
                state !is Number || state.toDouble() != 0.0 ||
                token.isNullOrBlank() || token.trim() == "sandbox-token"
            ) {
                return BillingOutcome.invalidReceipt()
            }
            BillingOutcome(
                success = true,
                token = token,
                orderId = receipt.opt("orderId") as? String,
                message = "خرید با رسید امضاشده تأیید شد",
                status = "verified",
                productId = productId,
                store = store.name.lowercase(),
                purchaseState = 0,
                signedData = signedData,
                signature = signature,
            )
        } catch (_: Exception) {
            BillingOutcome.invalidReceipt()
        }
    }
}
