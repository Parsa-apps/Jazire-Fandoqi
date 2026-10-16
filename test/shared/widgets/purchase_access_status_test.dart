import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/monetization.dart';
import 'package:jazireh_fandoghi/shared/widgets/purchase_access_status.dart';

import '../../support/paywall_test_store.dart';

void main() {
  late PaywallTestStore store;
  setUp(() => store = PaywallTestStore()..install());
  tearDown(() => store.dispose());

  const host = MaterialApp(
    home: Scaffold(body: Center(child: PurchaseAccessStatus())),
  );

  testWidgets('support status follows verified purchase and confirmed revocation',
      (tester) async {
    await tester.pumpWidget(host);
    await Monetization.hasFullVersion();
    await tester.pump();
    expect(find.textContaining('نسخهٔ رایگان'), findsOneWidget);

    store.purchaseResponse = PaywallTestStore.verifiedPurchase;
    expect(await Monetization.purchaseFullVersion(), isTrue);
    await tester.pump();
    expect(find.textContaining('رسید امضاشدهٔ مایکت تأیید شد'), findsOneWidget);
    expect(find.textContaining('verified-test-receipt'), findsNothing);
    expect(find.textContaining('verified-test-order'), findsNothing);
    expect(find.textContaining(PaywallTestStore.signature), findsNothing);

    store.restoreResponse = PaywallTestStore.notOwned;
    expect(await Monetization.hasFullVersion(), isFalse);
    await tester.pump();
    expect(find.textContaining('نسخهٔ رایگان'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unverified legacy ownership requests restore without exposing data',
      (tester) async {
    store.values.addAll({
      'entitlement.granted': 'true',
      'entitlement.receipt_token': 'do-not-display-this-old-token',
    });
    store.offline = true;
    await tester.pumpWidget(host);
    expect(await Monetization.hasFullVersion(), isFalse);
    await tester.pump();
    expect(find.textContaining('مجوز قبلی قابل تأیید نیست'), findsOneWidget);
    expect(find.textContaining('do-not-display-this-old-token'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
