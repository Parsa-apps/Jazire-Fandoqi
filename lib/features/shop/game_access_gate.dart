import 'package:flutter/material.dart';
import 'package:jazireh_fandoghi/shared/widgets/animated_gold_lock.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/content_access_policy.dart';
import '../../core/growth/growth.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/island_kit.dart';
import '../../shared/widgets/parent_pin_gate.dart';
import 'full_version_paywall.dart';

/// Route-level guard so premium games cannot be opened through a deep link.
class GameAccessGate extends StatefulWidget {
  const GameAccessGate({
    super.key,
    required this.gameName,
    required Widget this.child,
    this.isFree,
  }) : childBuilder = null;

  /// Construct destinations with side effects only after access is granted.
  const GameAccessGate.lazy({
    super.key,
    required this.gameName,
    required Widget Function() this.childBuilder,
    this.isFree,
  }) : child = null;

  final String gameName;
  /// Content routes supply their item policy explicitly. A story/world title
  /// must never inherit a free game's entitlement just because names match.
  final bool? isFree;
  final Widget? child;
  final Widget Function()? childBuilder;
  @override
  State<GameAccessGate> createState() => _GameAccessGateState();
}

class _GameAccessGateState extends State<GameAccessGate>
    with SingleTickerProviderStateMixin {
  bool? _allowed;
  int _checkGeneration = 0;
  Widget? _lazyChild;
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    Monetization.accessStatus.addListener(_onAccessChanged);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _check();
  }

  @override
  void didUpdateWidget(GameAccessGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childBuilder != widget.childBuilder) _lazyChild = null;
    if (oldWidget.gameName != widget.gameName || oldWidget.isFree != widget.isFree) {
      _allowed = null;
      _lazyChild = null;
      _check();
    }
  }

  void _onAccessChanged() {
    final status = Monetization.accessStatus.value;
    final isFree = widget.isFree ?? ContentAccessPolicy.isGameFree(widget.gameName);
    if (!mounted || isFree || _allowed != true ||
        status == FullVersionAccessStatus.checking || status.isVerified) {
      return;
    }
    _checkGeneration++;
    setState(() {
      _allowed = false;
      _lazyChild = null;
    });
  }

  @override
  void dispose() {
    Monetization.accessStatus.removeListener(_onAccessChanged);
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final generation = ++_checkGeneration;
    final isFree = widget.isFree ?? ContentAccessPolicy.isGameFree(widget.gameName);
    final allowed = isFree || await Monetization.hasFullVersion();
    if (mounted && generation == _checkGeneration) {
      setState(() => _allowed = allowed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockedRoute = '/game/${widget.gameName}';
    if (ParentControls.isRouteBlocked(blockedRoute) || ParentControls.isBedtimeNow) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFAEE7FF), Color(0xFFE8F9FF)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: IslandPanel(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 44)),
                      const SizedBox(height: 10),
                      Text(
                        'فعلاً استراحت',
                        style: AppFonts.kids(
                          color: IslandWorldPalette.ink,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ParentControls.blockReason(blockedRoute),
                        textAlign: TextAlign.center,
                        style: AppFonts.vazirmatn(
                          color: IslandWorldPalette.ink.withOpacity(0.75),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 18),
                      IslandKidButton(
                        label: 'برگشت به جزیره',
                        icon: Icons.home_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
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
              colors: [Color(0xFFAEE7FF), Color(0xFFE8F9FF)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, -5 * _floatCtrl.value),
                    child: Image.asset(
                      IslandWorldAssets.fandoghiWave,
                      width: 84,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                      errorBuilder: (_, __, ___) =>
                          const Text('🐿️', style: TextStyle(fontSize: 56)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'جزیره داره آماده می‌شه…',
                  style: AppFonts.kids(
                    color: IslandWorldPalette.ink,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 14),
                const CircularProgressIndicator(
                  color: Color(0xFFFFB300),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_allowed!) {
      if (widget.childBuilder != null) {
        return _lazyChild ??= widget.childBuilder!();
      }
      return widget.child!;
    }
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
                  const AnimatedGoldLock(size: 128),
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
                    child: IslandKidButton(
                      label: 'مامان / بابا بیاید',
                      icon: Icons.family_restroom_rounded,
                      onPressed: () async {
                        final allowed = await requestParentAccess(context);
                        if (!allowed || !context.mounted) return;
                        await showFullVersionPaywall(
                          context,
                          featureName: widget.gameName,
                        );
                        await _check();
                      },
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
