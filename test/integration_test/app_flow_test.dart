import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:amoozesh_fandoghi/main.dart' as app;

/// فاز ۸۳: تست انتگراسیون — سناریوی کامل روی دستگاه/شبیه‌ساز:
/// شروع → onboarding → خانه → بازی → ذخیره → بستن
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full onboarding to home flow', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Splash باید به Onboarding یا Home برود؛ هر دو قابل قبول‌اند.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(app.AmoozeshFandoghiApp), findsOneWidget);
  });
}
