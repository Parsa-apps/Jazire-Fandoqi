import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/mascot/fandoghi_baby_shy.webp',
                width: 112,
                height: 112,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                'یک سؤال کوچک، با اجازهٔ شما 🌰',
                textAlign: TextAlign.center,
                style: AppFonts.kids(
                  color: const Color(0xFF4A2875),
                  fontSize: 27,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'آیا مایل هستید همین حالا نام و مشخصات کودکتان را وارد کنید؟',
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(
                  color: const Color(0xFF392F43),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'این کار کاملاً اختیاری است و اطلاعات فقط روی همین دستگاه نگهداری می‌شود.',
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(
                  color: const Color(0xFF776A80),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  key: const ValueKey('profile_offer_accept'),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7048C8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: AppFonts.kids(fontSize: 19),
                  ),
                  icon: const Icon(Icons.child_care_rounded),
                  label: const Text('بله، با کمال میل'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  key: const ValueKey('profile_offer_later'),
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF604B70),
                    side: const BorderSide(color: Color(0xFFC9B9D8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
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
    );

    if (wantsToSetUp == true && mounted) {
      await showProfileEditor(context);
    }
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
