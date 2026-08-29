import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/store_listing.dart';
import 'package:jazireh_fandoghi/core/store_vendor.dart';

void main() {
  test('Myket listing uses the official details intent and Myket name', () {
    expect(StoreListing.displayName(StoreVendor.myket), 'مایکت');
    expect(
      StoreListing.buttonLabel(StoreVendor.myket),
      'ورود به صفحه برنامه در مایکت',
    );
    expect(
      StoreListing.detailsDeepLink(StoreVendor.myket),
      'myket://details?id=com.parsaapps.amoozesh_fandoghi',
    );
    expect(
      StoreListing.detailsWebUrl(StoreVendor.myket),
      'https://myket.ir/app/com.parsaapps.amoozesh_fandoghi',
    );
    expect(StoreListing.hasStorePage(StoreVendor.myket), isTrue);
  });

  test('Bazaar listing points at Cafe Bazaar, never the publisher site', () {
    expect(StoreListing.displayName(StoreVendor.bazaar), 'کافه‌بازار');
    expect(
      StoreListing.detailsDeepLink(StoreVendor.bazaar),
      'bazaar://details?id=com.parsaapps.amoozesh_fandoghi',
    );
    expect(
      StoreListing.detailsWebUrl(StoreVendor.bazaar),
      contains('cafebazaar.ir/app/'),
    );
    expect(StoreListing.detailsWebUrl(StoreVendor.bazaar), isNot(contains('github.io')));
    expect(StoreListing.detailsWebUrl(StoreVendor.myket), isNot(contains('github.io')));
  });

  test('unknown vendor has no outbound store or website page', () {
    expect(StoreListing.hasStorePage(StoreVendor.unknown), isFalse);
    expect(StoreListing.detailsDeepLink(StoreVendor.unknown), isEmpty);
    expect(StoreListing.detailsWebUrl(StoreVendor.unknown), isEmpty);
    expect(StoreListing.buttonLabel(StoreVendor.unknown), isEmpty);
  });
}
