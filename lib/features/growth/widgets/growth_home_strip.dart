import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_fonts.dart';
import '../../../app/design_tokens.dart';
import '../../../core/audio_service.dart';
import '../../../core/growth/growth.dart';

/// نوار رشد روی داشبورد: ادامه بازی، چالش هفته، رویداد فصلی، اخیراً.
class GrowthHomeStrip extends StatelessWidget {
  const GrowthHomeStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final event = SeasonalEvents.current();
    final challenge = WeeklyEngine.currentChallenge();
    final recents = ActivityTracker.recent.take(4).toList();
    final decay = ActivityTracker.skillDecayMessage();

    return Column(
      children: [
        if (GrowthStore.lastRoute.isNotEmpty) ...[
          _card(
            context,
            emoji: '▶️',
            title: 'ادامه با فندقی',
            subtitle: GrowthStore.lastTitle.isEmpty ? 'آخرین بازی' : GrowthStore.lastTitle,
            color: const Color(0xFF6C5CE7),
            onTap: () => Navigator.pushNamed(context, GrowthStore.lastRoute),
          ),
          const SizedBox(height: 10),
        ],
        _card(
          context,
          emoji: challenge.emoji,
          title: 'چالش هفته: ${challenge.title}',
          subtitle:
              '${PersianDigits.toFa(GrowthStore.weeklyChallengeProgress)}/${PersianDigits.toFa(challenge.target)} — ${challenge.description}',
          color: const Color(0xFFFF8E53),
          onTap: () => Navigator.pushNamed(context, '/weekly-report'),
        ),
        if (event != null) ...[
          const SizedBox(height: 10),
          _card(
            context,
            emoji: event.emoji,
            title: event.title,
            subtitle: event.message,
            color: const Color(0xFFE91E63),
            onTap: () => Navigator.pushNamed(context, '/life-skills'),
          ),
        ],
        if (decay != null) ...[
          const SizedBox(height: 10),
          _card(
            context,
            emoji: '🌱',
            title: 'یادآوری مهربان',
            subtitle: decay,
            color: const Color(0xFF00B894),
            onTap: () => Navigator.pushNamed(context, '/life-skills'),
          ),
        ],
        if (recents.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recents.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final item = recents[i];
                return ActionChip(
                  label: Text(item.$2, style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w800)),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    AudioService.tap();
                    Navigator.pushNamed(context, item.$1);
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _card(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        onTap: () {
          HapticFeedback.lightImpact();
          AudioService.tap();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 13)),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
