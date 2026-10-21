import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../home/home_screen.dart';
import '../profile/profile_editor.dart';

/// 🏝️ دروازه و صفحه اصلی جزیره فندقی
/// مستقیماً دنیای ۳بعدی جزیره و هاب‌های بازی و یادگیری را نمایش می‌دهد.
class AppGatewayScreen extends StatefulWidget {
  const AppGatewayScreen({
    super.key,
    this.offerProfileSetup = false,
  });

  final bool offerProfileSetup;

  @override
  State<AppGatewayScreen> createState() => _AppGatewayScreenState();
}

class _AppGatewayScreenState extends State<AppGatewayScreen> {
  bool _launchArgumentsHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_launchArgumentsHandled) return;
    _launchArgumentsHandled = true;

    if (widget.offerProfileSetup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _offerProfileSetup();
      });
    }
  }

  Future<void> _offerProfileSetup() async {
    final wantsToSetUp = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslandWorldPalette.paper,
                IslandWorldPalette.skyMist,
                const Color(0xFFF4F9EC),
              ],
            ),
            borderRadius: BorderRadius.circular(IslandWorldMetrics.cardRadius),
            boxShadow: [
              BoxShadow(
                color: IslandWorldPalette.deepOcean.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: IslandWorldPalette.foliage.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 2,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Mascot with glow ──
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        IslandWorldPalette.ocean.withOpacity(0.3),
                        IslandWorldPalette.foliage.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: IgnorePointer(
                    child: Image.asset(
                      IslandWorldAssets.fandoghiWave,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      excludeFromSemantics: true,
                      cacheWidth:
                          (120 * MediaQuery.devicePixelRatioOf(context))
                              .round()
                              .clamp(120, 360)
                              .toInt(),
                      errorBuilder: (_, __, ___) => Image.asset(
                        IslandWorldAssets.fandoghiMain,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'یک سؤال کوچک، با اجازهٔ شما 🌰',
                  textAlign: TextAlign.center,
                  style: AppFonts.kids(
                    color: IslandWorldPalette.deepOcean,
                    fontSize: 26,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'آیا مایل هستید همین حالا نام و مشخصات کودکتان را وارد کنید؟',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    color: IslandWorldPalette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: IslandWorldPalette.sky.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: IslandWorldPalette.softOutline,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: IslandWorldPalette.deepOcean,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'کاملاً اختیاری — اطلاعات فقط روی همین دستگاه می‌ماند.',
                          style: AppFonts.vazirmatn(
                            color: IslandWorldPalette.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: IslandWorldMetrics.primaryActionHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: IslandWorldGradients.honeyButton,
                      borderRadius: BorderRadius.circular(
                        IslandWorldMetrics.buttonRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: IslandWorldPalette.honey.withOpacity(0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      key: const ValueKey('profile_offer_accept'),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(dialogContext, true);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: IslandWorldPalette.ink,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            IslandWorldMetrics.buttonRadius,
                          ),
                        ),
                        textStyle: AppFonts.kids(fontSize: 19),
                      ),
                      icon: const Icon(Icons.child_care_rounded),
                      label: const Text('بله، با کمال میل'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    key: const ValueKey('profile_offer_later'),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(dialogContext, false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: IslandWorldPalette.ink,
                      side: const BorderSide(
                        color: IslandWorldPalette.softOutline,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          IslandWorldMetrics.buttonRadius,
                        ),
                      ),
                      textStyle: AppFonts.kids(fontSize: 18),
                    ),
                    child: const Text('فعلاً نه، متشکرم'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (wantsToSetUp == true && mounted) {
      await showProfileEditor(context);
    }
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
