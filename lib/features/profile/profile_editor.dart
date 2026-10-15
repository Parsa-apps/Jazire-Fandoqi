import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/island_kit.dart';

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
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) => Container(
        decoration: const BoxDecoration(
          // پوستهٔ کاغذیِ دنیای جزیره، هم‌زبان با بقیهٔ صفحه‌ها
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDF7),
              Color(0xFFFFF6E0),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            16,
            22,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.stars_rounded,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'پروفایل قهرمان کوچولو',
                      style: AppFonts.kids(
                        color: const Color(0xFF4A2875),
                        fontSize: 24,
                      ),
                    ),
                  ],
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
                const SizedBox(height: 18),
                // ── Avatar preview with glow ──
                Container(
                  width: 108,
                  height: 108,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFF472B6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFFF472B6).withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 4,
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
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
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
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => selectedAvatar = asset);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
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
                                            .withOpacity(0.3),
                                        blurRadius: 10,
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
                // ── Name field ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: name,
                    maxLength: 24,
                    decoration: InputDecoration(
                      labelText: 'نام کودک (اختیاری)',
                      hintText: 'بدون نام هم می‌تونی بازی کنی!',
                      prefixIcon: Icon(Icons.badge_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ── Age slider ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.cake_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'سن کودک',
                              style: AppFonts.vazirmatn(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: const Color(0xFF3D3450),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.12),
                                  const Color(0xFFF472B6).withOpacity(0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$selectedAge سال',
                              style: AppFonts.kids(
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.primary.withOpacity(0.15),
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withOpacity(0.15),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: selectedAge.toDouble(),
                          min: 3,
                          max: 12,
                          divisions: 9,
                          label: '$selectedAge سال',
                          onChanged: (value) => setState(
                            () => selectedAge = value.round(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: IslandKidButton(
                    label: 'ذخیره پروفایل',
                    icon: Icons.check_circle_rounded,
                    onPressed: () {
                      GameData.updateProfile(
                        name: name.text,
                        avatarIcon: selectedAvatar,
                        age: selectedAge,
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  name.dispose();
}
