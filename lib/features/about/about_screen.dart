import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_fonts.dart';
import '../../core/app_legal.dart';

part 'about_components.dart';
part 'about_crown_painter.dart';
part 'about_models.dart';

/// Native, responsive adaptation of the public Parsa Apps About page.
///
/// The copy, brand palette, founder presentation, upcoming products and direct
/// contact destinations intentionally mirror https://parsa-apps.github.io/about.html.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;
  bool _isLight = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion == _reduceMotion) return;

    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _motionController
        ..stop()
        ..value = 0;
    } else {
      _motionController.repeat();
    }
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  Future<void> _openUri(Uri uri, {String? copyFallback}) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }

    if (!mounted || opened) return;

    if (copyFallback != null) {
      await Clipboard.setData(ClipboardData(text: copyFallback));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نشانی کپی شد.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('امکان باز کردن این لینک وجود ندارد.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _isLight
        ? const _AboutPalette.light()
        : const _AboutPalette.dark();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: palette.background.withOpacity(0.96),
          surfaceTintColor: Colors.transparent,
          foregroundColor: palette.text,
          systemOverlayStyle: _isLight
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          title: Text(
            'درباره ما',
            style: AppFonts.vazirmatn(
              color: palette.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              tooltip: _isLight ? 'حالت تاریک' : 'حالت روشن',
              onPressed: () => setState(() => _isLight = !_isLight),
              icon: Icon(
                _isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _motionController,
                  builder: (context, _) => _AboutBackdrop(
                    palette: palette,
                    progress: _motionController.value,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 72,
              ),
              child: _AboutPage(
                palette: palette,
                motion: _motionController,
                onOpenProduct: () => _openUri(
                  Uri.parse(AppLegal.productPageUrl),
                  copyFallback: AppLegal.productPageUrl,
                ),
                onOpenTelegram: () => _openUri(
                  Uri.parse(AppLegal.telegramUrl),
                  copyFallback: AppLegal.telegramHandle,
                ),
                onOpenInstagram: () => _openUri(
                  Uri.parse(AppLegal.instagramUrl),
                  copyFallback: AppLegal.instagramUrl,
                ),
                onOpenEmail: () => _openUri(
                  Uri(
                    scheme: 'mailto',
                    path: AppLegal.supportEmail,
                    queryParameters: const {
                      'subject': 'ارتباط با پارسا اپس',
                    },
                  ),
                  copyFallback: AppLegal.supportEmail,
                ),
                onOpenContactForm: () => _openUri(
                  Uri.parse(AppLegal.contactPageUrl),
                  copyFallback: AppLegal.contactPageUrl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage({
    required this.palette,
    required this.motion,
    required this.onOpenProduct,
    required this.onOpenTelegram,
    required this.onOpenInstagram,
    required this.onOpenEmail,
    required this.onOpenContactForm,
  });

  final _AboutPalette palette;
  final Animation<double> motion;
  final VoidCallback onOpenProduct;
  final VoidCallback onOpenTelegram;
  final VoidCallback onOpenInstagram;
  final VoidCallback onOpenEmail;
  final VoidCallback onOpenContactForm;

  static const List<String> _reasons = [
    'توسعه با استانداردهای مهندسی نرم‌افزار و کدنویسی تمیز',
    'تمرکز کامل روی تجربه کاربری فارسی و RTL',
    'طراحی امن و خانواده‌محور برای کودکان',
    'بدون کتابخانه‌های سنگین — سریع، سبک و بهینه',
    'پشتیبانی واقعی و پاسخ سریع به کاربران',
    'به‌روزرسانی منظم و برنامه توسعه شفاف',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 720 ? 36.0 : 18.0;
    final titleSize = (screenWidth * 0.1).clamp(34.0, 52.0).toDouble();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 42, horizontalPadding, 0),
          child: Column(
            children: [
              _GradientTitle(
                text: 'درباره پارسا اپس',
                fontSize: titleSize,
              )
                  .animate()
                  .fadeIn(duration: 520.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutCubic),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  'پارسا اپس یک استودیوی ایرانی توسعه نرم‌افزار است؛ جایی که ایده‌های خلاقانه\n'
                  'با مهندسی دقیق، طراحی در سطح جهانی و عشق به جزئیات به محصول تبدیل می‌شوند.',
                  textAlign: TextAlign.center,
                  style: AppFonts.vazirmatn(
                    color: palette.muted,
                    fontSize: 17,
                    height: 2.05,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 90.ms, duration: 520.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutCubic),
              const SizedBox(height: 52),
              _AboutBlock(
                palette: palette,
                child: _FounderSection(palette: palette, motion: motion),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 520.ms)
                  .slideY(begin: 0.06, curve: Curves.easeOutCubic),
              const SizedBox(height: 26),
              _AboutBlock(
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(text: '🎯 ماموریت ما', palette: palette),
                    const SizedBox(height: 12),
                    _Paragraph(
                      palette: palette,
                      text:
                          'ساخت محصولاتی که فناوری را ساده‌تر، جذاب‌تر و مفیدتر برای همه کنند —\n'
                          'از کوچک‌ترین کاربران تا خانواده‌ها؛ با کیفیتی که در هر مرحله قابل لمس باشد.',
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 210.ms, duration: 500.ms)
                  .slideY(begin: 0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 26),
              _AboutBlock(
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(text: '💡 چرا پارسا اپس؟', palette: palette),
                    const SizedBox(height: 12),
                    ..._reasons.map(
                      (reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 9),
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: palette.leaf,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: palette.leaf.withOpacity(0.38),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reason,
                                style: AppFonts.vazirmatn(
                                  color: palette.muted,
                                  fontSize: 16,
                                  height: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 270.ms, duration: 500.ms)
                  .slideY(begin: 0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 26),
              _AboutBlock(
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      text: '🏝️ اولین محصول: جزیره فندقی',
                      palette: palette,
                    ),
                    const SizedBox(height: 12),
                    _Paragraph(
                      palette: palette,
                      text:
                          'اولین ماجراجویی ما «جزیره فندقی» است؛ دنیایی آموزشی و سرگرم‌کننده برای کودکان\n'
                          'که یادگیری را با بازی ترکیب می‌کند.',
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: onOpenProduct,
                      style: TextButton.styleFrom(
                        foregroundColor: palette.gold,
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        textStyle: AppFonts.vazirmatn(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_back_rounded, size: 19),
                      label: const Text('مشاهده محصول'),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 330.ms, duration: 500.ms)
                  .slideY(begin: 0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 26),
              _AboutBlock(
                palette: palette,
                child: Column(
                  children: [
                    _SectionTitle(
                      text: '🚀 اپلیکیشن‌های در راه انتشار',
                      palette: palette,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _Paragraph(
                      palette: palette,
                      text:
                          'تیم پارسا اپس در حال ساخت این محصولات است؛ به‌زودی در استورهای معتبر منتشر می‌شوند.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _UpcomingGrid(palette: palette, motion: motion),
                    const SizedBox(height: 30),
                    Text(
                      '✦ برای اطلاع از تاریخ انتشار، از راه‌های ارتباطی زیر عضو شوید ✦',
                      textAlign: TextAlign.center,
                      style: AppFonts.vazirmatn(
                        color: palette.muted,
                        fontSize: 14,
                        height: 1.9,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 390.ms, duration: 500.ms)
                  .slideY(begin: 0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 26),
              _AboutBlock(
                palette: palette,
                child: Column(
                  children: [
                    _SectionTitle(
                      text: '📬 ارتباط مستقیم با مدیریت',
                      palette: palette,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _Paragraph(
                      palette: palette,
                      text:
                          'سوال، پیشنهاد یا گزارش مشکل؟ پیام شما مستقیم به مدیر و برنامه‌نویس ارشد می‌رسد.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _ContactGrid(
                      palette: palette,
                      motion: motion,
                      destinations: [
                        _ContactDestination(
                          name: 'تلگرام',
                          meta: 'پاسخ سریع در کمتر از ۲۴ ساعت',
                          icon: Icons.send_rounded,
                          colors: const [Color(0xFF37AEE2), Color(0xFF1E8FC9)],
                          glowColor: const Color(0xFF2AABEE),
                          onTap: onOpenTelegram,
                        ),
                        _ContactDestination(
                          name: 'اینستاگرام',
                          meta: 'پیج رسمی پارسا اپس — به‌زودی',
                          icon: Icons.photo_camera_rounded,
                          colors: const [
                            Color(0xFFF58529),
                            Color(0xFFDD2A7B),
                            Color(0xFF8134AF),
                          ],
                          glowColor: const Color(0xFFDD2A7B),
                          onTap: onOpenInstagram,
                        ),
                        _ContactDestination(
                          name: 'ایمیل',
                          meta: 'همکاری و پیشنهادهای تجاری',
                          icon: Icons.email_rounded,
                          colors: const [Color(0xFFFBD06F), Color(0xFFE9B949)],
                          glowColor: const Color(0xFFE9B949),
                          iconColor: const Color(0xFF5B3600),
                          onTap: onOpenEmail,
                        ),
                        _ContactDestination(
                          name: 'فرم تماس',
                          meta: 'ارسال پیام از خود سایت',
                          icon: Icons.forum_rounded,
                          colors: const [Color(0xFF6D5DF6), Color(0xFF2BB3A0)],
                          glowColor: const Color(0xFF6D5DF6),
                          onTap: onOpenContactForm,
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 500.ms)
                  .slideY(begin: 0.05, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }
}
