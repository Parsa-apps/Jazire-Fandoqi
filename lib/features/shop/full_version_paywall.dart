import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/monetization.dart';

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
    final answer = TextEditingController();
    final allowed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ورود والدین'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('برای ادامه، پاسخ این سؤال را وارد کنید:'),
          const SizedBox(height: 12),
          Text('$a + $b = ؟', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          TextField(controller: answer, keyboardType: TextInputType.number, autofocus: true),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, answer.text.trim() == '${a + b}'), child: const Text('تأیید')),
        ],
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
    if (ok) Navigator.pop(context, true);
    else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پرداخت کامل نشد؛ لطفاً دوباره تلاش کنید.')));
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
    decoration: const BoxDecoration(color: Color(0xFFFFFBFF), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
    child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8))),
      const SizedBox(height: 20),
      const Text('✨ نسخه کامل کُدَک ایران', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 23)).animate().fadeIn().scale(),
      const SizedBox(height: 10),
      Text(widget.featureName == null ? 'دنیای کامل یادگیری و بازی را برای همیشه باز کنید.' : '«${widget.featureName}» در نسخه کامل منتظر شماست.', textAlign: TextAlign.center),
      const SizedBox(height: 18),
      const _Benefit(text: 'یک پرداخت، دسترسی همیشگی'),
      const _Benefit(text: 'همه بازی‌ها، داستان‌ها و دنیاهای آموزشی'),
      const _Benefit(text: 'بدون تبلیغ و بدون تمدید ماهانه'),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: _loading ? null : _buy,
        icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_open_rounded),
        label: Text(_loading ? 'در حال اتصال امن...' : 'خرید نسخه کامل'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), backgroundColor: const Color(0xFF6C43D9)),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1800.ms, color: Colors.white24),
      TextButton(onPressed: _loading ? null : () async { if (await Monetization.restoreFullVersion() && mounted) Navigator.pop(context, true); }, child: const Text('بازیابی خرید قبلی')),
    ])),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [const Icon(Icons.check_circle_rounded, color: Color(0xFF16803C)), const SizedBox(width: 10), Expanded(child: Text(text))]));
}
