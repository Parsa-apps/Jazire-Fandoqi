import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/game_data.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🌐 دروازهٔ شفاف ورود به کارتون‌کده — قانون Offline-First
///
/// «کارتون‌کده» تنها بخش آنلاین اپ است. طبق قانون Offline-First، پیش از
/// ورود به بخش آنلاین یک اعلان شفاف نمایش داده می‌شود تا کودک و والد
/// بدانند: این بخش اینترنت می‌خواهد، پخش فقط از آپارات است و «بازگشت
/// به جزیرهٔ آفلاین» همیشه یک لمس دور است.
///
/// ریتم اعلان:
///  - نخستین ورود (یک‌بار برای همیشه): اطلاعیهٔ کامل والدین — همان
///    شفاف‌سازی نسخهٔ ۶.۲.۱ که داخل کارتون‌کده بود، حالا «پیش از ورود».
///  - ورودهای بعدی در همان اجرای برنامه: اعلان کوتاهِ یک‌خطی.
///  - اجرای تازهٔ برنامه: اعلان دوباره فعال می‌شود (بدون ذخیرهٔ دائمی).
///
/// تا تأیید نشود هیچ محتوای آنلاین ساخته نمی‌شود؛ پیش‌بارگیری پوسترها
/// در `CartoonHubScreen` فقط بعد از تأیید شروع می‌شود.
/// ═══════════════════════════════════════════════════════════════
class OnlineCartoonGate extends StatefulWidget {
  const OnlineCartoonGate({super.key, required this.child});

  /// صفحه‌ای که فقط بعد از تأیید ساخته می‌شود (در تست، جایگزین سبک).
  final Widget child;

  /// برای تست‌ها — شبیه‌سازی اجرای تازهٔ برنامه (اعلان دوباره فعال شود).
  static void resetForTesting() => _acknowledgedThisRun = false;

  /// آیا در این اجرای برنامه، اعلان آنلاین تأیید شده است؟
  static bool get acknowledgedThisRun => _acknowledgedThisRun;

  static bool _acknowledgedThisRun = false;

  @override
  State<OnlineCartoonGate> createState() => _OnlineCartoonGateState();
}

class _OnlineCartoonGateState extends State<OnlineCartoonGate> {
  static const String _disclosureFlag = 'cartoon_parent_disclosure_shown';

  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    if (OnlineCartoonGate.acknowledgedThisRun) {
      _resolved = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _askForConsent();
    });
  }

  Future<void> _askForConsent() async {
    final firstEver = !(GameData.getBool(_disclosureFlag) ?? false);
    final wantsToEnter =
        firstEver ? await _showParentDisclosure() : await _showShortNotice();
    if (!mounted) return;
    if (!wantsToEnter) {
      // بازگشت آسان: بدون تأیید، هیچ محتوای آنلاین باز نمی‌شود.
      Navigator.of(context).pop();
      return;
    }
    OnlineCartoonGate._acknowledgedThisRun = true;
    if (firstEver) {
      // پرچم دائمی فقط یک‌بار در عمر برنامه ست می‌شود؛ اعلان‌های بعدی
      // کوتاه‌اند و در هر اجرای تازه دوباره نشان داده می‌شوند.
      await GameData.setBool(_disclosureFlag, true);
    }
    if (mounted) setState(() => _resolved = true);
  }

  /// نخستین ورود: اطلاعیهٔ کامل والدین (شفاف‌سازی نسخهٔ ۶.۲.۱).
  Future<bool> _showParentDisclosure() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFFDF7),
        title: Row(
          children: [
            const Text('👨‍👩‍👧', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'اطلاعیه به والدین عزیز — پیش از ورود',
                style: AppFonts.kids(
                  color: const Color(0xFF3B2B52),
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _noticeRow(Icons.wifi_rounded, const Color(0xFF2196F3),
                'بخش «کارتون‌کده» تنها بخش آنلاین اپ است و برای پخش به اینترنت نیاز دارد.'),
            const SizedBox(height: 10),
            _noticeRow(Icons.verified_rounded, const Color(0xFF43A047),
                'ویدیوها فقط از سرویس ویدیوی ایرانی آپارات (aparat.com) و صرفاً از طریق هش‌های از پیش تأییدشده و فهرست سفید پخش می‌شوند.'),
            const SizedBox(height: 10),
            _noticeRow(Icons.shield_rounded, const Color(0xFFEF6C00),
                'هیچ‌گونه جستجوی آزاد، تبلیغ، لینک خروجی به سایت‌های ثالث، یا ارسال اطلاعات کودک به سرور وجود ندارد.'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(dialogContext).pop(false);
            },
            child: Text(
              'بازگشت به جزیره 🏝️',
              style: AppFonts.kids(
                color: const Color(0xFF546E7A),
                fontSize: 15,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(dialogContext).pop(true);
            },
            icon: const Icon(Icons.movie_rounded, size: 20),
            label: Text(
              'ورود به کارتون‌کده',
              style: AppFonts.kids(
                color: const Color(0xFFFFFDF7),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  /// ورودهای بعدی در همان اجرا: اعلان کوتاهِ شفاف.
  Future<bool> _showShortNotice() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFFDF7),
        title: Row(
          children: [
            const Text('🌐', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'کارتون‌کده بخش آنلاین بازی است',
                style: AppFonts.kids(
                  color: const Color(0xFF3B2B52),
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _noticeRow(Icons.wifi_rounded, const Color(0xFF2196F3),
                'برای تماشای کارتون‌ها به اینترنت نیاز است؛ تمام جزیرهٔ فندقی همیشه آفلاین می‌ماند.'),
            const SizedBox(height: 10),
            _noticeRow(Icons.verified_rounded, const Color(0xFF43A047),
                'پخش فقط از آپارات (aparat.com) با فهرست سفید تأییدشده انجام می‌شود؛ بدون تبلیغ و بدون ارسال اطلاعات کودک.'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(dialogContext).pop(false);
            },
            child: Text(
              'بازگشت به جزیره 🏝️',
              style: AppFonts.kids(
                color: const Color(0xFF546E7A),
                fontSize: 15,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(dialogContext).pop(true);
            },
            icon: const Icon(Icons.movie_rounded, size: 20),
            label: Text(
              'ورود به کارتون‌کده',
              style: AppFonts.kids(
                color: const Color(0xFFFFFDF7),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Widget _noticeRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4B3565),
              fontSize: 12,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved) {
      // صفحهٔ انتظار خنثی و بی‌حرکت: پیش از تأیید، هیچ محتوای آنلاین
      // ساخته یا بارگیری نمی‌شود (قانون Offline-First).
      return const Scaffold(
        backgroundColor: Color(0xFFFFFDF7),
        body: SizedBox.shrink(),
      );
    }
    return widget.child;
  }
}
