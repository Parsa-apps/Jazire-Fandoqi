package com.parsaapps.amoozesh_fandoghi

/**
 * سیاست واحد انتشار: هیچ APK دیباگ/تست‌تنها/بدون امضای رسمی و هیچ رسید
 * فروشگاهِ دیگر نمی‌تواند دسترسی نسخهٔ کامل بسازد.
 *
 * هر flavor فقط کانال خودش را مجاز می‌داند (`bazaar` یا `myket`) و کلید
 * عمومی همان فروشگاه باید پیکربندی شده باشد. نتیجهٔ SDK هم باید دقیقاً
 * متعلق به همان کانال باشد؛ رسید بازار در بیلد مایکت (و برعکس) رد می‌شود.
 */
internal object ProductionBillingPolicy {
    const val FULL_VERSION_PRODUCT_ID = "full_version"
    private val supportedChannels = setOf("bazaar", "myket")
    private val certificateDigest = Regex("[0-9a-fA-F]{64}")

    fun allowsBilling(
        channel: String,
        buildType: String,
        debuggable: Boolean,
        testOnly: Boolean,
        expectedSigner: String,
        actualSigner: String,
        storeKeyConfigured: Boolean,
    ): Boolean = channel in supportedChannels && buildType == "release" &&
        !debuggable && !testOnly && storeKeyConfigured &&
        certificateDigest.matches(expectedSigner) &&
        certificateDigest.matches(actualSigner) &&
        expectedSigner.equals(actualSigner, ignoreCase = true)

    fun canConsume(productId: String): Boolean =
        productId.isNotBlank() && productId != FULL_VERSION_PRODUCT_ID

    /** Only the native bridge can attest the installed release. Receipt RSA
     * verification alone (e.g. in an unsigned QA build) is not an entitlement.
     */
    fun protect(
        outcome: BillingOutcome,
        allowed: Boolean,
        expectedStore: String,
    ): BillingOutcome {
        if (!allowed) return BillingOutcome.untrustedBuild()
        if (outcome.success && outcome.status == "verified") {
            if (expectedStore !in supportedChannels ||
                outcome.store != expectedStore ||
                outcome.purchaseState != 0 ||
                outcome.productId.isNullOrBlank() ||
                outcome.token.isNullOrBlank() ||
                outcome.signedData.isNullOrBlank() ||
                outcome.signature.isNullOrBlank()
            ) {
                return BillingOutcome.invalidReceipt()
            }
            return outcome.copy(releaseVerified = true)
        }
        return outcome.copy(releaseVerified = false)
    }
}
