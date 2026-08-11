import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/growth/growth.dart';
import '../../shared/widgets/premium_button.dart';

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تازه‌های نسخه ${WhatsNew.version}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final item in WhatsNew.items)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$1, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$2, style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(item.$3, style: const TextStyle(height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          PremiumButton(
            text: 'باشه، بریم بازی',
            onPressed: () {
              GrowthStore.markWhatsNewSeen();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
