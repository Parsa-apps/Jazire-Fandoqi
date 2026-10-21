import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jazireh_fandoghi/shared/widgets/animated_gold_lock.dart';
import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/content_access_policy.dart';
import '../../core/fandoghi_coach.dart';
import '../../core/fandoghi_models.dart';
import '../../core/game_data.dart';
import '../../core/growth/persian_digits.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/today_complete_sheet.dart';
import '../shop/full_version_paywall.dart';
import '../shop/content_lock.dart';

/// 🔢 NUMBERS HUB PREMIUM — دنیای اعداد و دست‌ورزی ریاضی اول دبستان (مطابقِ `04_numbers_phone.png`).
class NumbersHubScreen extends StatefulWidget {
  const NumbersHubScreen({super.key});
  @override
  State<NumbersHubScreen> createState() => _NumbersHubState();
}

class _NumbersHubState extends State<NumbersHubScreen> {
  int _selectedNumber = 1;
  int _quizTarget = 3;
  bool _hasFullVersion = false;

  @override
  void dispose() {
    Monetization.accessStatus.removeListener(_syncFullVersionAccess);
    super.dispose();
  }

  void _syncFullVersionAccess() {
    if (!mounted) return;
    final has = Monetization.accessStatus.value.isVerified;
    if (has != _hasFullVersion) setState(() => _hasFullVersion = has);
  }

