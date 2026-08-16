import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/game_data.dart';

/// دروازهٔ والد: فقط پین ۴ رقمی. جمع ساده را کلاس‌اولی حل می‌کند.
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
  if (ok) GameData.parentUnlockedThisSession = true;
  return ok;
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

Future<String?> _pinDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String confirmLabel,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: AppFonts.vazirmatn(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              final pin = controller.text.trim();
              if (RegExp(r'^\d{4}$').hasMatch(pin)) {
                Navigator.pop(ctx, pin);
              }
            },
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}
