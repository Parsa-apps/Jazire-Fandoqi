import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// 👑 هویت بصری Parsa Apps — منبع واحد رنگ‌ها، دارایی‌ها و نام برند
///
/// دارایی‌های برندِ ناشر Parsa Apps برای بخش «دربارهٔ برنامه» و اعتبار ناشر.
/// لوگوی اسپلش و آیکون اصلیِ اپ جزیرهٔ فندقی، دارایی‌های مستقل خودشان را دارند؛
/// در اسپلش همچنان اعتبار «Powered by Parsa Apps» نمایش داده می‌شود.
/// ─────────────────────────────────────────────────────────────
abstract final class ParsaBrand {
  /// تصویر اصلی و مرجع برند (۱۲۵۴×۱۲۵۴، پس‌زمینهٔ مشکی).
  ///
  /// فقط برای تولید نسخه‌های مشتق (آیکون، نسخهٔ شفاف اسپلش) استفاده
  /// می‌شود و برای صرفه‌جویی در حجم نصب، به‌تنهایی بسته نمی‌شود.
  static const String masterAsset = 'assets/branding/parsa_apps_logo.png';

  /// نسخهٔ بهینهٔ همان تصویر با پس‌زمینهٔ شفاف (۱۰۲۴×۱۰۲۴، WebP).
  ///
  /// برای اسپلش سینمایی لازم است، چون هالهٔ نئونی باید *پشت* لوگو دیده
  /// شود؛ یک مربع مشکی مات هاله را می‌پوشاند. طرح، رنگ‌ها و جزئیات
  /// دقیقاً همان تصویر اصلی‌اند و فقط پس‌زمینهٔ یکدست مشکی حذف شده است.
  static const String logoAsset = 'assets/branding/parsa_apps_logo_alpha.webp';

  /// خوراک تولید آیکون‌ها (فقط زمان ساخت، در بستهٔ برنامه نیست).
  static const String launcherSource = 'assets/icons/app_icon.png';
  static const String launcherForegroundSource =
      'assets/icons/fandoghi_app_icon.png';

  // ── رنگ‌های برند، برداشته‌شده از خود لوگو ──
  /// مشکی عمیق پس‌زمینه — نه خاکستری، تا پنل OLED واقعاً سیاه باشد.
  static const Color ink = Color(0xFF04060A);
  static const Color inkSoft = Color(0xFF080D16);

  static const Color neonBlue = Color(0xFF2E8BFF);
  static const Color electricBlue = Color(0xFF1466F5);
  static const Color iceBlue = Color(0xFF9BD4FF);
  static const Color deepBlue = Color(0xFF0A2A5E);

  static const Color gold = Color(0xFFFFC94D);
  static const Color brightGold = Color(0xFFFFE08A);
  static const Color deepGold = Color(0xFFC98A1E);

  static const Color silver = Color(0xFFE8EDF5);

  // ── نام برند ──
  static const String wordmark = 'PARSA APPS';
  static const String name = 'Parsa Apps';
  static const String developer = 'فرشاد پارسا';
  static const String poweredBy = 'Powered by Parsa Apps';

  /// گرادیان شیشه‌ای تیره برای کارت‌های برند (دربارهٔ برنامه).
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF0B1830), Color(0xFF071021), Color(0xFF03060B)],
    stops: <double>[0.0, 0.55, 1.0],
  );

  /// درخشش طلایی فلزی، هماهنگ با تاج و حاشیه‌های لوگو.
  static const LinearGradient goldSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[brightGold, gold, deepGold, gold],
  );

  /// قلم برند برای نوشته‌های لاتین (نام لوگو در تصویر هم Sans است).
  static const List<Shadow> glowText = <Shadow>[
    Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
    Shadow(color: Color(0x33000000), blurRadius: 18),
  ];
}
