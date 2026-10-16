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

    private fun receipt() = BillingOutcome(
        success = true, token = "native-test-token", status = "verified",
        productId = "full_version", store = "myket", purchaseState = 0,
        signedData = "native-verified-data", signature = "native-verified-signature",
    )

    @Test
    fun onlyOfficialMyketReleaseCanUseBilling() {
        assertTrue(BuildIdentity().allowed())
        assertTrue(BuildIdentity(actual = "A".repeat(64)).allowed())
    }

    @Test
    fun debugAndProfileBuildsAreAlwaysDenied() {
        assertFalse(BuildIdentity(buildType = "debug").allowed())
        assertFalse(BuildIdentity(buildType = "profile").allowed())
        assertFalse(BuildIdentity(debuggable = true).allowed())
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
    fun anotherStoreOrUnknownBuildChannelIsDenied() {
        for (channel in listOf("bazaar", "unknown", "", "MYKET")) {
            assertFalse(BuildIdentity(channel = channel).allowed())
        }
    }

    @Test
    fun missingMyketPublicKeyIsDenied() {
        assertFalse(BuildIdentity(keyConfigured = false).allowed())
    }

    @Test
    fun configuredMyketKeyIsAnActualRsaPublicKey() {
        val encoded = Base64.getDecoder().decode(BuildConfig.MYKET_RSA_PUBLIC_KEY)
        val key = KeyFactory.getInstance("RSA")
            .generatePublic(X509EncodedKeySpec(encoded)) as RSAPublicKey
        assertTrue(key.modulus.bitLength() >= 1024)
    }

    @Test
    fun verifiedReceiptInAnUntrustedBuildStillCannotUnlock() {
        val blocked = ProductionBillingPolicy.protect(receipt(), allowed = false)
        assertFalse(blocked.success)
        assertFalse(blocked.releaseVerified)
        assertEquals("untrusted_build", blocked.status)
    }

    @Test
    fun bridgeAttestsOnlyVerifiedMyketReceiptInOfficialRelease() {
        val approved = ProductionBillingPolicy.protect(receipt(), allowed = true)
        assertTrue(approved.success)
        assertTrue(approved.releaseVerified)
        assertEquals(true, approved.toMap()["releaseVerified"])
        val bazaar = ProductionBillingPolicy.protect(receipt().copy(store = "bazaar"), true)
        assertFalse(bazaar.success)
        assertFalse(bazaar.releaseVerified)
    }

    @Test
    fun receiptWithMissingSignedFieldsCannotBeAttested() {
        for (incomplete in listOf(
            receipt().copy(signature = null),
            receipt().copy(signedData = null),
            receipt().copy(token = ""),
            receipt().copy(purchaseState = 1),
        )) {
            assertFalse(ProductionBillingPolicy.protect(incomplete, true).success)
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
            BillingOutcome.success(message = "consumed"), true,
        )
        assertTrue(consumed.success)
        assertFalse(consumed.releaseVerified)
        assertEquals("completed", consumed.status)
    }
}
