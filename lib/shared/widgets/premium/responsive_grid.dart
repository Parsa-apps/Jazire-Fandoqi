import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ═══════════════════════════════════════════════════════════
/// 📐 RESPONSIVE GRID — گرید واکنش‌گرای حرفه‌ای
/// چیدمان خودکار بر اساس سایز صفحه
/// ═══════════════════════════════════════════════════════════

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int minCrossAxisCount;
  final int maxCrossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minCrossAxisCount = 2,
    this.maxCrossAxisCount = 4,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 1,
    this.padding,
  });

  int _getCrossAxisCount(double width) {
    if (width < 400) return minCrossAxisCount;
    if (width < 600) return (minCrossAxisCount + maxCrossAxisCount) ~/ 2;
    return maxCrossAxisCount;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          padding: padding ?? const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) {
            return AnimatedGridItem(
              index: index,
              child: children[index],
            );
          },
        );
      },
    );
  }
}

class AnimatedGridItem extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedGridItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🎯 STAGGERED GRID — گرید موزاییکی
/// برای نمایش کارت‌های با اندازه‌های مختلف
/// ═══════════════════════════════════════════════════════════

class StaggeredTile {
  final int crossAxisCell;
  final int mainAxisCell;

  const StaggeredTile({
    this.crossAxisCell = 1,
    this.mainAxisCell = 1,
  });

  static const StaggeredTile single = StaggeredTile(crossAxisCell: 1, mainAxisCell: 1);
  static const StaggeredTile wide = StaggeredTile(crossAxisCell: 2, mainAxisCell: 1);
  static const StaggeredTile tall = StaggeredTile(crossAxisCell: 1, mainAxisCell: 2);
  static const StaggeredTile large = StaggeredTile(crossAxisCell: 2, mainAxisCell: 2);
}

class StaggeredGrid extends StatelessWidget {
  final List<StaggeredTile> tiles;
  final List<Widget> children;
  final double spacing;
  final EdgeInsets? padding;

  const StaggeredGrid({
    super.key,
    required this.tiles,
    required this.children,
    this.spacing = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 
            (padding?.horizontal ?? 32);
        final cellWidth = availableWidth / 3;
        
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(children.length, (index) {
            final tile = tiles[index];
            final width = cellWidth * tile.crossAxisCell + 
                (tile.crossAxisCell - 1) * spacing;
            final height = cellWidth * tile.mainAxisCell + 
                (tile.mainAxisCell - 1) * spacing;
            
            return SizedBox(
              width: width,
              height: height,
              child: AnimatedGridItem(
                index: index,
                child: children[index],
              ),
            );
          }),
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 📱 RESPONSIVE COLUMN — ستون واکنش‌گرا
/// نمایش محتوا در ستون‌های متعدد بر اساس سایز صفحه
/// ═══════════════════════════════════════════════════════════

class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final VerticalDirection verticalDirection;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.verticalDirection = VerticalDirection.down,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Mobile: همه در یک ستون
    if (width < 600) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        verticalDirection: verticalDirection,
        children: children,
      );
    }
    
    // Tablet: ۲ ستون
    if (width < 900) {
      return _buildColumns(2, children);
    }
    
    // Desktop: ۳ ستون
    return _buildColumns(3, children);
  }

  Widget _buildColumns(int columnCount, List<Widget> children) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columnCount) {
      final rowChildren = children.skip(i).take(columnCount).toList();
      while (rowChildren.length < columnCount) {
        rowChildren.add(const SizedBox());
      }
      rows.add(
        Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: rowChildren,
        ),
      );
    }
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: rows,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🖥️ RESPONSIVE ROW — ردیف واکنش‌گرا
/// تبدیل به ستون در موبایل
/// ═══════════════════════════════════════════════════════════

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }
    
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 📐 ASPECT RATIO BOX — باکس با نسبت تصویر ثابت
/// ═══════════════════════════════════════════════════════════

class AspectRatioBox extends StatelessWidget {
  final Widget child;
  final double aspectRatio;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AspectRatioBox({
    super.key,
    required this.child,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = AspectRatio(
      aspectRatio: aspectRatio,
      child: child,
    );
    
    if (borderRadius != null) {
      content = ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }
    
    return content;
  }
}

/// ═══════════════════════════════════════════════════════════
/// 📏 SIZE AWARE BUILDER — سازنده آگاه از سایز
/// دسترسی به سایز فعلی در هر نقطه از ویجت‌ها
/// ═══════════════════════════════════════════════════════════

class SizeAwareBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Size size) builder;

  const SizeAwareBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(
          context,
          Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// 🎚️ BREAKPOINT HELPER — کمک‌کننده نقاط شکست
/// ═══════════════════════════════════════════════════════════

class Breakpoint {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktop!) return desktop;
    if (width >= tablet!) return tablet;
    return mobile;
  }
}
