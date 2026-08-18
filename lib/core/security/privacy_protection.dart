import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 🛡️ Window-level privacy protection (Android FLAG_SECURE).
///
/// While a parent-facing screen (PIN entry, paywall, backup) is open, the
/// window is marked FLAG_SECURE: screenshots and screen recordings capture a
/// blank area and the app is hidden from the recents preview.
///
/// چندین صفحهٔ حساس ممکن است هم‌زمان روی هم باز باشند (مثلاً پنل والد که
/// خودش امن است و روی آن صفحهٔ پین یا paywall باز می‌شود). این کلاس با یک
/// شمارندهٔ مرجع کار می‌کند تا بستنِ صفحهٔ بالایی، تصادفی امنیت صفحهٔ
/// پایینی را خاموش نکند. تا وقتی حداقل یک متقاضی باقی است، FLAG_SECURE روشن
/// می‌ماند.
class PrivacyProtection {
  PrivacyProtection._();

  static const MethodChannel _channel = MethodChannel('kudake_iran/privacy');

  /// تعداد متقاضیان فعالِ صفحهٔ امن. روی رشتهٔ main/UI تغییر می‌کند، پس
  /// بدون قفل هم ایمن است.
  static int _refCount = 0;

  /// آخرین وضعیت اعمال‌شده روی پنجره، تا فراخوانی تکراری به نیتیو نرود.
  static bool _currentlySecure = false;

  /// افزودن یک متقاضی امنیت. اولین متقاضی پنجره را امن می‌کند.
  static Future<void> retain() => _setRefCount(_refCount + 1);

  /// حذف یک متقاضی امنیت. وقتی آخرین متقاضی بسته می‌شود، پرچم پاک می‌شود.
  static Future<void> release() => _setRefCount(_refCount - 1);

  static Future<void> _setRefCount(int next) async {
    final target = next < 0 ? 0 : next;
    _refCount = target;
    final shouldBeSecure = target > 0;
    if (shouldBeSecure == _currentlySecure) return;
    _currentlySecure = shouldBeSecure;
    try {
      await _channel.invokeMethod<void>(
        'setSecureWindow',
        <String, Object?>{'secure': shouldBeSecure},
      );
    } catch (_) {
      // Non-Android platforms / missing plugin: nothing to do. این فقط یک
      // حفاظت دیداری است و شکستش نباید جریان اپ را بگیرد. مقدار را
      // برمی‌گردانیم تا تلاش بعدی (مثلاً باز شدن صفحه‌ای دیگر) دوباره شانس
      // اعمال‌شدن داشته باشد.
      _currentlySecure = !shouldBeSecure;
    }
  }

  /// API قدیمی برای روشن/خاموش مستقیم. در کدهای جدید از [retain]/[release]
  /// استفاده شود. نگه داشته شده تا باقی کدها بدون تغییر کار کنند.
  ///
  /// اگر [secure] برابر true باشد معادل یک retain کامل رفتار می‌کند؛ اگر
  /// false باشد همهٔ متقاضیان را صفر می‌کند (پاک‌سازی صریح).
  static Future<void> enableSecureWindow(bool secure) {
    if (secure) return retain();
    _refCount = 0;
    return _setRefCount(0);
  }
}

/// Wraps a subtree and marks the window secure while it is mounted.
///
/// Used around the parent panel, the paywall and the backup dialogs so a
/// child (or a malicious app) cannot capture the parent PIN or payment flow.
///
/// از retain/release استفاده می‌کند، پس باز و بسته شدن هم‌پوشانِ چند نمونه از
/// این ویجت یکدیگر را خراب نمی‌کنند.
class SecureWindowScope extends StatefulWidget {
  const SecureWindowScope({super.key, required this.child});

  final Widget child;

  @override
  State<SecureWindowScope> createState() => _SecureWindowScopeState();
}

class _SecureWindowScopeState extends State<SecureWindowScope> {
  @override
  void initState() {
    super.initState();
    PrivacyProtection.retain();
  }

  @override
  void dispose() {
    PrivacyProtection.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
