import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/island_world_style.dart';
import '../../core/audio_service.dart';
import 'fandoghi_premium.dart';

/// 🧸 اسکلتِ مشترکِ دنیاهای تازهٔ فندقی
///
/// موسیقی، رنگ‌آمیزی، شعر، قرآن و آزمایشگاه علوم همه از این اسکلت استفاده
/// می‌کنند تا هدرِ برگشت، تیترِ کودکانه، کارتِ کاغذی و دکمه‌های لمسی در
/// همهٔ بخش‌ها دقیقاً یکدست باشند. این کار هم تجربهٔ کودک را ساده‌تر می‌کند
/// و هم نگهداری را ارزان‌تر: یک تغییر در هدر، همهٔ دنیاها را به‌روز می‌کند.
class KidsWorldScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final Widget body;

  /// دکمه‌های اضافهٔ کنارِ شخصیت فندقی (مثلاً نشانِ «همه رایگان»).
  final List<Widget> headerActions;

  /// اگر true باشد، بدنه زیرِ هدر اسکرول نمی‌شود (برای صفحه‌هایی که
  /// خودشان ساختار اسکرول دارند).
  final bool bodyIsScrollable;

  const KidsWorldScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.body,
    this.headerActions = const <Widget>[],
    this.bodyIsScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: gradient.first,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradient,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -70,
              right: -50,
              child: _Blob(
                size: 220,
                color: Colors.white.withOpacity(0.14),
              ),
            ),
            Positioned(
              top: 120,
              left: -70,
              child: _Blob(
                size: 180,
                color: Colors.white.withOpacity(0.09),
              ),
            ),
            Positioned(
              bottom: -90,
              right: -40,
              child: _Blob(
                size: 260,
                color: Colors.black.withOpacity(0.10),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: _KidsWorldHeader(
                      title: title,
                      subtitle: subtitle,
                      emoji: emoji,
                      reduceMotion: reduceMotion,
                      actions: headerActions,
                    ),
                  ),
                  Expanded(
                    child: bodyIsScrollable
                        ? body
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.paddingOf(context).bottom + 20,
                            ),
                            child: body,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KidsWorldHeader extends StatelessWidget {
  const _KidsWorldHeader({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.reduceMotion,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final bool reduceMotion;
  final List<Widget> actions;

  void _goBack(BuildContext context) {
    HapticFeedback.lightImpact();
    AudioService.back();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title — $subtitle',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.34),
            width: 1.4,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.24),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            _HeaderBackButton(onTap: () => _goBack(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.kids(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: const <Shadow>[
                              Shadow(color: Color(0x55000000), blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.vazirmatn(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.84),
                    ),
                  ),
                ],
              ),
            ),
            ...actions,
            const SizedBox(width: 4),
            FandoghiPremium(
              size: 42,
              animated: !reduceMotion,
              showParticles: false,
              showShadow: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'برگشت',
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF8FD6A0), Color(0xFF2E7D4F)],
            ),
            border: Border.all(color: const Color(0xFFD6F5DE), width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}

/// کارتِ کاغذیِ مشترکِ دنیاهای تازه — همان زبانِ بصریِ `IslandPanel` با
/// گوشه‌های نرم‌تر برای صفحه‌های پرجزئیات.
class KidsWorldCard extends StatelessWidget {
  const KidsWorldCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = const Color(0xFFFFFBF0),
    this.borderColor = IslandWorldPalette.honey,
    this.radius = 22,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      ),
    );
  }
}

/// تیترِ بخش‌ها با تایپوگرافیِ کودکانه و یک خطِ نرمِ جداکننده.
class KidsWorldSectionTitle extends StatelessWidget {
  const KidsWorldSectionTitle({
    super.key,
    required this.title,
    this.emoji,
    this.trailing,
  });

  final String title;
  final String? emoji;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: <Widget>[
          if (emoji != null) ...<Widget>[
            Text(emoji!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.kids(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: const <Shadow>[
                  Shadow(color: Color(0x55000000), blurRadius: 5),
                ],
              ),
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 8),
            trailing!,
          ],
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1.2,
              color: Colors.white.withOpacity(0.28),
            ),
          ),
        ],
      ),
    );
  }
}

/// دکمهٔ اصلیِ دنیاهای تازه؛ بزرگ، گرد و با بازخوردِ لمسی.
class KidsWorldButton extends StatelessWidget {
  const KidsWorldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.emoji,
    this.color = IslandWorldPalette.honey,
    this.textColor = const Color(0xFF3B2A00),
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? emoji;
  final Color color;
  final Color textColor;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: label,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(18),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed == null
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    AudioService.tap();
                    onPressed!();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (emoji != null) ...<Widget>[
                    Text(emoji!, style: const TextStyle(fontSize: 19)),
                    const SizedBox(width: 7),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.kids(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: textColor,
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
    return button;
  }
}

/// نشانِ کوچک و روشن برای بالای کارت‌ها («رایگان»، «نسخهٔ کامل» و...).
class KidsWorldBadge extends StatelessWidget {
  const KidsWorldBadge({
    super.key,
    required this.label,
    this.background = const Color(0xFFFFF3C4),
    this.foreground = const Color(0xFF6B4E00),
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: AppFonts.vazirmatn(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

/// راهنمای کوچکِ پایینِ صفحه‌ها؛ برای یادآوریِ «همه‌چیز آفلاین است».
class KidsWorldOfflineNote extends StatelessWidget {
  const KidsWorldOfflineNote({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.wifi_off_rounded, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text ?? 'همه‌چیز داخل برنامه و بدون اینترنت کار می‌کند.',
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// فضای خالیِ پایانی برای اینکه آخرین کارت زیرِ نوار پایین پنهان نشود.
class KidsWorldBottomSpacer extends StatelessWidget {
  const KidsWorldBottomSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.paddingOf(context).bottom + 22);
  }
}
