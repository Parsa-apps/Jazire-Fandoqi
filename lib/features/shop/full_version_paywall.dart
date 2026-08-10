import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import '../../shared/widgets/gradient_text.dart';
import '../../core/game_data.dart';
import '../../core/monetization.dart';

/// تبدیل اعداد فارسی به انگلیسی برای مقایسه صحیح
String _normalizeDigits(String input) {
  const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  String result = input;
  for (int i = 0; i < persianDigits.length; i++) {
    result = result.replaceAll(persianDigits[i], englishDigits[i]);
  }
  return result;
}

/// A parent-facing, one-time purchase surface. It never asks a child to pay.
Future<void> showFullVersionPaywall(BuildContext context, {String? featureName}) async {
  final bought = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FullVersionSheet(featureName: featureName),
  );
  if (bought == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('نسخه کامل فعال شد؛ همه دنیاها آماده بازی‌اند! 🎉'),
      backgroundColor: Color(0xFF16803C),
    ));
  }
}

class _FullVersionSheet extends StatefulWidget {
  const _FullVersionSheet({this.featureName});
  final String? featureName;
  @override
  State<_FullVersionSheet> createState() => _FullVersionSheetState();
}

class _FullVersionSheetState extends State<_FullVersionSheet> {
  bool _loading = false;

  Future<bool> _parentGate() async {
    final random = Random();
    final a = random.nextInt(6) + 4;
    final b = random.nextInt(5) + 2;
    final correctAnswer = '${a + b}';
    final answer = TextEditingController();
    final allowed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Theme(
        data: ThemeData.light(useMaterial3: true),
        child: AlertDialog(
          backgroundColor: const Color(0xFFFFFBFF),
          title: const Text('ورود والدین', style: TextStyle(color: Color(0xFF2D3436))),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('برای ادامه، پاسخ این سؤال را وارد کنید:', style: TextStyle(color: Color(0xFF2D3436))),
            const SizedBox(height: 12),
            Text('$a + $b = ؟', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF6C43D9))),
            TextField(
              controller: answer,
              keyboardType: TextInputType.number,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                final normalized = _normalizeDigits(answer.text.trim());
                Navigator.pop(dialogContext, normalized == correctAnswer);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('انصراف', style: TextStyle(color: Colors.redAccent)),
            ),
            FilledButton(
              onPressed: () {
                final normalized = _normalizeDigits(answer.text.trim());
                Navigator.pop(dialogContext, normalized == correctAnswer);
              },
              child: const Text('تأیید'),
            ),
          ],
        ),
      ),
    );
    answer.dispose();
    return allowed ?? false;
  }

  Future<void> _buy() async {
    if (!await _parentGate() || !mounted) return;
    setState(() => _loading = true);
    final ok = await Monetization.purchaseFullVersion();
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ نسخه کامل فعال شد؛ همه دنیاها آماده بازی‌اند! 🎉'),
          backgroundColor: Color(0xFF16803C),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFFFFFBFF),
          title: const Text('پرداخت کامل نشد', style: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w900)),
          content: const Text('لطفاً اتصال اینترنت خود را بررسی کنید و دوباره تلاش کنید. اگر مشکل ادامه داشت، می‌توانید از طریق کافه‌بازار خرید را بازیابی کنید.', style: TextStyle(color: Color(0xFF2D3436))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('باشه', style: TextStyle(color: Color(0xFF6C43D9))),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                if (await Monetization.restoreFullVersion() && mounted) Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C43D9)),
              child: const Text('بازیابی خرید قبلی'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData.light(useMaterial3: true).copyWith(
      textTheme: ThemeData.light(useMaterial3: true).textTheme.apply(
        bodyColor: const Color(0xFF2D3436),
        displayColor: const Color(0xFF2D3436),
        fontSizeFactor: GameData.textScale,
      ),
    ),
    child: Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(color: Color(0xFFFFFBFF), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFF2D3436).withOpacity(0.15), borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 20),
        const GradientText(
          '✨ نسخه کامل کُدَک ایران',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 23,
          ),
          gradientColors: [Color(0xFFFFA726), Color(0xFFF06292), Color(0xFFBA68C8)],
        ).animate().fadeIn(delay: 50.ms).scale(),
        const SizedBox(height: 10),
        Text(
          widget.featureName == null ? 'دنیای کامل یادگیری و بازی را برای همیشه باز کنید.' : '«${widget.featureName}» در نسخه کامل منتظر شماست.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF2D3436), fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 18),
        const _Benefit(text: 'یک پرداخت، دسترسی همیشگی'),
        const _Benefit(text: 'همه بازی‌ها، داستان‌ها و دنیاهای آموزشی'),
        const _Benefit(text: 'بدون تبلیغ و بدون تمدید ماهانه'),
        const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: _loading ? null : _buy,
        icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_open_rounded, color: Colors.white),
        label: Text(
          _loading ? 'در حال اتصال امن...' : 'خرید نسخه کامل',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(color: Color(0xFF6C43D9), blurRadius: 8)]),
        ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: const Color(0xFF6C43D9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, duration: 500.ms),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _loading ? null : () async {
            if (await Monetization.restoreFullVersion() && mounted) Navigator.pop(context, true);
          },
          child: const Text('بازیابی خرید قبلی', style: TextStyle(color: Color(0xFF6C43D9), fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ])),
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF16803C)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF2D3436), fontSize: 15, height: 1.4))),
      ],
    ),
  );
}
