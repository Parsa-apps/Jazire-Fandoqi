package com.parsaapps.amoozesh_fandoghi

/** No debug, profile, test-only, unsigned or other-store build can grant access. */
internal object ProductionBillingPolicy {
    const val FULL_VERSION_PRODUCT_ID = "full_version"
    private val certificateDigest = Regex("[0-9a-fA-F]{64}")

    fun allowsBilling(
        channel: String,
        buildType: String,
        debuggable: Boolean,
        testOnly: Boolean,
        expectedSigner: String,
        actualSigner: String,
        myketKeyConfigured: Boolean,
    ): Boolean = channel == "myket" && buildType == "release" &&
        !debuggable && !testOnly && myketKeyConfigured &&
        certificateDigest.matches(expectedSigner) &&
        certificateDigest.matches(actualSigner) &&
        expectedSigner.equals(actualSigner, ignoreCase = true)

    fun canConsume(productId: String): Boolean =
        productId.isNotBlank() && productId != FULL_VERSION_PRODUCT_ID

    /** Only the native bridge can attest the installed release. Receipt RSA
     * verification alone (e.g. in an unsigned QA build) is not an entitlement.
     */
    fun protect(outcome: BillingOutcome, allowed: Boolean): BillingOutcome {
        if (!allowed) return BillingOutcome.untrustedBuild()
        if (outcome.success && outcome.status == "verified") {
            if (outcome.store != "myket" || outcome.purchaseState != 0 ||
                outcome.productId.isNullOrBlank() || outcome.token.isNullOrBlank() ||
                outcome.signedData.isNullOrBlank() || outcome.signature.isNullOrBlank()
            ) {
                return BillingOutcome.invalidReceipt()
            }
            return outcome.copy(releaseVerified = true)
        }
        return outcome.copy(releaseVerified = false)
    }
}
