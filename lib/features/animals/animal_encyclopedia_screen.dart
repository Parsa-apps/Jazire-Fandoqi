import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../core/learning_content/learning_topics.dart';
import '../../shared/widgets/fandoghi_premium.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🦁 ANIMAL ENCYCLOPEDIA PREMIUM — پیشنهاد ۲۲
/// دایره‌المعارف ۳۰ حیوان ایران با زیستگاه، صدا، نکته و پازل
/// ═══════════════════════════════════════════════════════════════
class AnimalEncyclopediaScreen extends StatefulWidget {
  const AnimalEncyclopediaScreen({super.key});

  @override
  State<AnimalEncyclopediaScreen> createState() => _AnimalEncyclopediaState();
}

class _AnimalEncyclopediaState extends State<AnimalEncyclopediaScreen> {
  String _filter = 'همه';
  static const List<String> _filters = ['همه', 'پستاندار', 'پرنده', 'خزنده', 'دریایی'];

  // دسته‌بندی دستی برای ۳۰ حیوان
  String _categoryOf(String name) {
    const mammals = {'یوزپلنگ', 'خرس قهوه‌ای', 'روباه', 'گرگ', 'پلنگ', 'آهو', 'قوچ', 'بز کوهی', 'گوزن', 'خرگوش', 'جوجه‌تیغی', 'سنجاب', 'موش', 'گربه', 'سگ', 'اسب', 'الاغ', 'شتر', 'گاو', 'گوسفند'};
    const birds = {'مرغ', 'خروس', 'اردک', 'غاز', 'کبوتر', 'گنجشک', 'عقاب', 'شاهین'};
    const reptile = {'لاک‌پشت'};
    const sea = {'ماهی'};
    if (mammals.contains(name)) return 'پستاندار';
    if (birds.contains(name)) return 'پرنده';
    if (reptile.contains(name)) return 'خزنده';
    if (sea.contains(name)) return 'دریایی';
    return 'پستاندار';
  }

  String _habitatOf(String name) {
    const map = {
      'یوزپلنگ': 'دشت‌های مرکزی — در خطر انقراض!',
      'خرس قهوه‌ای': 'جنگل‌های البرز و زاگرس',
      'روباه': 'بیابان و جنگل',
      'پلنگ': 'کوهستان‌های ایران',
      'آهو': 'دشت و استپ',
      'گوزن': 'جنگل‌های شمال',
      'شتر': 'کویر لوت',
      'لاک‌پشت': 'سواحل جنوبی',
      'عقاب': 'قله‌های بلند',
      'ماهی': 'دریای خزر',
    };
    return map[name] ?? 'سراسر ایران';
  }