  @override
  void initState() {
    super.initState();
    Monetization.accessStatus.addListener(_syncFullVersionAccess);
    FandoghiCoach.enablePersistentPresence();
    _refreshEntitlement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FandoghiCoach.say(
        'به دنیای اعداد و ریاضی اول دبستان خوش اومدی! سیب‌ها را بشمار و عدد درست را انتخاب کن 🍎🔢',
        mood: FandoghiMood.excited,
        duration: const Duration(seconds: 4),
      );
    });
  }

  bool _isLocked(int number) =>
      !_hasFullVersion && !ContentAccessPolicy.isNumberFree(number);

  Future<bool> _refreshEntitlement() async {
    final hasFullVersion = await Monetization.hasFullVersion();
    if (mounted && hasFullVersion != _hasFullVersion) {
      setState(() => _hasFullVersion = hasFullVersion);
    }
    return hasFullVersion;
  }

  Future<void> _selectNumber(int number) async {
    HapticFeedback.selectionClick();
    if (!ContentAccessPolicy.isNumberFree(number) &&
        !await Monetization.hasFullVersion()) {
      if (!mounted) return;
      await showFullVersionPaywall(context, featureName: 'عدد $number');
      if (!mounted || !await _refreshEntitlement()) return;
    }
    if (!mounted) return;
    setState(() => _selectedNumber = number);
    AudioService.speakNumber(number);
  }

  List<int> get _quizOptions {
    final base = _quizTarget.clamp(2, 5);
    return <int>[base - 1, base, base + 1];
  }

  Future<void> _answerCountingQuiz(int chosen) async {
    HapticFeedback.mediumImpact();
    if (chosen == _quizTarget) {
      GameData.stars += 20;
      await showTodayCompleteSheet(context, bonusStars: 20);
      if (!mounted) return;
      setState(() {
        _quizTarget = (_quizTarget % 4) + 2; // چرخش بین ۲ تا ۵ سیب
      });
    } else {
      AudioService.wrong();
      FandoghiCoach.say(
        'دوباره سیب‌ها را با دقت بشمار قهرمان! 🍎',
        mood: FandoghiMood.thinking,
        duration: const Duration(seconds: 2),
      );
    }
  }

  String _countLabel(int n) {
    if (n <= 0) return '';
    if (n <= 10) return List<String>.filled(n, '●').join(' ');
    if (n < 20) return 'یک ده و ${PersianDigits.toFa(n - 10)} یکی';
    return 'دو ده';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/theme_v2/alphabet_meadow_bg.webp',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF29B6F6),
                    Color(0xFF81D4FA),
                    Color(0xFF66BB6A),
                    Color(0xFF2E7D32),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF072B36).withOpacity(0.18),
                  const Color(0xFF0A3822).withOpacity(0.55),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                ContentAccessNotice(
                  featureName: 'اعداد',
                  freeCount: ContentAccessPolicy.freeNumberCount,
                  totalCount: 20,
                  hasFullVersion: _hasFullVersion,
                  onUnlocked: () async {
                    await _refreshEntitlement();
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        _buildAppleCountingCard(),
                        const SizedBox(height: 10),
                        _buildMathActivitiesRow(),
                        const SizedBox(height: 10),
                        _buildLargeNumberCard(),
                        const SizedBox(height: 10),
                        _buildNumbersGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final stars = GameData.stars > 0 ? GameData.stars : 120;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF7),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFFFD54F), width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اعداد',
                    style: AppFonts.kids(
                      color: const Color(0xFF1B5E20),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'دنیای اعداد و ریاضی اول 🔢',
                      style: AppFonts.vazirmatn(
                        color: const Color(0xFF4E342E),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [Color(0xD8124B5A), Color(0xEC082933)],
              ),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 4),
                Text(
                  PersianDigits.toFa(stars),
                  style: AppFonts.kids(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFF59D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// کارتِ سه‌بعدیِ شمارشِ سیب‌ها: «چند عدد است؟» (مطابقِ `04_numbers_phone.png`)
  Widget _buildAppleCountingCard() {
    final options = _quizOptions;
    const optionGradients = <List<Color>>[
      [Color(0xFF4FC3F7), Color(0xFF0288D1)],
      [Color(0xFF81C784), Color(0xFF2E7D32)],
      [Color(0xFFFFB74D), Color(0xFFE65100)],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF7),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFFD54F), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: List<Widget>.generate(
                    _quizTarget,
                    (int i) => Image.asset(
                      'assets/theme_v2/apple_3d.webp',
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Text('🍎', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'چند عدد است؟',
                  style: AppFonts.kids(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List<Widget>.generate(options.length, (int idx) {
              final val = options[idx];
              final colors = optionGradients[idx % optionGradients.length];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () => _answerCountingQuiz(val),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: colors,
                        ),
                        border: Border.all(color: Colors.white, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: colors.last.withOpacity(0.55),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          PersianDigits.toFa(val),
                          style: AppFonts.kids(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMathActivitiesRow() {
    final activities = [
      ('جمع و تفریق', '➕', const Color(0xFFD84315), '/math/add', 'جمع'),
      ('قاب ده‌تایی', '🟥', const Color(0xFFC0392B), '/math/ten-frame', 'قاب ده‌تایی'),
      ('تمساح', '🐊', const Color(0xFF2E7D32), '/math/compare', 'تمساح'),
      ('ساعت', '🕐', const Color(0xFF1565C0), '/math/clock', 'ساعت'),
      ('چوب‌خط', '🥢', const Color(0xFF2980B9), '/math/tally', 'چوب‌خط'),
      ('ارزش مکانی', '🧮', const Color(0xFF8E44AD), '/math/place-value', 'ارزش مکانی'),
      ('محور اعداد', '🐸', const Color(0xFF16A085), '/math/number-line', 'محور اعداد'),
      ('تقارن', '🦋', const Color(0xFFD35400), '/math/symmetry', 'تقارن'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: activities.map((act) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () async {
                HapticFeedback.selectionClick();
                final allowed = await ensureContentAccess(
                  context,
                  featureName: act.$1,
                  isFree: ContentAccessPolicy.isGameFree(act.$5),
                );
                if (!allowed || !mounted) return;
                await _refreshEntitlement();
                if (mounted) Navigator.pushNamed(context, act.$4);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  boxShadow: AppShadows.soft,
                  border: Border.all(color: act.$3.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_hasFullVersion && !ContentAccessPolicy.isGameFree(act.$5)) ...[
                      const AnimatedGoldLock(size: 24),
                      const SizedBox(width: 4),
                    ],
                    Text(act.$2, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      act.$1,
                      style: AppFonts.vazirmatn(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: act.$3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLargeNumberCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.medium,
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: AppGradients.sunset,
              shape: BoxShape.circle,
              boxShadow: AppShadows.colored(const Color(0xFFFF6B00)),
            ),
            child: Center(
              child: Text(
                PersianDigits.toFa(_selectedNumber),
                style: AppFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عدد ${PersianDigits.toFa(_selectedNumber)}',
                  style: AppFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4E342E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _countLabel(_selectedNumber),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    AudioService.speakNumber(_selectedNumber);
                    FandoghiCoach.say(
                      '${PersianDigits.toFa(_selectedNumber)} — ${_countLabel(_selectedNumber)}',
                      mood: FandoghiMood.excited,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: const Color(0xFFE65100).withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFFE65100)),
                        const SizedBox(width: 4),
                        Text(
                          'بشنو',
                          style: AppFonts.vazirmatn(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildNumbersGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        final n = index + 1;
        final locked = _isLocked(n);
        final selected = _selectedNumber == n && !locked;

        return GestureDetector(
          onTap: () => _selectNumber(n),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFE65100)
                  : locked
                      ? const Color(0xFF4E342E).withOpacity(0.78)
                      : Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: selected
                    ? Colors.white
                    : locked
                        ? Colors.white38
                        : Colors.white.withOpacity(0.5),
                width: selected ? 2.5 : 1,
              ),
              boxShadow: selected
                  ? AppShadows.colored(
                      const Color(0xFFE65100),
                      opacity: 0.3,
                    )
                  : AppShadows.soft,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  PersianDigits.toFa(n),
                  style: AppFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: selected
                        ? Colors.white
                        : locked
                            ? Colors.white70
                            : const Color(0xFF4E342E),
                  ),
                ),
                if (locked)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: AnimatedGoldLock(size: 24),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
