import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/content_access_policy.dart';
import '../../core/growth/growth.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/parent_pin_gate.dart';
import 'full_version_paywall.dart';

/// Route-level guard so premium games cannot be opened through a deep link.
class GameAccessGate extends StatefulWidget {
  const GameAccessGate({super.key, required this.gameName, required this.child});
  final String gameName;
  final Widget child;
  @override
  State<GameAccessGate> createState() => _GameAccessGateState();
}

class _GameAccessGateState extends State<GameAccessGate>
    with SingleTickerProviderStateMixin {
  bool? _allowed;
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _check();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final allowed = ContentAccessPolicy.isGameFree(widget.gameName) ||
        await Monetization.hasFullVersion();
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
    if (_allowed == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F0FF), Color(0xFFFFF8F0)],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_allowed!) return widget.child;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.08),
              const Color(0xFFF5F0FF),
              AppColors.mapAccent.withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Animated lock icon ──
                  AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, __) {
                      return Transform.translate(
                        offset: Offset(0, -6 * _floatCtrl.value),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.15),
                                AppColors.primary.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 72,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '«${widget.gameName}»',
                    textAlign: TextAlign.center,
                    style: AppFonts.kids(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مامان یا بابا این بخش رو باز می‌کنه',
                    textAlign: TextAlign.center,
                    style: AppFonts.vazirmatn(
                      color: const Color(0xFF3D3450),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'این بخش برای خرید نسخهٔ کامل است؛\nکودک لازم نیست اینجا کاری بکند.',
                    textAlign: TextAlign.center,
                    style: AppFonts.vazirmatn(
                      color: const Color(0xFF6B5D7B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7048C8), Color(0xFF9B59B6)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7048C8).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: () async {
                          final allowed = await requestParentAccess(context);
                          if (!allowed || !mounted) return;
                          await showFullVersionPaywall(context, featureName: widget.gameName);
                          await _check();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: AppFonts.kids(fontSize: 18),
                        ),
                        icon: const Icon(Icons.family_restroom_rounded),
                        label: const Text('مامان / بابا بیاید'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: Text(
                      'برگشت به جزیره',
                      style: AppFonts.vazirmatn(
                        color: const Color(0xFF6B5D7B),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
