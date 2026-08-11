import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../core/growth/growth.dart';

class SiblingSwitcher extends StatelessWidget {
  const SiblingSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final siblings = SiblingProfiles.all;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('کودکان این گوشی', style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 8),
        const Text(
          'تا ۳ پروفایل جدا. تعویض، پیشرفت را جدا نگه می‌دارد.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in siblings)
              ChoiceChip(
                selected: s['id'] == SiblingProfiles.activeId,
                label: Text('${s['avatar'] ?? '🧒'} ${s['name'] ?? ''}'),
                onSelected: (_) {
                  SiblingProfiles.switchTo(s['id'].toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حالا نوبت ${s['name']} است')),
                  );
                },
              ),
            if (siblings.length < SiblingProfiles.maxSiblings)
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('کودک تازه'),
                onPressed: () => _addDialog(context),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _addDialog(BuildContext context) async {
    final name = TextEditingController();
    var age = 5;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('پروفایل کودک تازه'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'نام یا لقب'),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setLocal) => Row(
                children: [
                  const Text('سن تقریبی'),
                  Expanded(
                    child: Slider(
                      min: 3,
                      max: 8,
                      divisions: 5,
                      value: age.toDouble(),
                      label: '$age',
                      onChanged: (v) => setLocal(() => age = v.round()),
                    ),
                  ),
                  Text('$age'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ساخت')),
        ],
      ),
    );
    final created = ok == true &&
        SiblingProfiles.add(name: name.text, age: age);
    name.dispose();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(created ? 'پروفایل ساخته شد' : 'ساخت پروفایل ممکن نشد')),
    );
  }
}
