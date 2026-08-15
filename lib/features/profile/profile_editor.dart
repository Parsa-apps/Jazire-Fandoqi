import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
import '../../core/game_data.dart';

const List<String> _avatarNames = [
  'روباه کوچولو',
  'پاندای مهربان',
  'خرگوش ناز',
  'کوآلای خندان',
  'شیر شجاع',
  'قورباغهٔ شاد',
  'پنگوئن بازیگوش',
  'جغد دانا',
  'گربهٔ پشمالو',
  'توله‌سگ بامزه',
  'دختر هنرمند',
  'پسر خندان',
  'دختر گل‌به‌سر',
  'پسر عینکی',
  'دختر مو‌بافته',
  'پسر ماجراجو',
  'خرگوش نقاش',
  'دایناسور ریاضی‌دان',
  'جغد استاد',
  'پنگوئن کتاب‌خوان',
];

/// Opens the local-only profile editor.
///
/// Profile imagery is deliberately limited to bundled avatars. This screen
/// never requests gallery, camera or media permissions.
Future<void> showProfileEditor(BuildContext context) async {
  final name = TextEditingController(text: GameData.childName);
  String selectedAvatar = GameData.avatar;
  int selectedAge = GameData.childAge;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'پروفایل قهرمان کوچولو',
                style: AppFonts.kids(
                  color: const Color(0xFF4A2875),
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'یکی از ۲۰ آواتار بامزه را انتخاب کنید',
                style: AppFonts.vazirmatn(
                  color: const Color(0xFF776A80),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFF472B6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: selectedAvatar.startsWith('assets/')
                      ? Image.asset(selectedAvatar, fit: BoxFit.cover)
                      : ColoredBox(
                          color: const Color(0xFFF2ECFF),
                          child: Center(
                            child: Text(
                              selectedAvatar,
                              style: const TextStyle(fontSize: 44),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 20,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 9,
                  crossAxisSpacing: 9,
                ),
                itemBuilder: (context, index) {
                  final asset = 'assets/avatars/avatar_$index.webp';
                  final active = selectedAvatar == asset;
                  return Semantics(
                    button: true,
                    selected: active,
                    label: 'انتخاب آواتار ${_avatarNames[index]}',
                    child: Tooltip(
                      message: _avatarNames[index],
                      child: GestureDetector(
                        key: ValueKey('profile_avatar_$index'),
                        onTap: () => setState(() => selectedAvatar = asset),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? const Color(0xFFEDE4FF)
                                : Colors.transparent,
                            border: Border.all(
                              color: active
                                  ? const Color(0xFF6C43D9)
                                  : const Color(0xFFE2D9EA),
                              width: active ? 3 : 1,
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF6C43D9)
                                          .withOpacity(0.25),
                                      blurRadius: 9,
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipOval(
                            child: Image.asset(asset, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: name,
                maxLength: 24,
                decoration: const InputDecoration(
                  labelText: 'نام کودک',
                  prefixIcon: Icon(Icons.badge_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.cake_rounded,
                    color: Color(0xFF6C43D9),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'سن کودک',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '$selectedAge سال',
                    style: const TextStyle(
                      color: Color(0xFF6C43D9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: selectedAge.toDouble(),
                min: 3,
                max: 12,
                divisions: 9,
                activeColor: const Color(0xFF6C43D9),
                label: '$selectedAge سال',
                onChanged: (value) => setState(
                  () => selectedAge = value.round(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    GameData.updateProfile(
                      name: name.text,
                      avatarIcon: selectedAvatar,
                      age: selectedAge,
                    );
                    Navigator.pop(sheetContext);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C43D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: AppFonts.kids(fontSize: 18),
                  ),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('ذخیره پروفایل'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  name.dispose();
}
