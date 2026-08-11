import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/game_data.dart';
import '../../core/growth/growth.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final certs = CertificateBuilder.all();
    return Scaffold(
      appBar: AppBar(title: const Text('گواهی‌های افتخار')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: certs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = certs[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.earned ? const Color(0xFFFFF8E1) : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: c.earned ? const Color(0xFFFFD700) : Colors.black12,
                width: 1.6,
              ),
            ),
            child: Row(
              children: [
                Text(c.emoji, style: TextStyle(fontSize: 36, color: c.earned ? null : Colors.black26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.title, style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(c.requirement, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                if (c.earned)
                  IconButton(
                    tooltip: 'کپی متن گواهی',
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: c.shareText(GameData.childName)),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('متن گواهی کپی شد')),
                        );
                      }
                    },
                    icon: const Icon(Icons.ios_share_rounded),
                  )
                else
                  const Icon(Icons.lock_outline_rounded, color: Colors.black26),
              ],
            ),
          );
        },
      ),
    );
  }
}
