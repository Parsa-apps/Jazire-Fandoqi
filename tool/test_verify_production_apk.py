"""Regression checks for accidental publication of QA/debug/wrong-store APKs."""
import unittest

from verify_production_apk import ProductionApkError, verify


class ProductionApkVerificationTest(unittest.TestCase):
    def inputs(self):
        return dict(
            pubspec="version: 7.5.4+26\n",
            badging=("package: name='com.parsaapps.amoozesh_fandoghi' "
                     "versionCode='26' versionName='7.5.4'\n"
                     "uses-permission: name='ir.mservices.market.BILLING'\n"),
            manifest="A: android:debuggable(0x0101000f)=(type 0x12)0x0\n",
            signature=("Signer #1 certificate DN: CN=Fandoghi\n"
                       "Signer #1 certificate SHA-256 digest: " + "a" * 64 + "\n"),
            expected_signer="a" * 64,
        )

    def rejected(self, **changes):
        values = {**self.inputs(), **changes}
        with self.assertRaises(ProductionApkError):
            verify(**values)

    def test_official_release_is_accepted(self):
        self.assertEqual(verify(**self.inputs())["store"], "myket")

    def test_debuggable_apk_is_rejected(self):
        self.rejected(badging=self.inputs()["badging"] + "application-debuggable\n")
        self.rejected(manifest="A: android:debuggable(0x0101000f)=(type 0x12)0xffffffff")

    def test_test_only_apk_is_rejected(self):
        self.rejected(manifest="A: android:testOnly(0x01010272)=(type 0x12)0xffffffff")
        self.rejected(manifest="A: android:testOnly(0x01010272)=true")

    def test_explicit_false_test_only_flag_is_safe(self):
        values = self.inputs()
        values["manifest"] += "A: android:testOnly(0x01010272)=(type 0x12)0x0\n"
        self.assertEqual(verify(**values)["version_code"], "26")

    def test_missing_or_wrong_release_signer_is_rejected(self):
        self.rejected(expected_signer="")
        self.rejected(expected_signer="b" * 64)
        self.rejected(signature="no certificates")

    def test_unknown_sdk_console_format_is_not_treated_as_a_signer(self):
        # Only the API-backed canonical report is consumed by this gate.
        self.rejected(signature="APK signature verified; no canonical certificate report")

    def test_android_debug_key_is_rejected_even_if_digest_matches(self):
        self.rejected(signature=self.inputs()["signature"].replace(
            "CN=Fandoghi", "CN=Android Debug,O=Android,C=US"))

    def test_multiple_signers_are_rejected(self):
        self.rejected(signature=self.inputs()["signature"] +
                      "Signer #2 certificate SHA-256 digest: " + "a" * 64)

    def test_wrong_package_or_old_version_is_rejected(self):
        self.rejected(badging=self.inputs()["badging"].replace("versionCode='26'", "versionCode='25'"))
        self.rejected(badging=self.inputs()["badging"].replace("versionName='7.5.4'", "versionName='7.5.3'"))
        self.rejected(badging=self.inputs()["badging"].replace("amoozesh_fandoghi", "another_app"))

    def test_wrong_store_or_missing_myket_permission_is_rejected(self):
        self.rejected(badging=self.inputs()["badging"].replace("ir.mservices.market.BILLING", "other.BILLING"))
        self.rejected(badging=self.inputs()["badging"] +
                      "uses-permission: name='com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR'\n")


if __name__ == "__main__":
    unittest.main()
