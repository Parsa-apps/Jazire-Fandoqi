import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_colors.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/premium_button.dart';

/// =======================================================
/// 👨‍👩‍👧 PREMIUM ADVANCED PARENT CONTROL SYSTEM
/// =======================================================
class ParentPanel extends StatefulWidget {
  const ParentPanel({super.key});

  @override
  State<ParentPanel> createState() => _ParentPanelState();
}

class _ParentPanelState extends State<ParentPanel> {
  late int _timeLimit;
  String _pin = '';
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _timeLimit = GameData.timeLimitMinutes;
    _isUnlocked = !GameData.hasParentPin();
    GameData.changes.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GameData.changes.removeListener(_onDataChanged);
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

          // ==================== REPORT ====================
          _buildReportCard(),

          const SizedBox(height: 24),

          // ==================== PIN MANAGEMENT ====================
          _buildPinCard(),
        ],
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
            style: GoogleFonts.vazirmatn(
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
            style: GoogleFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w800),
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
            style: GoogleFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w800),
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