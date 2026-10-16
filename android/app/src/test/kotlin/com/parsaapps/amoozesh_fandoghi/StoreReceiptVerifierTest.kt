package com.parsaapps.amoozesh_fandoghi

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.Signature
import java.util.Base64

/** Real cryptography with generated test-only keys, not a mocked success flag. */
class StoreReceiptVerifierTest {
    companion object {
        private const val PACKAGE = "com.parsaapps.amoozesh_fandoghi"
        private const val PRODUCT = "full_version"
        private val keys: KeyPair = KeyPairGenerator.getInstance("RSA").run {
            initialize(2048)
            generateKeyPair()
        }
        private val otherKeys: KeyPair = KeyPairGenerator.getInstance("RSA").run {
            initialize(2048)
            generateKeyPair()
        }
    }

    private fun receipt(change: (JSONObject) -> Unit = {}): String = JSONObject()
        .put("packageName", PACKAGE)
        .put("productId", PRODUCT)
        .put("purchaseState", 0)
        .put("purchaseToken", "signed-test-purchase-token")
        .put("orderId", "test-order")
        .also(change)
        .toString()

    private fun sign(data: String, keyPair: KeyPair = keys): String {
        val signer = Signature.getInstance("SHA1withRSA")
        signer.initSign(keyPair.private)
        signer.update(data.toByteArray(Charsets.UTF_8))
        return Base64.getEncoder().encodeToString(signer.sign())
    }

    private fun verifier(keyPair: KeyPair = keys) = StoreReceiptVerifier(
        PACKAGE,
        mapOf(
            StoreVendor.MYKET to Base64.getEncoder().encodeToString(keyPair.public.encoded),
            StoreVendor.BAZAAR to Base64.getEncoder().encodeToString(keyPair.public.encoded),
        ),
        decodeBase64 = { Base64.getDecoder().decode(it) },
    )

    private fun check(data: String, signature: String = sign(data)) =
        verifier().verify(StoreVendor.MYKET, data, signature, PRODUCT)

    @Test
    fun signedCompletedMyketPurchaseIsAccepted() {
        val data = receipt()
        val result = verifier().verify(StoreVendor.MYKET, data, sign(data), PRODUCT)
        assertTrue(result.success)
        assertEquals("verified", result.status)
        assertEquals(PRODUCT, result.productId)
        assertEquals(0, result.purchaseState)
        assertEquals("myket", result.store)
        assertEquals(data, result.signedData)
        assertEquals("signed-test-purchase-token", result.token)
        // RSA is separate from the bridge's official-release attestation.
        assertFalse(result.releaseVerified)
        assertTrue(ProductionBillingPolicy.protect(result, true).releaseVerified)
        assertFalse(ProductionBillingPolicy.protect(result, false).success)
    }

    @Test
    fun evenCorrectlySignedBazaarReceiptCannotGrantFullVersion() {
        val data = receipt()
        val result = verifier().verify(StoreVendor.BAZAAR, data, sign(data), PRODUCT)
        assertFalse(result.success)
        assertEquals("invalid_receipt", result.status)
    }

    @Test
    fun sameReceiptCanBeVerifiedOfflineWithoutAnyBillingSdk() {
        val data = receipt()
        val signature = sign(data)
        assertTrue(verifier().verify(StoreVendor.MYKET, data, signature, PRODUCT).success)
        // A new verifier instance simulates a new process reading saved proof.
        assertTrue(verifier().verify(StoreVendor.MYKET, data, signature, PRODUCT).success)
    }

    @Test
    fun modifyingSignedDataInvalidatesItsSignature() {
        val data = receipt()
        val modified = data.replace("test-order", "edited-order")
        assertFalse(check(modified, sign(data)).success)
    }

    @Test
    fun signatureFromAnotherPrivateKeyIsRejected() {
        val data = receipt()
        assertFalse(check(data, sign(data, otherKeys)).success)
    }

    @Test
    fun receiptForAnotherProductCannotGrantFullVersion() {
        for (product in listOf("coins_100", "android.test.purchased")) {
            assertFalse(check(receipt { it.put("productId", product) }).success)
        }
    }

    @Test
    fun receiptForAnotherApplicationIsRejectedEvenWithValidSignature() {
        assertFalse(check(receipt { it.put("packageName", "another.app") }).success)
    }

    @Test
    fun cancelledRefundedAndPendingStatesNeverGrantAccess() {
        for (state in listOf(1, 2, 3)) {
            assertFalse(check(receipt { it.put("purchaseState", state) }).success)
        }
    }

    @Test
    fun missingOrMalformedStateNeverDefaultsToPurchased() {
        assertFalse(check(receipt { it.remove("purchaseState") }).success)
        assertFalse(check(receipt { it.put("purchaseState", "0") }).success)
        assertFalse(check(receipt { it.put("purchaseState", true) }).success)
    }

    @Test
    fun blankSandboxAndMissingTokensAreRejected() {
        for (token in listOf("", "  ", "sandbox-token")) {
            assertFalse(check(receipt { it.put("purchaseToken", token) }).success)
        }
        assertFalse(check(receipt { it.remove("purchaseToken") }).success)
    }

    @Test
    fun myketTokenAliasIsAcceptedButStillNeedsValidSignature() {
        val data = receipt {
            it.remove("purchaseToken")
            it.put("token", "signed-myket-token")
        }
        assertEquals("signed-myket-token", check(data).token)
        assertFalse(check(data, "unsigned-placeholder").success)
    }

    @Test
    fun malformedOrMissingSignatureAndJsonFailClosed() {
        val data = receipt()
        assertFalse(check(data, "").success)
        assertFalse(check(data, "not-base64!").success)
        assertFalse(check("not-json").success)
        assertFalse(verifier().verify(StoreVendor.MYKET, null, null, PRODUCT).success)
        assertFalse(verifier().verify(StoreVendor.UNKNOWN, data, sign(data), PRODUCT).success)
    }

    @Test
    fun emptyInventoryIsDifferentFromUnavailableStore() {
        assertEquals("not_owned", BillingOutcome.notOwned().toMap()["status"])
        assertEquals("unavailable", BillingOutcome.failure("offline").toMap()["status"])
        assertEquals("invalid_receipt", BillingOutcome.invalidReceipt().toMap()["status"])
    }
}
