import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../app/design_tokens.dart';
import '../../../core/growth/parent_insights.dart';

/// کارت پایه‌ی مرکز والدین با گوشه‌های گرد و سایه‌ی نرم.
class ParentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  const ParentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null
                ? (color ?? (isDark ? const Color(0xFF1E1E2E) : Colors.white))
                : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFEEECF6),
            ),
            boxShadow: gradient == null ? AppShadows.soft : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// عنوان بخش با آیکون.
class SectionTitle extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionTitle({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFonts.vazirmatn(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppFonts.vazirmatn(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// نوار پیشرفت افقی با برچسب.
class LabeledProgress extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final String? label;
  final String? trailing;
  final double height;
  const LabeledProgress({
    super.key,
    required this.value,
    required this.color,
    this.label,
    this.trailing,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || trailing != null) ...[
          Row(
            children: [
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: AppFonts.vazirmatn(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: AppFonts.vazirmatn(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height * 2),
          child: LinearProgressIndicator(
            value: v,
            minHeight: height,
            backgroundColor: color.withOpacity(0.13),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// اعلان/توصیه با لحن رنگی.
class ToneBanner extends StatelessWidget {
  final String emoji;
  final String title;
  final String? body;
  final ColorTone tone;
  final VoidCallback? onAction;
  final String? actionLabel;
  const ToneBanner({
    super.key,
    required this.emoji,
    required this.title,
    this.body,
    this.tone = ColorTone.neutral,
    this.onAction,
    this.actionLabel,
  });

  static Color colorOf(ColorTone tone) => switch (tone) {
        ColorTone.good => const Color(0xFF00B894),
        ColorTone.ok => AppColors.primary,
        ColorTone.warn => const Color(0xFFE17055),
        ColorTone.neutral => const Color(0xFF636E72),
      };

  @override
  Widget build(BuildContext context) {
    final c = colorOf(tone);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withOpacity(0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.vazirmatn(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.4,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    body!,
                    style: AppFonts.vazirmatn(
                      fontSize: 12.5,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: c,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text(actionLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ردیف تنظیم با سوییچ.
class ParentSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final bool enabled;
  const ParentSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: enabled ? onChanged : null,
        secondary: icon == null
            ? null
            : Icon(icon, color: AppColors.primary, size: 22),
        title: Text(
          title,
          style: AppFonts.vazirmatn(fontSize: 14.5, fontWeight: FontWeight.w800),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: AppFonts.vazirmatn(fontSize: 12, height: 1.5),
              ),
      ),
    );
  }
}

/// دکمه‌ی تخت برای نوار ابزار والد.
class ParentActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final bool filled;
  const ParentActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.color = AppColors.primary,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: filled ? color : color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: filled ? Colors.white : color, size: 24),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 76,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.vazirmatn(
              fontSize: 11,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: filled ? color : color,
            ),
          ),
        ),
      ],
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: child,
    );
  }
}
