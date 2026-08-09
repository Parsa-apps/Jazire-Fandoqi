import 'package:flutter/widgets.dart';

/// ────────────────────────────────────────────────────────────
/// 🤚 فاز ۱۶: پشتیبانی چپ‌دست/راست‌دست
///
/// دکمه‌های مهم (برگشت، اقدام اصلی) باید در دسترس شست همان دست
/// باشند. این helper فقط بر اساس تنظیم والدین، چینش را برمی‌گرداند.
/// ────────────────────────────────────────────────────────────
class HandPreference {
  HandPreference._();

  /// آیا کودک چپ‌دست است؟ (از GameData خوانده می‌شود — برای عدم وابستگی
  /// مستقیم به core در ویجت‌های shared، مقدار از بیرون داده می‌شود)
  static Alignment heroAlignment({required bool leftHanded}) =>
      leftHanded ? Alignment.centerLeft : Alignment.centerRight;

  static EdgeInsets directionalPadding({
    required bool leftHanded,
    double amount = 16,
  }) =>
      leftHanded
          ? EdgeInsets.only(left: amount)
          : EdgeInsets.only(right: amount);

  /// دکمه اقدام اصلی: در حالت چپ‌دست سمت چپ، راست‌دست سمت راست.
  static Row mainActionRow({
    required bool leftHanded,
    required Widget action,
    required Widget secondary,
  }) {
    return leftHanded
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [action, const SizedBox(width: 12), secondary],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [secondary, const SizedBox(width: 12), action],
          );
  }
}
