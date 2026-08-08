import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/island/island_screen.dart';
import '../features/stage_map/stage_map_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/profile/profile_screen.dart';
import 'premium_animations.dart';

/// =======================================================
/// 🚀 PREMIUM ROUTER — سیستم ناوبری حرفه‌ای
/// =======================================================
class PremiumRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/home':
        return _buildPremiumRoute(const HomeScreen());

      case '/onboarding':
        return _buildPremiumRoute(const OnboardingScreen());

      case '/island':
        return _buildPremiumRoute(const LearningIsland(embedded: false));

      case '/map':
        return _buildPremiumRoute(const StageMapScreen(embedded: false));

      case '/shop':
        return _buildPremiumRoute(const ShopScreen(embedded: false));

      case '/profile':
        return _buildPremiumRoute(const ProfileScreen(embedded: false));

      default:
        if (settings.name?.startsWith('/game/') == true) {
          // بعداً به گیم روتر وصل می‌شود
          return _buildPremiumRoute(const HomeScreen());
        }
        return _buildPremiumRoute(const HomeScreen());
    }
  }

  static PageRouteBuilder _buildPremiumRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionDuration: PremiumAnimations.normal,
      reverseTransitionDuration: PremiumAnimations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final scale = Tween<double>(begin: 0.94, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        final slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
    );
  }
}