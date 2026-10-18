package com.parsaapps.amoozesh_fandoghi

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.security.KeyFactory
import java.security.interfaces.RSAPublicKey
import java.security.spec.X509EncodedKeySpec
import java.util.Base64

class ProductionBillingPolicyTest {
    private data class BuildIdentity(
        val channel: String = "myket",
        val buildType: String = "release",
        val debuggable: Boolean = false,
        val testOnly: Boolean = false,
        val expected: String = "a".repeat(64),
        val actual: String = "a".repeat(64),
        val keyConfigured: Boolean = true,
    ) {
        fun allowed() = ProductionBillingPolicy.allowsBilling(
            channel, buildType, debuggable, testOnly, expected, actual, keyConfigured,
        )
    }

    private fun receipt(store: String = "myket") = BillingOutcome(
        success = true, token = "native-test-token", status = "verified",
        productId = "full_version", store = store, purchaseState = 0,
        signedData = "native-verified-data", signature = "native-verified-signature",
    )

    @Test
    fun eachOfficialStoreFlavorCanUseItsOwnBilling() {
        assertTrue(BuildIdentity().allowed())
        assertTrue(BuildIdentity(channel = "bazaar").allowed())
        assertTrue(BuildIdentity(actual = "A".repeat(64)).allowed())
    }

    @Test
    fun debugAndProfileBuildsAreAlwaysDenied() {
        for (channel in listOf("bazaar", "myket")) {
            assertFalse(BuildIdentity(channel = channel, buildType = "debug").allowed())
            assertFalse(BuildIdentity(channel = channel, buildType = "profile").allowed())
            assertFalse(BuildIdentity(channel = channel, debuggable = true).allowed())
        }
    }

    @Test
    fun testOnlyApkIsDeniedEvenWithReleaseCertificate() {
        assertFalse(BuildIdentity(testOnly = true).allowed())
    }

    @Test
    fun missingOrMalformedSignerNeverFallsBackToDebugSigning() {
        assertFalse(BuildIdentity(expected = "").allowed())
        assertFalse(BuildIdentity(actual = "").allowed())
        assertFalse(BuildIdentity(expected = "not-a-certificate").allowed())
        assertFalse(BuildIdentity(expected = "a".repeat(63)).allowed())
    }

    @Test
    fun signerMismatchIsDenied() {
        assertFalse(BuildIdentity(actual = "b".repeat(64)).allowed())
    }

    @Test
    fun unknownOrMalformedBuildChannelIsDenied() {
        for (channel in listOf("unknown", "", "MYKET", "BAZAAR", "google", "bazaar ")) {
            assertFalse(BuildIdentity(channel = channel).allowed())
        }
    }

    @Test
    fun missingStorePublicKeyIsDenied() {
        for (channel in listOf("bazaar", "myket")) {
            assertFalse(BuildIdentity(channel = channel, keyConfigured = false).allowed())
        }
    }

    @Test
    fun configuredStoreKeyIsAnActualRsaPublicKey() {
        // Each flavor embeds only its own store's public key in this field.
        val encoded = Base64.getDecoder().decode(BuildConfig.STORE_RSA_PUBLIC_KEY)
        val key = KeyFactory.getInstance("RSA")
            .generatePublic(X509EncodedKeySpec(encoded)) as RSAPublicKey
        assertTrue(key.modulus.bitLength() >= 1024)
    }

    @Test
    fun verifiedReceiptInAnUntrustedBuildStillCannotUnlock() {
        for (store in listOf("bazaar", "myket")) {
            val blocked = ProductionBillingPolicy.protect(
                receipt(store), allowed = false, expectedStore = store,
            )
            assertFalse(blocked.success)
            assertFalse(blocked.releaseVerified)
            assertEquals("untrusted_build", blocked.status)
        }
    }

    @Test
    fun bridgeAttestsOnlyVerifiedReceiptOfTheSameStore() {
        val myket = ProductionBillingPolicy.protect(receipt(), true, "myket")
        assertTrue(myket.success)
        assertTrue(myket.releaseVerified)
        assertEquals(true, myket.toMap()["releaseVerified"])

        val bazaar = ProductionBillingPolicy.protect(receipt("bazaar"), true, "bazaar")
        assertTrue(bazaar.success)
        assertTrue(bazaar.releaseVerified)

        // Cross-store replay is never an entitlement.
        for (outcome in listOf(
            ProductionBillingPolicy.protect(receipt("bazaar"), true, "myket"),
            ProductionBillingPolicy.protect(receipt("myket"), true, "bazaar"),
        )) {
            assertFalse(outcome.success)
            assertFalse(outcome.releaseVerified)
            assertEquals("invalid_receipt", outcome.status)
        }
    }

    @Test
    fun receiptWithMissingSignedFieldsCannotBeAttested() {
        for (incomplete in listOf(
            receipt().copy(signature = null),
            receipt().copy(signedData = null),
            receipt().copy(token = ""),
            receipt().copy(purchaseState = 1),
            receipt().copy(store = ""),
        )) {
            assertFalse(ProductionBillingPolicy.protect(incomplete, true, "myket").success)
        }
    }

    @Test
    fun permanentFullVersionIsNeverConsumed() {
        assertFalse(ProductionBillingPolicy.canConsume("full_version"))
        assertFalse(ProductionBillingPolicy.canConsume(""))
        assertTrue(ProductionBillingPolicy.canConsume("coins_100"))
    }

    @Test
    fun consumptionCompletionIsNotAFullVersionReceipt() {
        val consumed = ProductionBillingPolicy.protect(
            BillingOutcome.success(message = "consumed"), true, "myket",
        )
        assertTrue(consumed.success)
        assertFalse(consumed.releaseVerified)
        assertEquals("completed", consumed.status)
    }
}
