import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../core/game_data.dart';
import '../../core/security/privacy_protection.dart';
import 'tabs/parent_children_tab.dart';
import 'tabs/parent_content_tab.dart';
import 'tabs/parent_home_tab.dart';
import 'tabs/parent_progress_tab.dart';
import 'tabs/parent_time_tab.dart';
import 'tabs/parent_tools_tab.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🏝️ مرکز حرفه‌ای والدین — Parent Hub
///
/// معماری تمیز چند-تبّه با الگوبرداری از بهترین اپ‌های دنیا:
///  - خانه: کارنامه یک‌نگاه + هشدارهای معلم
///  - پیشرفت: رادار مهارت + روند ۷ روزه
///  - زمان و امنیت: سهمیه، خواب، سلامت چشم
///  - محتوا: فیلتر بخش‌ها + دسترس‌پذیری
///  - کودکان: تا ۳ پروفایل خواهر/برادر
///  - ابزار: بکاپ AES-256-GCM، پین، حریم خصوصی، پشتیبانی
///
/// امنیت: قفل پین، قفل خودکار ۲ دقیقه‌ای، قفل در پس‌زمینه و
/// FLAG_SECURE برای جلوگیری از اسکرین‌شات/ضبط.
/// ═══════════════════════════════════════════════════════════════
class ParentHub extends StatefulWidget {
  const ParentHub({super.key});

  @override
  State<ParentHub> createState() => _ParentHubState();
}

class _ParentHubState extends State<ParentHub>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _isUnlocked = false;
  int _failedPinAttempts = 0;
  DateTime? _pinLockedUntil;
  Timer? _lockTimer;
  late final TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  void _armLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer(const Duration(minutes: 2), () {
      if (mounted && _isUnlocked) setState(() => _isUnlocked = false);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (mounted && _isUnlocked) setState(() => _isUnlocked = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  bool get _isPinCoolingDown =>
      _pinLockedUntil != null && DateTime.now().isBefore(_pinLockedUntil!);

  // ── پین ────────────────────────────────────────────────────
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                autofocus: true,
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
    if (await GameData.verifyParentPin(pin)) {
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
        const SnackBar(
            content: Text('پین چند بار اشتباه بود؛ ۳۰ ثانیه صبر کنید')),
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
    if (!await GameData.setParentPin(result)) {
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

  // ── صفحه قفل ───────────────────────────────────────────────
  Widget _buildLockScreen() {
    return SecureWindowScope(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_rounded,
                          size: 56, color: Colors.white),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'مرکز والدین',
                      style: AppFonts.vazirmatn(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'این بخش فقط برای والدین است.\nبرای ورود پین ۴ رقمی را وارد کنید.',
                      textAlign: TextAlign.center,
                      style: AppFonts.vazirmatn(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 240,
                      child: FilledButton.icon(
                        onPressed: _showPinDialog,
                        icon: const Icon(Icons.lock_open_rounded),
                        label: const Text('ورود با پین'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4834D4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: AppFonts.vazirmatn(
                              fontSize: 16, fontWeight: FontWeight.w900),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    if (!GameData.hasParentPin()) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _setupPin,
                        child: Text(
                          'اولین بار هستید؟ پین بسازید',
                          style: AppFonts.vazirmatn(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── صفحه اصلی ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) return _buildLockScreen();

    // هر تعامل تایمر قفل را تمدید می‌کند.
    _armLockTimer();

    final tabs = <_TabDef>[
      _TabDef('🏠', 'خانه'),
      _TabDef('📈', 'پیشرفت'),
      _TabDef('⏱️', 'زمان'),
      _TabDef('🎛️', 'محتوا'),
      _TabDef('👨\u200d👩\u200d👧', 'کودکان'),
      _TabDef('⚙️', 'ابزار'),
    ];

    return SecureWindowScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentIndex == 0 ? 'مرکز والدین' : tabs[_currentIndex].title),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'قفل کردن',
              icon: const Icon(Icons.lock_outline_rounded),
              onPressed: () => setState(() => _isUnlocked = false),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                labelStyle:
                    AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 13),
                unselectedLabelStyle:
                    AppFonts.vazirmatn(fontWeight: FontWeight.w700, fontSize: 12),
                tabs: [
                  for (final t in tabs)
                    Tab(
                      icon: Text(t.emoji, style: const TextStyle(fontSize: 18)),
                      text: t.title,
                      iconMargin: const EdgeInsets.only(bottom: 2),
                    ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ParentHomeTab(
              onOpenTimeControls: () => _tabController.animateTo(2),
              onOpenContent: () => _tabController.animateTo(3),
              onOpenProgress: () => _tabController.animateTo(1),
              onShareReport: () => Navigator.pushNamed(context, '/weekly-report'),
            ),
            ParentProgressTab(
              onOpenCertificates: () =>
                  Navigator.pushNamed(context, '/certificates'),
              onOpenVocabulary: () =>
                  Navigator.pushNamed(context, '/vocabulary'),
            ),
            const ParentTimeTab(),
            const ParentContentTab(),
            const ParentChildrenTab(),
            ParentToolsTab(askPin: _askPin, onSetupPin: _setupPin),
          ],
        ),
      ),
    );
  }
}

class _TabDef {
  final String emoji;
  final String title;
  const _TabDef(this.emoji, this.title);
}
