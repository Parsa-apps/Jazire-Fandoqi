import 'package:flutter/material.dart';

import '../../core/content_access.dart';
import '../../core/growth/growth.dart';
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
  bool? _allowed;

  @override
  void initState() { super.initState(); _check(); }
  Future<void> _check() async {
    // `refresh` خودش مرجع خرید (کافه‌بازار/Keystore) را می‌خواند و کش
    // می‌کند؛ پس یک بار کافی است و بقیهٔ صفحه‌ها بلافاصله هم‌راستا می‌شوند.
    await ContentAccess.refresh();
    final allowed = ContentAccess.isGameUnlocked(widget.gameName);
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

/// گیت عمومی برای محتوای پولی (کارتون، قصه، لالایی و …) — همان ظاهر
/// و همان مسیر خرید `GameAccessGate` را دارد، ولی به‌جای «نام بازی» با
/// یک شرطِ بازبودن کار می‌کند تا قوانین «۲ مورد اول رایگان» هم از راه
/// دیپ‌لینک دور زده نشود.
class PremiumContentGate extends StatefulWidget {
  const PremiumContentGate({
    super.key,
    required this.isUnlocked,
    required this.contentName,
    required this.child,
  });

  /// هر بار بعد از خرید دوباره ارزیابی می‌شود.
  final bool Function() isUnlocked;
  final String contentName;
  final Widget child;

  @override
  State<PremiumContentGate> createState() => _PremiumContentGateState();
}

class _PremiumContentGateState extends State<PremiumContentGate> {
  bool? _allowed;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (widget.isUnlocked()) {
      if (mounted) setState(() => _allowed = true);
      return;
    }
    await ContentAccess.refresh();
    if (mounted) setState(() => _allowed = widget.isUnlocked());
  }

  @override
  Widget build(BuildContext context) {
    if (_allowed == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_allowed!) return widget.child;
    return Scaffold(
      appBar: AppBar(title: const Text('بخش ویژه')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 76, color: Color(0xFF6C43D9)),
              const SizedBox(height: 18),
              Text(
                '«${widget.contentName}» در نسخه کامل باز می‌شود',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'در نسخه رایگان چند مورد اول هر بخش باز است؛ با یک خرید همیشگی همه محتوا باز می‌شود.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  await showFullVersionPaywall(context, featureName: widget.contentName);
                  await _check();
                },
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('مشاهده نسخه کامل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
