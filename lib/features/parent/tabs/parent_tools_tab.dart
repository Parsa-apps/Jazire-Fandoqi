import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_fonts.dart';
import '../../../core/app_legal.dart';
import '../../../core/backup_service.dart';
import '../../../data/datasources/crash_report_store.dart';
import '../../../core/game_data.dart';
import '../../../core/growth/growth.dart';
import '../../../shared/widgets/theme_selector_widget.dart';
import '../widgets/parent_widgets.dart';

/// تب ابزار: بکاپ امن، پین، گزارش خطا، حریم خصوصی، پشتیبانی و تم.
class ParentToolsTab extends StatefulWidget {
  final Future<String?> Function({
    required String title,
    required String subtitle,
  }) askPin;
  final VoidCallback onSetupPin;

  const ParentToolsTab({
    super.key,
    required this.askPin,
    required this.onSetupPin,
  });

  @override
  State<ParentToolsTab> createState() => _ParentToolsTabState();
}

class _ParentToolsTabState extends State<ParentToolsTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // بکاپ
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '💾',
                title: 'بکاپ امن پیشرفت',
                subtitle:
                    'فایل رمزنگاری‌شده‌ی .parsa با استاندارد AES-256-GCM. رمز فایل همان پین والدین است؛ هیچ نسخه‌ای روی سرور نیست.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _exportBackup,
                      icon: const Icon(Icons.save_alt_rounded),
                      label: const Text('ساخت بکاپ'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _importBackup,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('بازیابی'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00B894),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // پین
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '🔒',
                title: 'پین والدین',
                subtitle:
                    'پین ۴ رقمی با هَش و قفل خودکار. این پین کلید بکاپ و ورود به مرکز والدین است.',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.onSetupPin,
                      icon: Icon(GameData.hasParentPin()
                          ? Icons.sync_rounded
                          : Icons.lock_outline_rounded),
                      label: Text(GameData.hasParentPin()
                          ? 'تغییر پین'
                          : 'تنظیم پین'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  if (GameData.hasParentPin()) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await GameData.removeParentPin();
                          if (mounted) setState(() {});
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('حذف پین'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // گزارش خطا
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '🛠️',
                title: 'گزارش سلامت دستگاه',
                subtitle:
                    'خطاها فقط روی همین گوشی ذخیره می‌شوند و هرگز خودکار جایی ارسال نمی‌شوند.',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showDebugLogs,
                      icon: const Icon(Icons.list_alt_rounded),
                      label: const Text('مشاهده خطاها'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sendLogsToSupport,
                      icon: const Icon(Icons.support_agent_rounded),
                      label: const Text('ارسال به پشتیبانی'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // تم
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '🎨',
                title: 'ظاهر و تم برنامه',
                subtitle: 'تم دل‌خواه کودک را انتخاب کنید',
              ),
              const SizedBox(height: 8),
              const ThemeSelectorWidget(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // منوی میانبر
        ParentCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _menuTile(
                icon: Icons.menu_book_rounded,
                title: 'کتابچه‌ی کوتاه والدین',
                subtitle: 'نکات رشد بدون هزینه',
                route: '/parent-booklet',
              ),
              const Divider(height: 1),
              _menuTile(
                icon: Icons.auto_awesome_rounded,
                title: 'تازه‌های نسخه',
                subtitle: 'چه چیزی در این نسخه اضافه شد',
                route: '/whats-new',
              ),
              const Divider(height: 1),
              _menuTile(
                icon: Icons.shield_outlined,
                title: 'حریم خصوصی',
                subtitle: 'سیاست‌نامه‌ی کامل',
                route: '/privacy',
              ),
              const Divider(height: 1),
              _menuTile(
                icon: Icons.info_outline_rounded,
                title: 'درباره ما',
                subtitle: AppLegal.developerName,
                route: '/about',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // تماس
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '💬',
                title: 'پشتیبانی و تماس',
                subtitle:
                    'برای گزارش محتوا، پیشنهاد یا مشکل، در دسترس هستیم.',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(AppLegal.telegramUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('تلگرام'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse('mailto:${AppLegal.supportEmail}'),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.mail_outline_rounded),
                      label: const Text('ایمیل'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ریست آمار
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                emoji: '⚠️',
                title: 'ناحیه خطر',
                subtitle:
                    'این کارها برگشت‌ناپذیرند؛ بهتر است اول یک بکاپ بگیرید.',
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmReset,
                  icon: const Icon(Icons.restart_alt_rounded,
                      color: Colors.redAccent),
                  label: const Text('بازنشانی پیشرفت کودک'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '${AppLegal.productName} • نسخه ${GrowthStore.appVersion}',
            style: AppFonts.vazirmatn(fontSize: 11, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title,
          style: AppFonts.vazirmatn(fontWeight: FontWeight.w800, fontSize: 14)),
      subtitle: Text(subtitle,
          style: AppFonts.vazirmatn(fontSize: 11, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_left_rounded),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Future<String?> _confirmPin() async {
    if (!GameData.hasParentPin()) return null;
    final pin = await widget.askPin(
      title: 'تأیید پین',
      subtitle: 'برای رمزگذاری/رمزگشایی بکاپ پین را وارد کنید',
    );
    if (pin == null) return null;
    if (!await GameData.verifyParentPin(pin)) {
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
    if (!GameData.hasParentPin()) {
      widget.onSetupPin();
      return;
    }
    final pin = await _confirmPin();
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
    final pin = await _confirmPin();
    if (pin == null || !mounted) return;
    final restored = await BackupService.pickAndImportBackup(pin: pin);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(restored
            ? 'بکاپ با موفقیت بازیابی شد ✅'
            : 'فایل بکاپ انتخاب نشد یا معتبر نبود.'),
      ),
    );
    if (restored) setState(() {});
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  child: Text('گزارش خطاها (${logs.length})',
                      style: AppFonts.vazirmatn(
                          fontSize: 17, fontWeight: FontWeight.w900)),
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
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final log = logs[index];
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
                        Text('${log['source'] ?? 'runtime'} — ${log['time'] ?? ''}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontFamily: 'monospace')),
                        const SizedBox(height: 6),
                        Text((log['message'] ?? '').toString(),
                            style: const TextStyle(fontSize: 13)),
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

  Future<void> _sendLogsToSupport() async {
    final logs = await CrashReportStore.getLogs();
    if (!mounted) return;
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هیچ خطایی ثبت نشده 🎉')),
      );
      return;
    }
    final summary = logs.take(10).map((l) {
      final raw = (l['message'] ?? '').toString().replaceAll(RegExp(r'\s+'), ' ');
      final safe = raw.length > 80 ? raw.substring(0, 80) : raw;
      return '${l['source'] ?? 'runtime'}: $safe';
    }).join('\n');
    final text = 'گزارش سلامت ${AppLegal.productName}\n'
        'نسخه: ${GrowthStore.appVersion}\n---\n$summary\n(${logs.length} خطا)';
    final uri = Uri.parse(
      'https://t.me/share/url?url=${Uri.encodeComponent(AppLegal.productName)}&text=${Uri.encodeComponent(text)}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تلگرام نصب نیست؛ آیدی: ${AppLegal.telegramHandle}')),
      );
    }
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('بازنشانی پیشرفت؟'),
        content: const Text(
            'تمام ستاره‌ها، سکه‌ها، مهارت‌ها و مراحل پاک می‌شود. تنظیمات والدین و پین می‌ماند. ادامه می‌دهید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('بازنشانی'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    GameData.resetChildProgressKeepingParent();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پیشرفت کودک بازنشانی شد.')),
      );
      setState(() {});
    }
  }
}
