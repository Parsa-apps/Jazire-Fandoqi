import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';

/// 🚫 تمام‌صفحه‌ای که وقتی APK نصب‌شده نسخهٔ رسمی نیست نمایش داده می‌شود
/// (بستهٔ repackage/دستکاری‌شده، بیلد debug به‌جای release، یا ماژول
/// امنیتی حذف‌شده). این صفحه عمداً دکمهٔ «ادامه بده» ندارد — هدف، محافظت
/// از کودک در برابر نرم‌افزار مخرب منتشرشده با نام این اپ است.
class TamperBlockScreen extends StatelessWidget {
  const TamperBlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 20),
                Text(
                  'این نسخه از برنامه قابل تأیید نیست',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'برنامهٔ نصب‌شده با نسخهٔ رسمی «جزیره فندقی» تفاوت دارد و ممکن است دستکاری شده باشد. '
                  'برای امنیت کودک، اجرای برنامه متوقف شد.\n\n'
                  'لطفاً نسخهٔ رسمی را فقط از فروشگاه‌های معتبر نصب کنید.',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    fontSize: 15,
                    height: 1.7,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C43D9),
                  ),
                  onPressed: () => SystemNavigator.pop(),
                  icon: const Icon(Icons.exit_to_app_rounded),
                  label: const Text('خروج از برنامه'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
