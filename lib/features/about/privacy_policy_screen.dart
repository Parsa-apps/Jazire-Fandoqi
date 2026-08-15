import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import '../../core/app_legal.dart';

/// In-app privacy summary so parents do not need a network connection to read
/// the policy. The same information is also kept in PRIVACY_POLICY_FA.md for
/// the CafeBazaar listing.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سیاست حریم خصوصی',
          style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _section(
            'سازنده و مسئول پشتیبانی',
            'نام سازنده/ناشر: ${AppLegal.developerName}\n'
            'ایمیل: ${AppLegal.supportEmail}\n'
            'تلگرام: ${AppLegal.telegramHandle}',
          ),
          _section(
            'درباره برنامه',
            'جزیره فندقی یک برنامه آموزشی آفلاین برای کودکان است. بازی‌ها بدون ساخت حساب کاربری و بدون نیاز به اینترنت کار می‌کنند.',
          ),
          _section(
            'اطلاعات ذخیره‌شده',
            'لقب اختیاری، بازه سنی انتخاب‌شده، پیشرفت بازی، امتیاز، سکه، ستاره، مدال‌ها و تنظیمات صدا و زمان فقط روی همین دستگاه ذخیره می‌شوند.',
          ),
          _section(
            'اطلاعاتی که جمع نمی‌شود',
            'برنامه به نام واقعی، شماره تلفن، ایمیل کودک، مخاطبین، موقعیت مکانی، دوربین، میکروفون، عکس‌های شخصی، تبلیغات، ردیابی یا analytics نیاز ندارد. نقاشی‌ها و اطلاعات کودک به اینترنت ارسال نمی‌شوند.',
          ),
          _section(
            'دسترسی اینترنت — شفاف‌سازی کامل',
            'بیشتر بخش‌های اپ (آموزش، بازی‌ها، داستان‌ها، لالایی‌ها، نقاشی، رنگ‌ها، اشکال، فلش‌کارت‌ها و پنل والدین) کاملاً آفلاین هستند. '
                'تنها بخشی که به اینترنت نیاز دارد «کارتون‌کده» است که ویدیوها را فقط از سرویس معتبر ایرانی آپارات (aparat.com) و فقط از فهرست سفید (whitelist) هش‌های از پیش تأییدشده پخش می‌کند. '
                'هیچ جستجوی آزاد، هیچ تبلیغ، هیچ ردیابی/analytics و هیچ جمع‌آوری اطلاعات کودک در اپ وجود ندارد. '
                'لینک‌های خروجی (تلگرام، پرداخت، اشتراک‌گذاری) فقط در پنل والدین و پشت قفل پین قرار دارند.',
          ),
          _section(
            'پرداخت',
            'پرداخت واقعی فقط از مسیر رسمی فروشگاهی که برنامه از آن نصب شده انجام می‌شود. اطلاعات کارت بانکی در اختیار برنامه نیست. دسترسی ویژه فقط پس از تأیید رسید معتبر استور فعال می‌شود.',
          ),
          _section(
            'کنترل والدین',
            'ورود به پنل والدین با یک سؤال ساده محافظت می‌شود. والد می‌تواند بازخوردها و سقف زمان بازی روزانه را کنترل کند. این سازوکار جایگزین نظارت والدین نیست.',
          ),
          _section(
            'حذف اطلاعات و تماس',
            'برای حذف اطلاعات محلی، داده‌های برنامه را از تنظیمات Android پاک یا برنامه را حذف کنید. برای گزارش خطا یا درخواست پشتیبانی با ایمیل یا تلگرام بالا تماس بگیرید و اطلاعات حساس کودک یا بانکی ارسال نکنید.',
          ),
          const SizedBox(height: 8),
          const Text(
            'آخرین به‌روزرسانی: ۱۴ اوت ۲۰۲۶ — به‌روزرسانی شفاف‌سازی دسترسی اینترنت',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppFonts.vazirmatn(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(height: 1.7)),
          ],
        ),
      ),
    );
  }
}
