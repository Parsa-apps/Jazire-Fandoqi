#!/usr/bin/env python3
"""Gate a production store APK (Bazaar or Myket) using aapt/apksigner output.

The caller must first run apksigner and VerifyApkSigner.java successfully. The
latter emits a stable report from the verifier's certificate API. This gate
checks its signer against the configured release key, rejects debug/test-only
APKs and checks package, version and the selected store's billing permission
(never the competing market's) before publication.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


class ProductionApkError(ValueError):
    pass


BAZAAR_PERMISSION = "com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR"
MYKET_PERMISSION = "ir.mservices.market.BILLING"


def verify(*, pubspec: str, badging: str, manifest: str, signature: str,
           expected_signer: str, store: str = "myket") -> dict[str, str]:
    if store not in ("bazaar", "myket"):
        raise ProductionApkError(f"unknown store {store!r}")
    version = re.search(r"^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$", pubspec, re.M)
    if not version:
        raise ProductionApkError("pubspec must contain an explicit version and build number")
    package = re.search(
        r"^package: name='([^']+)' versionCode='([^']+)' versionName='([^']+)'",
        badging, re.M,
    )
    if not package or package.group(1) != "com.parsaapps.amoozesh_fandoghi":
        raise ProductionApkError("unexpected APK package")
    if (package.group(3), package.group(2)) != version.groups():
        raise ProductionApkError("APK version/build does not match pubspec")
    if "application-debuggable" in badging:
        raise ProductionApkError("debuggable APK cannot be distributed")
    for flag in ("debuggable", "testOnly"):
        declarations = re.findall(
            rf"A:\s+android:{flag}\([^)]*\)=\s*(?:\(type 0x12\))?(\S+)",
            manifest,
        )
        if any(value.lower() not in ("false", "0x0", "0x00000000")
               for value in declarations):
            raise ProductionApkError(f"APK is marked {flag}")
    required_permission = (
        BAZAAR_PERMISSION if store == "bazaar" else MYKET_PERMISSION
    )
    forbidden_permission = (
        MYKET_PERMISSION if store == "bazaar" else BAZAAR_PERMISSION
    )
    if f"uses-permission: name='{required_permission}'" not in badging:
        raise ProductionApkError(f"{store} billing permission is missing")
    if forbidden_permission in badging:
        raise ProductionApkError(
            f"{store} APK must not contain another market's billing permission"
        )
    expected = expected_signer.strip().lower()
    signers = re.findall(r"^Signer #\d+ certificate SHA-256 digest:\s*([0-9a-fA-F]+)\s*$",
                         signature, re.M)
    if not re.fullmatch(r"[0-9a-f]{64}", expected) or len(signers) != 1:
        raise ProductionApkError("exactly one configured release signer is required")
    if signers[0].lower() != expected:
        raise ProductionApkError("APK certificate does not match the release keystore")
    if re.search(r"\bCN=Android Debug(?:,|$)", signature, re.I | re.M):
        raise ProductionApkError("Android debug certificate cannot sign a production APK")
    return {
        "package": package.group(1), "version": version.group(1),
        "version_code": version.group(2), "store": store,
        "certificate_sha256": expected,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("pubspec", "badging", "manifest", "signature", "expected-signer"):
        parser.add_argument(f"--{name}", required=True, type=Path)
    parser.add_argument("--store", choices=("bazaar", "myket"), default="myket")
    args = parser.parse_args()
    try:
        identity = verify(**{
            name: getattr(args, name).read_text(encoding="utf-8")
            for name in ("pubspec", "badging", "manifest", "signature", "expected_signer")
        }, store=args.store)
    except (ProductionApkError, OSError) as error:
        print(f"::error::Production APK rejected: {error}", file=sys.stderr)
        return 1
    print(f"::notice::Production {identity['store'].title()} APK verified: "
          f"{identity['version']}+{identity['version_code']}; "
          "release certificate matched; debuggable=false; testOnly=false")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
