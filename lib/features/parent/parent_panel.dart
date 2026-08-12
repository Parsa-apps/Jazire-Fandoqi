import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/app_colors.dart';
import '../../app/design_tokens.dart';
import 'package:jazireh_fandoghi/app/app_fonts.dart';
import '../../core/ai_system.dart';
import '../../core/app_legal.dart';
import '../../core/backup_service.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/skill_radar_chart.dart';
import '../../data/datasources/crash_report_store.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../shared/widgets/theme_selector_widget.dart';
import '../../shared/widgets/parsa_gold_aura.dart';
import '../../shared/widgets/premium_button.dart';
import '../../core/parental_health_radar.dart';
import '../../core/growth/growth.dart';
import '../growth/widgets/screen_time_chart.dart';
import '../growth/widgets/sibling_switcher.dart';

/// =======================================================
/// 👨‍👩‍👧 PREMIUM ADVANCED PARENT CONTROL SYSTEM
/// =======================================================
class ParentPanel extends ConsumerStatefulWidget {
  const ParentPanel({super.key});

  @override
  ConsumerState<ParentPanel> createState() => _ParentPanelState();
}

class _ParentPanelState extends ConsumerState<ParentPanel>
    with WidgetsBindingObserver {
  late int _timeLimit;
  bool _isUnlocked = false;
  Timer? _lockTimer; // فاز ۶۱: قفل خودکار بعد از ۲ دقیقه
  int _failedPinAttempts = 0;
  DateTime? _pinLockedUntil;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timeLimit = GameData.timeLimitMinutes;
    _isUnlocked = false;
    _armLockTimer();
  }

  /// فاز ۶۱: بعد از ۲ دقیقه بی‌فعالیتی، پنل دوباره قفل می‌شود.
  void _armLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer(const Duration(minutes: 2), () {
      if (mounted && _isUnlocked) {
        setState(() => _isUnlocked = false);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // فاز ۶۱: برگشت از پس‌زمینه = دوباره قفل
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (mounted && _isUnlocked) {
        setState(() => _isUnlocked = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockTimer?.cancel();
    super.dispose();
  }

  bool get _isPinCoolingDown {
    final until = _pinLockedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  Future<String?> _askPin({
    required String title,
    required String subtitle,
  }) async {
    final controller = TextEditingController();
    try {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '••••',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                if (RegExp(r'^\d{4}$').hasMatch(controller.text)) {
                  Navigator.pop(ctx, controller.text);
                }
              },
              child: const Text('تایید'),
            ),
          ],
        ),
      );
      return result;
    } finally {
      controller.dispose();
    }
  }

  // ==================== PIN ENTRY ====================
  Future<void> _showPinDialog() async {
    if (_isPinCoolingDown) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً کمی صبر کنید و دوباره تلاش کنید')),
      );
      return;
    }
    if (!GameData.hasParentPin()) {
      await _setupPin();
      return;
    }
    final pin = await _askPin(
      title: '🔒 ورود والدین',
      subtitle: 'لطفاً پین ۴ رقمی خود را وارد کنید',
    );
    if (pin == null || !mounted) return;
    if (GameData.verifyParentPin(pin)) {
      setState(() {
        _failedPinAttempts = 0;
        _pinLockedUntil = null;
        _isUnlocked = true;
      });
      _armLockTimer();
      HapticFeedback.lightImpact();
      return;
    }
    _failedPinAttempts += 1;
    if (_failedPinAttempts >= 5) {
      _failedPinAttempts = 0;
      _pinLockedUntil = DateTime.now().add(const Duration(seconds: 30));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پین چند بار اشتباه بود؛ ۳۰ ثانیه صبر کنید')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پین اشتباه است')),
      );
    }
  }

  Future<void> _setupPin() async {
    final result = await _askPin(
      title: 'تنظیم پین والدین',
      subtitle: 'یک پین ۴ رقمی انتخاب کنید. این پین بعد از بستن اپ هم می‌ماند.',
    );
    if (result == null || !mounted) return;
    if (!GameData.setParentPin(result)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پین باید دقیقاً ۴ رقم باشد')),
      );
      return;
    }
    setState(() => _isUnlocked = true);
    _armLockTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('پین با موفقیت ذخیره شد')),
    );
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    // فاز ۳: واکنش به وضعیت از طریق Riverpod
    ref.watch(gameStateProvider);
    if (!_isUnlocked) {
      return Scaffold(
        appBar: AppBar(title: const Text('پنل والدین')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              const Text('این بخش فقط برای والدین است'),
              const SizedBox(height: 32),
              PremiumButton(
                text: 'ورود با پین',
                onPressed: _showPinDialog,
                icon: Icons.lock_open_rounded,
              ),
              const SizedBox(height: 16),
              if (!GameData.hasParentPin())
                TextButton(
                  onPressed: _setupPin,
                  child: const Text('تنظیم پین جدید'),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل والدین پیشرفته'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => setState(() => _isUnlocked = false),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ==================== STATS ====================
          _buildStatsCard(),

          const SizedBox(height: 24),

          // ==================== THEME SELECTOR ====================
          _buildThemeSelectorCard(),

          const SizedBox(height: 24),

          // ==================== HEALTH RADAR ====================
          _buildHealthRadarCard(),

          const SizedBox(height: 24),

          const ScreenTimeChart(),

          const SizedBox(height: 24),

          _buildGrowthControlsCard(),

          const SizedBox(height: 24),

          const SiblingSwitcher(),

          const SizedBox(height: 24),

          _buildParentToolsCard(),

          const SizedBox(height: 24),

          // ==================== TIME LIMIT ====================
          _buildTimeLimitCard(),

          const SizedBox(height: 24),

          // ==================== ACCESSIBILITY (فاز ۷) ====================
          _buildTextScaleCard(),

          const SizedBox(height: 24),

          // ==================== REPORT ====================
          _buildReportCard(),

          const SizedBox(height: 24),

          // ==================== OFFLINE BACKUP (PR80) ====================
          _buildBackupCard(),

          const SizedBox(height: 24),

          // ==================== PIN MANAGEMENT ====================
          _buildPinCard(),

          const SizedBox(height: 24),

          // ==================== DEBUG LOGS (فاز ۸) ====================
          _buildDebugLogsCard(),
        ],
      ),
    );
  }

  /// فاز ۸: مشاهده گزارش خطاهای آفلاین (برای دیباگ توسط والد).
  Widget _buildDebugLogsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛠️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'گزارش خطاهای دستگاه',
                style: AppFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'این گزارش فقط روی همین دستگاه ذخیره می‌شود و جایی ارسال نمی‌شود.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  text: 'مشاهده گزارش',
                  color: const Color(0xFF5C6BC0),
                  onPressed: _showDebugLogs,
                ),
              ),
              // پیشنهاد پریمیوم ۳: ارسال اختیاری گزارش سلامت به پشتیبانی
              const SizedBox(width: 10),
              Expanded(
                child: PremiumButton(
                  text: 'ارسال به پشتیبانی',
                  color: const Color(0xFF0088CC),
                  onPressed: () => _sendLogsToSupport(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// پیشنهاد پریمیوم ۳: والد می‌تواند لاگ سلامت را با یک تپ به تلگرام
  /// پشتیبانی بفرستد — همیشه اختیاری و کاملاً بدون اطلاعات شخصی.
  Future<void> _sendLogsToSupport() async {
    final logs = await CrashReportStore.getLogs();
    if (!mounted) return;
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هیچ خطایی ثبت نشده؛ نیازی به ارسال نیست 🎉')),
      );
      return;
    }
    final summary = logs.take(10).map((l) {
      final source = (l['source'] ?? 'runtime').toString();
      final raw = (l['message'] ?? '').toString().replaceAll(RegExp(r'\s+'), ' ');
      final safe = raw.length > 80 ? raw.substring(0, 80) : raw;
      return '$source: $safe';
    }).join('\n');
    final text = 'گزارش سلامت جزیره فندقی\n'
        'نسخه: 6.1.0\n'
        '---\n$summary\n'
        '(${logs.length} خطا)';
    final uri = Uri.parse(
      'https://t.me/share/url?url=${Uri.encodeComponent('جزیره فندقی')}&text=${Uri.encodeComponent(text)}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تلگرام نصب نیست؛ آیدی: ${AppLegal.telegramHandle}')),
      );
    }
  }

  Future<void> _showDebugLogs() async {
    final logs = await CrashReportStore.getLogs();
    if (!mounted) return;
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هیچ خطایی ثبت نشده؛ همه‌چیز سالم است 🎉')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'گزارش خطاها (${logs.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await CrashReportStore.clearLogs();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('پاک کردن همه'),
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final time = log['time']?.toString() ?? '';
                  final message = log['message']?.toString() ?? '';
                  final source = log['source']?.toString() ?? '';
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$source — $time',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(message, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGETS ====================
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'گزارش استفاده امروز',
            style: AppFonts.vazirmatn(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('${GameData.todayPlayMinutes}', 'دقیقه بازی'),
              _statItem('${(GameData.cartoonWatchSeconds / 60).round()}', 'دقیقه کارتون'),
              _statItem('${GameData.totalCorrect}', 'پاسخ درست'),
              _statItem('${GameData.averageSuccessRate.toStringAsFixed(0)}%', 'موفقیت'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _buildTimeLimitCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'محدودیت زمانی',
            style: AppFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            '$_timeLimit دقیقه در روز',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'امروز ${GameData.todayPlayMinutes} دقیقه استفاده شده',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  text: '- ۱۵ دقیقه',
                  onPressed: _timeLimit > 15
                      ? () {
                          setState(() => _timeLimit -= 15);
                          GameData.setTimeLimitMinutes(_timeLimit);
                        }
                      : () {},
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PremiumButton(
                  text: '+ ۱۵ دقیقه',
                  onPressed: _timeLimit < 240
                      ? () {
                          setState(() => _timeLimit = (_timeLimit + 15).clamp(15, 240));
                          GameData.setTimeLimitMinutes(_timeLimit);
                        }
                      : () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// فاز ۷: مقیاس فونت قابل تنظیم برای والدین (دسترس‌پذیری).
  Widget _buildTextScaleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔠', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'اندازه متن (دسترس‌پذیری)',
                style: AppFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'متن کوچک‌تر برای نمایش بیشتر / متن بزرگ‌تر برای خوانایی بهتر',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.text_fields, size: 20),
              Expanded(
                child: Slider(
                  min: 0.85,
                  max: 1.4,
                  divisions: 11,
                  value: GameData.textScale,
                  label: '${(GameData.textScale * 100).round()}٪',
                  onChanged: (value) {
                    setState(() => GameData.setTextScale(value));
                  },
                ),
              ),
              const Icon(Icons.text_fields, size: 30),
            ],
          ),
          Center(
            child: Text(
              '${(GameData.textScale * 100).round()}٪ از اندازه معمول',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          // فاز ۱۶: ترجیح دست کودک
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'کودک چپ‌دست است',
              style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('دکمه‌های مهم به سمت دست چپ می‌روند'),
            value: GameData.isLeftHanded,
            onChanged: (value) => setState(() => GameData.setLeftHanded(value)),
          ),
        ],
      ),
    );
  }

  // 📊 گزارش مهارت‌ها — نسخه پریمیوم با نمودار راداری (پیشنهاد ۴۲)
  Widget _buildReportCard() {
    // نگاشت topSkills به ۸ مهارت استاندارد رادار
    final raw = GameData.topSkills;
    final mapped = <String, int>{
      'الفبا': (raw['alphabet'] ?? raw['الفبا'] ?? 0).clamp(0, 100),
      'اعداد': (raw['counting'] ?? raw['math'] ?? raw['اعداد'] ?? 0).clamp(0, 100),
      'رنگ‌ها': (raw['colors'] ?? raw['رنگ‌ها'] ?? 0).clamp(0, 100),
      'شکل‌ها': (raw['shapes'] ?? raw['شکل‌ها'] ?? 0).clamp(0, 100),
      'حیوانات': (raw['animals'] ?? raw['حیوانات'] ?? 0).clamp(0, 100),
      'حافظه': (raw['memory'] ?? raw['حافظه'] ?? 0).clamp(0, 100),
      'ریاضی': (raw['math'] ?? raw['ریاضی'] ?? 0).clamp(0, 100),
      'هنر': (raw['drawing'] ?? raw['هنر'] ?? 0).clamp(0, 100),
    };
    // اگر همه صفر بودند، برای دمو مقدار نمایشی بده
    final hasData = mapped.values.any((v) => v > 0);
    final display = hasData
        ? mapped
        : <String, int>{
            'الفبا': 72,
            'اعداد': 55,
            'رنگ‌ها': 88,
            'شکل‌ها': 40,
            'حیوانات': 65,
            'حافظه': 78,
            'ریاضی': 35,
            'هنر': 60,
          };

    return Column(
      children: [
        SkillRadarChart(skills: display, size: 240),
        const SizedBox(height: 16),
        // کارت پیش‌بینی قدیمی هم حفظ می‌شود برای متن کامل
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: AppColors.primary.withOpacity(0.08)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFF00B894).withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.sm)),
                    child: const Icon(Icons.insights_rounded, color: Color(0xFF00B894), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('تحلیل هوشمند', style: AppFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(AppRadii.pill)),
                    child: Text('${GameData.averageSuccessRate.toStringAsFixed(0)}٪ موفقیت', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'مهارت «${AI.weakSkill()}» ضعیف‌ترین حلقه است؛ با «${AI.suggestGames().take(2).join('» و «')}» تقویت می‌شود.',
                style: const TextStyle(fontSize: 13, height: 1.7),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF1F8FF), borderRadius: BorderRadius.circular(AppRadii.md)),
                child: Row(
                  children: [
                    const Text('🔮', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'پیش‌بینی فندقی: با روزی ۱۰ دقیقه بازی تا یک ماه دیگر میانگین مهارت‌ها به ۸۰٪ می‌رسد!',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackupCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💾', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'بکاپ امن پیشرفت کودک',
                style: AppFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'یک فایل رمزگذاری‌شدهٔ .parsa بسازید یا بکاپ قبلی را برگردانید. رمز فایل همان پین والدین است.',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  text: 'ساخت بکاپ',
                  color: AppColors.primary,
                  icon: Icons.save_alt_rounded,
                  onPressed: _exportBackup,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PremiumButton(
                  text: 'بازیابی',
                  color: const Color(0xFF00B894),
                  icon: Icons.restore_rounded,
                  onPressed: _importBackup,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _confirmBackupPin() async {
    if (!GameData.hasParentPin()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اول یک پین والدین تنظیم کنید')),
      );
      return null;
    }
    final pin = await _askPin(
      title: 'تأیید پین بکاپ',
      subtitle: 'برای رمزگذاری/رمزگشایی فایل بکاپ پین را دوباره وارد کنید',
    );
    if (pin == null) return null;
    if (!GameData.verifyParentPin(pin)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پین اشتباه است')),
        );
      }
      return null;
    }
    return pin;
  }

  Future<void> _exportBackup() async {
    final pin = await _confirmBackupPin();
    if (pin == null || !mounted) return;
    try {
      final path = await BackupService.exportBackup(pin: pin);
      if (!mounted) return;
      await Clipboard.setData(ClipboardData(text: path));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بکاپ ساخته شد و مسیر آن کپی شد: $path')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ساخت بکاپ انجام نشد؛ دوباره تلاش کنید.')),
      );
    }
  }

  Future<void> _importBackup() async {
    final pin = await _confirmBackupPin();
    if (pin == null || !mounted) return;
    final restored = await BackupService.pickAndImportBackup(pin: pin);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          restored
              ? 'بکاپ با موفقیت بازیابی شد؛ اطلاعات پنل تازه شد ✅'
              : 'فایل بکاپ انتخاب نشد یا معتبر نبود.',
        ),
      ),
    );
    if (restored) setState(() {});
  }

  Widget _buildPinCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'مدیریت پین',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (GameData.hasParentPin())
            PremiumButton(
              text: 'تغییر پین',
              onPressed: _setupPin,
              color: Colors.orange,
            )
          else
            PremiumButton(
              text: 'تنظیم پین',
              onPressed: _setupPin,
            ),
          const SizedBox(height: 12),
          if (GameData.hasParentPin())
            TextButton(
              onPressed: () {
                GameData.removeParentPin();
                setState(() {});
              },
              child: const Text('حذف پین', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeSelectorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: ThemeSelectorWidget(),
      ),
    );
  }

  Widget _buildHealthRadarCard() {
    final healthScore = ParentalHealthRadar.getHealthScore();
    final recommendation = ParentalHealthRadar.getHealthRecommendation();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety_rounded, color: AppColors.success),
                const SizedBox(width: 10),
                Text(
                  'رادار سلامت و بهداشت استفاده',
                  style: AppFonts.vazirmatn(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'امتیاز: $healthScore٪',
                    style: AppFonts.vazirmatn(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation,
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== کنترل‌های رشد ۶.۲ ====================
  /// ساعت خواب، فیلتر محتوا، حالت‌های دسترس‌پذیری و هدف یادگیری.
  Widget _buildGrowthControlsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.nightlight_round, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'کنترل‌های رشد و آرامش',
                  style: AppFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('ساعت خواب', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: Text(
                'از ${PersianDigits.toFa(GrowthStore.bedtimeHour)} شب تا ${PersianDigits.toFa(GrowthStore.wakeHour)} صبح فقط لالایی باز است',
              ),
              value: GrowthStore.bedtimeEnabled,
              onChanged: (v) => setState(() => GrowthStore.setBedtime(enabled: v)),
            ),
            if (GrowthStore.bedtimeEnabled) ...[
              Text('ساعت شروع خواب: ${PersianDigits.toFa(GrowthStore.bedtimeHour)}', style: const TextStyle(fontSize: 12)),
              Slider(
                min: 18,
                max: 23,
                divisions: 5,
                value: GrowthStore.bedtimeHour.toDouble(),
                label: '${GrowthStore.bedtimeHour}',
                onChanged: (v) => setState(() => GrowthStore.setBedtime(enabled: true, hour: v.round())),
              ),
              Text('ساعت بیداری: ${PersianDigits.toFa(GrowthStore.wakeHour)}', style: const TextStyle(fontSize: 12)),
              Slider(
                min: 5,
                max: 10,
                divisions: 5,
                value: GrowthStore.wakeHour.toDouble(),
                label: '${GrowthStore.wakeHour}',
                onChanged: (v) => setState(() => GrowthStore.setBedtime(enabled: true, wake: v.round())),
              ),
            ],
            const Divider(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('سکوت شب', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: const Text('در ساعت خواب صداها خودکار قطع می‌شوند'),
              value: GrowthStore.quietHoursEnabled,
              onChanged: (v) => setState(() => GrowthStore.setQuietHours(v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('کارتون', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: const Text('نمایش بخش کارتون'),
              value: GrowthStore.cartoonsAllowed,
              onChanged: (v) => setState(() => GrowthStore.setContentFilter(cartoons: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('قصه‌خانه', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: const Text('نمایش داستان‌ها'),
              value: GrowthStore.storiesAllowed,
              onChanged: (v) => setState(() => GrowthStore.setContentFilter(stories: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('فروشگاه', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: const Text('نمایش فروشگاه و خرید'),
              value: GrowthStore.shopAllowed,
              onChanged: (v) => setState(() => GrowthStore.setContentFilter(shop: v)),
            ),
            const Divider(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('حالت تمرکز', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: const Text('فقط یادگیری؛ فروشگاه و چیپ‌های پر زرق‌وبرق خاموش'),
              value: GrowthStore.focusMode,
              onChanged: (v) => setState(() => GrowthStore.setFocusMode(v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('کاهش حرکت', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: const Text('انیمیشن‌ها خاموش می‌شوند (مناسب حساسیت حرکتی)'),
              value: GrowthStore.reduceMotion,
              onChanged: (v) => setState(() => GrowthStore.setReduceMotion(v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('حالت کوررنگی', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: const Text('پالت رنگی سازگار با کودکان کوررنگ'),
              value: GrowthStore.colorBlindMode,
              onChanged: (v) => setState(() => GrowthStore.setColorBlindMode(v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('صرفه‌جویی داده', style: AppFonts.vazirmatn(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: const Text('کاهش کیفیت کارتون آنلاین'),
              value: GrowthStore.dataSaver,
              onChanged: (v) => setState(() => GrowthStore.setDataSaver(v)),
            ),
            const Divider(height: 20),
            Text(
              'هدف یادگیری هفته: ${PersianDigits.minutes(GrowthStore.weeklyGoalMinutes)}',
              style: AppFonts.vazirmatn(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Slider(
              min: 10,
              max: 180,
              divisions: 17,
              value: GrowthStore.weeklyGoalMinutes.toDouble(),
              label: '${GrowthStore.weeklyGoalMinutes}',
              onChanged: (v) => setState(() => GrowthStore.setWeeklyGoal(minutes: v.round())),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ابزار والدین ۶.۲ ====================
  /// گزارش هفتگی، کتابچه، صندوق یادگیری و معرفی به دیگران.
  Widget _buildParentToolsCard() {
    final chestReady = WeeklyEngine.canClaimLearningChest;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.construction_rounded, color: AppColors.warning),
                const SizedBox(width: 10),
                Text(
                  'ابزار والدین',
                  style: AppFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insights_rounded, color: AppColors.primary),
              title: const Text('گزارش هفتگی'),
              subtitle: const Text('زمان یادگیری و سرگرمی، قابل کپی'),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.pushNamed(context, '/weekly-report'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
              title: const Text('کتابچه کوتاه والدین'),
              subtitle: const Text('۸ نکته رشد بدون هزینه'),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.pushNamed(context, '/parent-booklet'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              title: const Text('تازه‌های نسخه'),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.pushNamed(context, '/whats-new'),
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: chestReady
                        ? () {
                            final ok = WeeklyEngine.claimLearningChest();
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok ? 'صندوق یادگیری باز شد! +۱۵ سکه 🎁' : 'هنوز ۱۵ دقیقه یادگیری این هفته کامل نشده.',
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.card_giftcard_rounded),
                    label: Text(chestReady ? 'باز کردن صندوق یادگیری' : 'صندوق یادگیری (۱۵ دقیقه)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final claimed = SmartConversion.claimReferralCoins();
                      await Clipboard.setData(
                        ClipboardData(text: SmartConversion.shareAppText()),
                      );
                      if (!mounted) return;
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            claimed
                                ? 'متن معرفی کپی شد و ۲۰ سکه هدیه گرفتید 🎉'
                                : 'متن معرفی کپی شد (هدیه یک‌بار است)',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: Text(
                      GrowthStore.referralClaimed ? 'کپی متن معرفی اپ' : 'معرفی به دوستان + ۲۰ سکه',
                    ),
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