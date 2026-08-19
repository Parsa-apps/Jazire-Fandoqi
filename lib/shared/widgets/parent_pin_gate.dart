import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/game_data.dart';

/// ارقام فارسی (۰-۹) و عربی (٠-٩) را به ارقام لاتین تبدیل می‌کند.
///
/// کیبوردهای فارسی بعضی دستگاه‌ها رقم فارسی تایپ می‌کنند؛ بدون این تبدیل،
/// پین یا اصلاً وارد نمی‌شد یا تأیید نمی‌شد و دکمهٔ خرید «بی‌صدا» کاری
/// نمی‌کرد. جدا نگه داشته شده تا بدون ویجت قابل تست باشد.
String normalizePinDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x06F0 && rune <= 0x06F9) {
      // ارقام فارسی ۰-۹
      buffer.writeCharCode(0x30 + (rune - 0x06F0));
    } else if (rune >= 0x0660 && rune <= 0x0669) {
      // ارقام عربی ٠-٩
      buffer.writeCharCode(0x30 + (rune - 0x0660));
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// دروازهٔ والد: فقط پین ۴ رقمی. جمع ساده را کلاس‌اولی حل می‌کند.
///
/// هیچ مسیر شکستی بی‌صدا نیست: پین اشتباه پیام قابل‌مشاهده می‌گیرد تا
/// کاربر فکر نکند دکمه‌ها کار نمی‌کنند.
Future<bool> requestParentAccess(BuildContext context) async {
  if (!GameData.isLoaded) return false;

  if (!GameData.hasParentPin()) {
    final created = await _askNewPin(context);
    if (created) GameData.parentUnlockedThisSession = true;
    return created;
  }

  final pin = await _askExistingPin(context);
  if (pin == null) return false;
  final ok = await GameData.verifyParentPin(pin);
  if (ok) {
    GameData.parentUnlockedThisSession = true;
    return true;
  }
  // پین اشتباه بود — حتماً بازخورد نشان بده؛ سکوت یعنی «دکمه کار نمی‌کند».
  // نتیجهٔ دروازه همان لحظه برمی‌گردد و دیالوگ اطلاع‌رسانی مستقل از جریان
  // caller روی صفحه می‌ماند؛ منتظر بسته‌شدنش نمی‌مانیم تا سرنوشت هیچ فلوی
  // خریدی به چرخهٔ عمر این دیالوگ گره نخورد.
  if (context.mounted) {
    unawaited(_showWrongPinNotice(context));
  }
  return false;
}

Future<void> _showWrongPinNotice(BuildContext context) {
  if (!context.mounted) return Future.value();
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('پین اشتباه بود',
          style: AppFonts.vazirmatn(fontWeight: FontWeight.w900)),
      content: Text('پین واردشده درست نیست. دوباره تلاش کنید.',
          style: AppFonts.vazirmatn(fontSize: 14, height: 1.6)),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('باشه'),
        ),
      ],
    ),
  );
}

Future<String?> _askExistingPin(BuildContext context) {
  return _pinDialog(
    context,
    title: 'ورود والدین',
    subtitle: 'پین ۴ رقمی را وارد کنید. این بخش برای کودک نیست.',
    confirmLabel: 'ورود',
  );
}

Future<bool> _askNewPin(BuildContext context) async {
  final first = await _pinDialog(
    context,
    title: 'تنظیم پین والدین',
    subtitle: 'یک پین ۴ رقمی بگذارید تا کودک نتواند تنظیمات را عوض کند.',
    confirmLabel: 'ادامه',
  );
  if (first == null || !context.mounted) return false;
  final second = await _pinDialog(
    context,
    title: 'تکرار پین',
    subtitle: 'همان پین را یک‌بار دیگر بنویسید.',
    confirmLabel: 'ذخیره',
  );
  if (second == null) return false;
  if (first != second) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دو پین یکسان نبود؛ دوباره تلاش کنید.')),
      );
    }
    return false;
  }
  return GameData.setParentPin(first);
}

/// فیلتری که هم ارقام لاتین و هم فارسی/عربی را مجاز می‌داند؛ تبدیل نهایی
/// در [normalizePinDigits] انجام می‌شود.
final TextInputFormatter _pinDigitFilter = FilteringTextInputFormatter.allow(
  RegExp('[0-9\u06F0-\u06F9\u0660-\u0669]'),
);

Future<String?> _pinDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String confirmLabel,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _PinDialogContent(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
    ),
  );
}

/// محتوای دیالوگ پین.
///
/// ⚠️ نکتهٔ مهم: کنترلر ورودی باید هم‌عمر خود ویجت دیالوگ باشد. الگوی قدیمی
/// `showDialog(...).whenComplete(controller.dispose)` کنترلر را به‌محض کامل‌شدن
/// futureِ route نابود می‌کرد، در حالی که انیمیشن خروج دیالوگ هنوز در حال
/// اجرا بود و TextField حین بازسازی به کنترلرِ disposeشده گوش می‌داد →
/// «TextEditingController was used after being disposed» و به‌هم‌ریختگی
/// layout. با Stateful بودن محتوا، dispose دقیقاً وقتی اتفاق می‌افتد که درخت
/// ویجت واقعاً حذف می‌شود.
class _PinDialogContent extends StatefulWidget {
  const _PinDialogContent({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
  });

  final String title;
  final String subtitle;
  final String confirmLabel;

  @override
  State<_PinDialogContent> createState() => _PinDialogContentState();
}

class _PinDialogContentState extends State<_PinDialogContent> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    // نرمال‌سازی ارقام فارسی/عربی به لاتین قبل از اعتبارسنجی.
    final pin = normalizePinDigits(_controller.text.trim());
    if (RegExp(r'^\d{4}$').hasMatch(pin)) {
      Navigator.pop(context, pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.title,
          style: AppFonts.vazirmatn(fontWeight: FontWeight.w900)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.subtitle, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            autofocus: true,
            textAlign: TextAlign.center,
            inputFormatters: [_pinDigitFilter],
            onSubmitted: (_) => _confirm(),
            style: const TextStyle(fontSize: 28, letterSpacing: 10),
            decoration: InputDecoration(
              hintText: '••••',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: _confirm,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
