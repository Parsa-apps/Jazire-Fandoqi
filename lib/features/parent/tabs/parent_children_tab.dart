import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../widgets/parent_widgets.dart';

/// تب کودکان: مدیریت تا ۳ پروفایل خواهر/برادر با پیشرفت جدا.
class ParentChildrenTab extends StatefulWidget {
  const ParentChildrenTab({super.key});

  @override
  State<ParentChildrenTab> createState() => _ParentChildrenTabState();
}

class _ParentChildrenTabState extends State<ParentChildrenTab> {
  static const List<String> _avatars = [
    '🧒', '👦', '👧', '🧑', '👶', '🐻', '🐰', '🦊', '🐼', '🦁', '🐯', '🐨',
  ];

  late final TextEditingController _nameController =
      TextEditingController(text: GameData.childName);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final siblings = SiblingProfiles.all;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '👨\u200d👩\u200d👧',
                title: 'پروفایل کودکان',
                subtitle:
                    'تا ۳ کودک روی همین گوشی، هر کدام با پیشرفت جدا. کودک فعال کسی است که الان بازی می‌کند.',
              ),
              const SizedBox(height: 8),
              for (final s in siblings) ...[
                _profileTile(s, s['id'] == SiblingProfiles.activeId),
                const SizedBox(height: 10),
              ],
              if (siblings.length < SiblingProfiles.maxSiblings)
                OutlinedButton.icon(
                  onPressed: _showAddChild,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                      'افزودن کودک (${PersianDigits.toFa(siblings.length)}/${PersianDigits.toFa(SiblingProfiles.maxSiblings)})'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // کودک فعال
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '✏️',
                title: 'ویرایش کودک فعال',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'نام کودک',
                  hintText: 'مثلاً: علی',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onSubmitted: (v) {
                  GameData.updateProfile(name: v.trim());
                  SiblingProfiles.syncActiveMeta();
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              Text('سن: ${PersianDigits.toFa(GameData.childAge)} ساله',
                  style: AppFonts.vazirmatn(fontWeight: FontWeight.w800)),
              Slider(
                min: 3,
                max: 8,
                divisions: 5,
                value: GameData.childAge.toDouble().clamp(3.0, 8.0),
                label: '${PersianDigits.toFa(GameData.childAge)} ساله',
                onChanged: (v) {
                  GameData.childAge = v.round();
                  GameData.save();
                  SiblingProfiles.syncActiveMeta();
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Text('آواتار', style: AppFonts.vazirmatn(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in _avatars)
                    GestureDetector(
                      onTap: () {
                        GameData.updateProfile(avatarIcon: a);
                        SiblingProfiles.syncActiveMeta();
                        setState(() {});
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: GameData.avatar == a
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: GameData.avatar == a
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(a, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileTile(Map<String, Object?> s, bool active) {
    final name = (s['name'] ?? '').toString();
    final avatar = (s['avatar'] ?? '🧒').toString();
    final age = (s['age'] is num) ? (s['age'] as num).toInt() : 5;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? AppColors.primary : Colors.grey.withOpacity(0.2),
          width: active ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text(avatar, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppFonts.vazirmatn(
                        fontWeight: FontWeight.w900, fontSize: 15)),
                Text('${PersianDigits.toFa(age)} ساله',
                    style: AppFonts.vazirmatn(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (active)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('فعال',
                  style: AppFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            )
          else
            TextButton(
              onPressed: () {
                SiblingProfiles.switchTo(s['id'].toString());
                _nameController.text = GameData.childName;
                setState(() {});
              },
              child: const Text('انتخاب'),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddChild() async {
    final nameCtrl = TextEditingController();
    int age = 5;
    String avatar = '🧒';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('افزودن کودک جدید',
                  style: AppFonts.vazirmatn(
                      fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'نام کودک',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              Text('سن: ${PersianDigits.toFa(age)} ساله'),
              Slider(
                min: 3,
                max: 8,
                divisions: 5,
                value: age.toDouble(),
                onChanged: (v) => setSheet(() => age = v.round()),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in _avatars)
                    GestureDetector(
                      onTap: () => setSheet(() => avatar = a),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: avatar == a
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: avatar == a
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(a, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final ok = SiblingProfiles.add(
                      name: nameCtrl.text,
                      age: age,
                      avatar: avatar,
                    );
                    if (ok) {
                      final id = SiblingProfiles.all.last['id'].toString();
                      SiblingProfiles.switchTo(id);
                      _nameController.text = nameCtrl.text.trim();
                      Navigator.pop(ctx);
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('نام را وارد کنید یا ظرفیت پر است')),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('افزودن'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(nameCtrl.dispose);
  }
}
