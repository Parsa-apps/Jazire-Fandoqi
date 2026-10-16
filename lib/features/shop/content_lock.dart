import 'package:flutter/material.dart';

import '../../core/growth/smart_conversion.dart';
import '../../core/monetization.dart';
import 'full_version_paywall.dart';

/// 🔒 درِ یکپارچهٔ قفلِ محتوا — «نیمهٔ رایگان، نیمهٔ نسخهٔ کامل»
///
/// هر صفحه‌ای که مجموعه‌ای از آیتم‌های محتوایی را نشان می‌دهد (دنیاهای مهارت
/// زندگی، حیوانات، شغل‌ها، مفاهیم، احساسات، واژه‌نامه، ...) باید **فقط** از
/// این مسیر اجازهٔ ورود بگیرد. دلیل وجودش این است که قانون دسترسی در
/// [ContentAccessPolicy] متمرکز است، ولی اِعمالِ آن تا پیش از این در هر صفحه
/// جداگانه و سلیقه‌ای نوشته شده بود — و هر صفحه‌ای که یادش می‌رفت، نیمهٔ
/// پولی‌اش را بی‌صدا رایگان تحویل می‌داد (همان اتفاقی که برای هاب مهارت
/// زندگی افتاد: مسیر `/life-skills/<id>` درست گیت شده بود، ولی خودِ هاب با
/// `MaterialPageRoute` مستقیم همهٔ دنیاها را باز می‌کرد).
///
/// رفتار:
///  * آیتم رایگان → اجازهٔ فوری، بدون هیچ فراخوانی شبکه/استور.
///  * آیتم پولی + کاربر نسخهٔ کامل دارد → اجازه.
///  * آیتم پولی + کاربر نسخهٔ کامل ندارد → پی‌وال والد؛ فقط در صورت تأیید
///    واقعیِ فروشگاه (`Monetization.hasFullVersion` بعد از خرید) اجازه می‌دهد.
///    پیامِ پی‌وال یا انصرافِ والد هرگز دسترسی نمی‌دهد.
///
/// مقدار برگشتی یعنی «اجازهٔ ورود»؛ صدا/لرزش/ناوبری بر عهدهٔ فراخوان است.
Future<bool> ensureContentAccess(
  BuildContext context, {
  required String featureName,
  required bool isFree,
}) async {
  if (isFree) return true;
  if (await Monetization.hasFullVersion()) return true;
  if (!context.mounted) return false;
  SmartConversion.noteLockedTap();
  final unlocked =
      await showFullVersionPaywall(context, featureName: featureName);
  if (!unlocked) return false;
  // پی‌وال فقط «ادعا» می‌کند؛ مرجعِ نهایی دوباره خودِ entitlement است تا
  // بسته‌شدنِ اتفاقیِ دیالوگ هرگز دسترسی پولی نسازد.
  return Monetization.hasFullVersion();
}

/// آیا این آیتمِ محتوایی برای کاربر فعلی قفل است؟
///
/// `isFree` باید از [ContentAccessPolicy] آمده باشد (بر پایهٔ ترتیبِ کتاب،
/// نه ترتیبِ نمایش/فیلتر/جست‌وجو) وگرنه فیلتر کردنِ یک مجموعه می‌تواند آیتمِ
/// پولی را به صدرِ فهرست بیاورد و رایگانش کند.
bool isContentLocked({required bool isFree, required bool hasFullVersion}) =>
    !isFree && !hasFullVersion;

/// نشانِ قفلِ یک آیتمِ محتوایی — همان زبانِ بصریِ قفلِ بازی‌ها در نقشهٔ جزیره.
///
/// فقط ظاهر است و جلوی لمس را نمی‌گیرد؛ تصمیمِ واقعی همیشه با
/// [ensureContentAccess] است تا لمسِ روی آیتمِ قفل‌شده پی‌وال را بیاورد، نه
/// اینکه بی‌صدا هیچ اتفاقی نیفتد.
class LockedItemBadge extends StatelessWidget {
  const LockedItemBadge({
    super.key,
    this.size = 30,
    this.color = const Color(0xFF5D4037),
    this.background = const Color(0xFFFFF8E1),
  });

  final double size;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_rounded,
        size: size * 0.58,
        color: color,
      ),
    );
  }
}

/// لایهٔ آمادهٔ «قفل روی کارت»؛ وقتی [locked] است نشان قفل روی کارت می‌نشیند
/// و در غیر این صورت خودِ کارت را بی‌تغییر برمی‌گرداند.
///
/// محتوای زیرش عمداً تار نمی‌شود تا کودک بفهمد چه چیزی آن‌جا است و والد
/// بداند با یک خرید چه باز می‌شود.
class LockedCardOverlay extends StatelessWidget {
  const LockedCardOverlay({
    super.key,
    required this.locked,
    required this.child,
    this.badgeSize = 30,
  });

  final bool locked;
  final Widget child;
  final double badgeSize;

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return Stack(
      children: [
        child,
        PositionedDirectional(
          top: 6,
          end: 6,
          child: LockedItemBadge(size: badgeSize),
        ),
      ],
    );
  }
}
