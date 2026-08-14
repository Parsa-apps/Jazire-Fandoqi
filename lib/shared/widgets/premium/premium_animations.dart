import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ═══════════════════════════════════════════════════════════
/// 🎭 ANIMATED LIST ITEMS — آیتم‌های لیست با انیمیشن
/// برای لیست بازی‌ها، داستان‌ها و محتوای آموزشی
/// ═══════════════════════════════════════════════════════════

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;
  final bool enableTapAnimation;
  final VoidCallback? onTap;

  const AnimatedListItem({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 400),
    this.beginOffset = const Offset(0, 0.3),
    this.enableTapAnimation = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entranceAnimation = child
        .animate()
        .fadeIn(
          delay: delay * index,
          duration: duration,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: beginOffset.dy,
          end: 0,
          delay: delay * index,
          duration: duration,
          curve: Curves.easeOutCubic,
        );

    Widget item = enableTapAnimation
        ? entranceAnimation.scale(
            begin: const Offset(1, 1),
            end: const Offset(0.98, 0.98),
            duration: 100.ms,
          )
        : entranceAnimation;

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: item,
      );
    }

    return item;
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🃏 GAME CARD — کارت بازی با افکت سه‌بعدی
/// ═══════════════════════════════════════════════════════════

class GameCard3D extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color gradientStart;
  final Color gradientEnd;
  final Color glowColor;
  final VoidCallback? onTap;
  final bool isLocked;
  final double progress;
  final Widget? badge;

  const GameCard3D({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientStart,
    required this.gradientEnd,
    required this.glowColor,
    this.onTap,
    this.isLocked = false,
    this.progress = 0,
    this.badge,
  });

  @override
  State<GameCard3D> createState() => _GameCard3DState();
}

class _GameCard3DState extends State<GameCard3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tiltController;
  double _xOffset = 0;
  double _yOffset = 0;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (widget.isLocked) return;
    
    final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    final position = details.localPosition;
    
    setState(() {
      _xOffset = (position.dx - center.dx) / center.dx * 10;
      _yOffset = (position.dy - center.dy) / center.dy * 10;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _xOffset = 0;
      _yOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: widget.isLocked
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  widget.onTap?.call();
                },
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: _onPanEnd,
          child: MouseRegion(
            onEnter: (_) {
              if (!widget.isLocked) _tiltController.forward();
            },
            onExit: (_) {
              _tiltController.reverse();
              setState(() {
                _xOffset = 0;
                _yOffset = 0;
              });
            },
            child: AnimatedBuilder(
              animation: _tiltController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_yOffset * 0.01)
                    ..rotateY(_xOffset * 0.01)
                    ..scale(1.0 + _tiltController.value * 0.05),
                  child: child,
                );
              },
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Main content
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.isLocked
                              ? [Colors.grey.shade400, Colors.grey.shade600]
                              : [widget.gradientStart, widget.gradientEnd],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.progress > 0) ...[
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: widget.progress,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // Lock overlay
                    if (widget.isLocked)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    
                    // Badge
                    if (widget.badge != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: widget.badge!,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🌟 SUCCESS OVERLAY — پوشش موفقیت با انیمیشن
/// ═══════════════════════════════════════════════════════════

class SuccessOverlay extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const SuccessOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 2),
  });

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(_opacityAnimation.value * 0.6),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 80),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.2, 1.2),
                            duration: 500.ms,
                          ),
                      const SizedBox(height: 16),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2D3436),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🎠 HORIZONTAL GAME SCROLLER — اسکرولر افقی بازی‌ها
/// ═══════════════════════════════════════════════════════════

class HorizontalGameScroller extends StatefulWidget {
  final List<GameCard3D> games;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final EdgeInsets? padding;
  final void Function(int index)? onGameSelected;

  const HorizontalGameScroller({
    super.key,
    required this.games,
    this.itemWidth = 160,
    this.itemHeight = 200,
    this.spacing = 16,
    this.padding,
    this.onGameSelected,
  });

  @override
  State<HorizontalGameScroller> createState() => _HorizontalGameScrollerState();
}

class _HorizontalGameScrollerState extends State<HorizontalGameScroller> {
  late final ScrollController _scrollController;
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    setState(() {
      _showLeftArrow = currentScroll > 20;
      _showRightArrow = currentScroll < maxScroll - 20;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(bool left) {
    final targetOffset = left
        ? (_scrollController.offset - widget.itemWidth * 2).clamp(0.0, double.infinity)
        : (_scrollController.offset + widget.itemWidth * 2);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.games.length,
          separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
          itemBuilder: (context, index) {
            return SizedBox(
              width: widget.itemWidth,
              height: widget.itemHeight,
              child: widget.games[index],
            );
          },
        ),
        if (_showLeftArrow)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: _ArrowButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => _scroll(true),
            ),
          ),
        if (_showRightArrow)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _ArrowButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => _scroll(false),
            ),
          ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 80),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF6C5CE7)),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 📱 RESPONSIVE LAYOUT — چیدمان واکنش‌گرا
/// ═══════════════════════════════════════════════════════════

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900 && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