  @override
  void initState() {
    super.initState();
    FandoghiCoach.enablePersistentPresence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FandoghiCoach.say('به دنیای حیوانات ایران خوش اومدی! 🦁 هر حیوان یه قصه داره — بزن روش تا صداشو بشنوی!', mood: FandoghiMood.excited, duration: const Duration(seconds: 4));
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = learningTopics.firstWhere((t) => t.id == 'animals');
    final filtered = _filter == 'همه' ? topic.cards : topic.cards.where((c) => _categoryOf(c.name) == _filter).toList();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.forest),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(topic.cards.length),
              _buildFilterBar(),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.82),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final card = filtered[index];
                    final isLearned = (GameData.skills['animals'] ?? 0) > index;
                    return _AnimalCard(
                      card: card,
                      index: index,
                      isLearned: isLearned,
                      habitat: _habitatOf(card.name),
                      category: _categoryOf(card.name),
                      onTap: () => _openDetail(card),
                    ).animate(delay: (index * 40).ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: Colors.white30)),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('دنیای حیوانات ایران 🦁', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                Text('$total حیوان بومی — با صدا و زیستگاه', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: AppShadows.soft),
            child: Row(
              children: [
                const Text('🌿', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('${GameData.skills['animals'] ?? 0}/$total', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: _filters.map((f) {
          final selected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _filter = f);
              },
              child: AnimatedContainer(
                duration: AppMotion.fast,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: selected ? Colors.white : Colors.white30),
                  boxShadow: selected ? AppShadows.soft : null,
                ),
                child: Text(f, style: AppFonts.vazirmatn(fontSize: 13, fontWeight: selected ? FontWeight.w900 : FontWeight.w700, color: selected ? const Color(0xFF2D3436) : Colors.white)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openDetail(LearningCard card) {
    HapticFeedback.lightImpact();
    AudioService.tap();
    // TTS ساده
    FandoghiCoach.say('${card.name}! ${card.fact ?? ''} زیستگاهش: ${_habitatOf(card.name)} 🗺️', mood: FandoghiMood.happy, duration: const Duration(seconds: 3));
    GameData.recordAnswer(correct: true, skill: 'animals');
    setState(() {});
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AnimalDetailSheet(card: card, habitat: _habitatOf(card.name), category: _categoryOf(card.name)),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final LearningCard card;
  final int index;
  final bool isLearned;
  final String habitat;
  final String category;
  final VoidCallback onTap;
  const _AnimalCard({required this.card, required this.index, required this.isLearned, required this.habitat, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: isLearned ? const Color(0xFF00B894).withOpacity(0.4) : Colors.black.withOpacity(0.06), width: isLearned ? 2 : 1),
          boxShadow: isLearned ? AppShadows.colored(const Color(0xFF00B894), opacity: 0.18) : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // هدر ایموجی
            Container(
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isLearned ? [const Color(0xFF00B894).withOpacity(0.15), const Color(0xFF00CEC9).withOpacity(0.12)] : [const Color(0xFFFFF0DB), const Color(0xFFFFE5B4)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl - 1)),
              ),
              child: Stack(
                children: [
                  Center(child: Text(card.emoji, style: const TextStyle(fontSize: 52))),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: isLearned ? const Color(0xFF00B894) : Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(AppRadii.pill)),
                      child: Row(
                        children: [
                          Icon(isLearned ? Icons.check_circle_rounded : Icons.play_circle_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(isLearned ? 'شناخته شد' : 'بشنو', style: AppFonts.vazirmatn(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(AppRadii.pill)),
                      child: Text(category, style: AppFonts.vazirmatn(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF636E72))),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.name, style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF2D3436)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(habitat, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  if (card.fact != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(AppRadii.sm), border: Border.all(color: const Color(0xFFFDCB6E).withOpacity(0.3))),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Expanded(child: Text(card.fact!, style: TextStyle(fontSize: 10, color: const Color(0xFF6D4C41), fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(gradient: AppGradients.forest, borderRadius: BorderRadius.circular(AppRadii.md)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('بشنو و ببین', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
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

class _AnimalDetailSheet extends StatelessWidget {
  final LearningCard card;
  final String habitat;
  final String category;
  const _AnimalDetailSheet({required this.card, required this.habitat, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.xl), boxShadow: AppShadows.strong),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(card.emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 8),
            Text(card.name, style: AppFonts.vazirmatn(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436))),
            Text('$category  •  $habitat', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF1F8FF), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: AppColors.primary.withOpacity(0.15))),
              child: Column(
                children: [
                  Row(
                    children: [
                      const FandoghiPremium(size: 48, mood: FandoghiMood.happy, showParticles: false),
                      const SizedBox(width: 12),
                      Expanded(child: Text(card.fact != null ? 'آیا می‌دانستی؟ ${card.fact}' : 'این حیوان زیبا در ایران زندگی می‌کند و خیلی دوست‌داشتنی است!', style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w700, height: 1.6, color: const Color(0xFF2D3436)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // نقشه ایران ساده
                  Container(
                    height: 80,
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: const Color(0xFF00B894).withOpacity(0.3))),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text('🗺️ نقشه زیستگاه', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                        Positioned(
                          right: 20,
                          top: 20,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFFFF6B6B), shape: BoxShape.circle),
                            child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 900.ms),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text('بستن', style: AppFonts.vazirmatn(fontWeight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      // پازل همان حیوان (شبیه‌سازی)
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🧩 پازل ${card.name} به زودی! فعلاً از بخش پازل بازی کن')) );
                    },
                    icon: const Icon(Icons.extension_rounded, size: 18),
                    label: Text('پازل', style: AppFonts.vazirmatn(fontWeight: FontWeight.w900)),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
