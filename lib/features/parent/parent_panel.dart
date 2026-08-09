import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../app/app_colors.dart';
import 'package:amoozesh_fandoghi/app/app_fonts.dart';
import '../../core/game_data.dart';
import '../../data/datasources/crash_report_store.dart';
import '../../presentation/providers/game_state_provider.dart';
import '../../shared/widgets/premium_button.dart';

/// =======================================================
/// 👨‍👩‍👧 PREMIUM ADVANCED PARENT CONTROL SYSTEM
/// =======================================================
class ParentPanel extends ConsumerStatefulWidget {
  const ParentPanel({super.key});

  @override
  ConsumerState<ParentPanel> createState() => _ParentPanelState();
}

class _ParentPanelState extends ConsumerState<ParentPanel> {
  late int _timeLimit;
  String _pin = '';
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _timeLimit = GameData.timeLimitMinutes;
    _isUnlocked = !GameData.hasParentPin();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ==================== PIN ENTRY ====================
  Future<void> _showPinDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🔒 ورود والدین'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('لطفاً پین ۴ رقمی خود را وارد کنید'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
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
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.length == 4) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('تایید'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.length == 4) {
      if (GameData.verifyParentPin(controller.text)) {
        setState(() => _isUnlocked = true);
        HapticFeedback.lightImpact();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پین اشتباه است')),
        );
      }
    }
    controller.dispose();
  }

  Future<void> _setupPin() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('تنظیم پین والدین'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8),
          decoration: const InputDecoration(
            hintText: '۴ رقم',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );

    if (result != null && result.length == 4) {
      GameData.setParentPin(result);
      setState(() => _isUnlocked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پین با موفقیت ذخیره شد')),
      );
    }
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

          // ==================== TIME LIMIT ====================
          _buildTimeLimitCard(),

          const SizedBox(height: 24),

          // ==================== ACCESSIBILITY (فاز ۷) ====================
          _buildTextScaleCard(),

          const SizedBox(height: 24),

          // ==================== REPORT ====================
          _buildReportCard(),

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
            ],
          ),
        ],
      ),
    );
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
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Text(
                    'گزارش خطاها (${logs.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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

  Widget _buildReportCard() {
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
            'گزارش مهارت‌ها',
            style: AppFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...GameData.topSkills.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  Text('${entry.value}'),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: (entry.value / 100).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
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
}