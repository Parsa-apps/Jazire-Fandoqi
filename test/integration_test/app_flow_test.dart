import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:jazireh_fandoghi/features/gateway/app_gateway_screen.dart';
import 'package:jazireh_fandoghi/features/onboarding/onboarding_screen.dart';
import 'package:jazireh_fandoghi/features/splash/splash_screen.dart';
import 'package:jazireh_fandoghi/main.dart' as app;

/// تست راه‌اندازی برنامه و عبور از اسپلش روی دستگاه/شبیه‌ساز.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts and survives the splash transition', (tester) async {
    await app.main();
    await tester.pump();

    expect(find.byType(app.JazirehFandoghiApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    // SplashScreen intentionally owns repeating premium animations, so
    // pumpAndSettle can never complete. Advance its navigation timer and route
    // transition by bounded durations instead.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    final reachedStartupDestination =
        find.byType(OnboardingScreen).evaluate().isNotEmpty ||
            find.byType(AppGatewayScreen).evaluate().isNotEmpty;
    expect(reachedStartupDestination, isTrue);
    expect(tester.takeException(), isNull);
  });
}
