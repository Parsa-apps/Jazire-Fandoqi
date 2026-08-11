import 'package:flutter/material.dart';

import '../../core/growth/growth.dart';
import '../../core/monetization.dart';
import 'full_version_paywall.dart';

/// Route-level guard so premium games cannot be opened through a deep link.
class GameAccessGate extends StatefulWidget {
  const GameAccessGate({super.key, required this.gameName, required this.child});
  final String gameName;
  final Widget child;
  @override
  State<GameAccessGate> createState() => _GameAccessGateState();
}

class _GameAccessGateState extends State<GameAccessGate> {
  static const _free = {'الفبا', 'اعداد', 'رنگ‌ها', 'ستاره‌گیری', 'حباب‌ترکان'};
  bool? _allowed;

  @override
  void initState() { super.initState(); _check(); }
  Future<void> _check() async {
    final allowed = _free.contains(widget.gameName) || await Monetization.hasFullVersion();
    if (mounted) setState(() => _allowed = allowed);
  }

  @override
  Widget build(BuildContext context) {
    final blockedRoute = '/game/${widget.gameName}';
    if (ParentControls.isRouteBlocked(blockedRoute) || ParentControls.isBedtimeNow) {
      return Scaffold(
        appBar: AppBar(title: const Text('فعلاً استراحت')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              ParentControls.blockReason(blockedRoute),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.6),
            ),
          ),
        ),
      );
    }
    if (_allowed == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_allowed!) return widget.child;
    return Scaffold(
      appBar: AppBar(title: const Text('بخش ویژه')),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.lock_rounded, size: 76, color: Color(0xFF6C43D9)),
          const SizedBox(height: 18),
          Text('«${widget.gameName}» در نسخه کامل باز می‌شود', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('نسخه رایگان را امتحان کرده‌اید؛ حالا همه بازی‌ها را برای همیشه باز کنید.', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: () async { await showFullVersionPaywall(context, featureName: widget.gameName); await _check(); }, icon: const Icon(Icons.lock_open_rounded), label: const Text('مشاهده نسخه کامل')),
        ]),
      )),
    );
  }
}
