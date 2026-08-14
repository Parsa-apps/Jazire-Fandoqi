import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/content_access.dart';
import '../../core/fandoghi_models.dart';
import '../../core/growth/smart_conversion.dart';
import '../../core/monetization.dart';
import '../../core/security/privacy_protection.dart';
import '../../shared/widgets/fandoghi_premium.dart';

String _normalizeDigits(String input) {
  const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  String result = input;
  for (int i = 0; i < persianDigits.length; i++) {
    result = result.replaceAll(persianDigits[i], englishDigits[i]);
  }
  return result;
}

/// 💰 قیمت نسخهٔ کامل — یک مرجع واحد، تا عدد در دکمه، کارت قیمت و
/// هدر همیشه یکی باشد.
const String kFullVersionPriceDigits = '۴۹٬۰۰۰';
const String kFullVersionPriceWords = 'چهل و نه هزار تومان';

/// هدر پی‌وال: لوگوی فندقی در کنار قیمتِ بزرگ که «تایپ» می‌شود.
///
/// رقم‌ها یکی‌یکی مثل ماشین‌تحریر ظاهر می‌شوند، بعد کلمهٔ «تومان» و
/// در پایان نوشتهٔ حروفی محو-ظاهر می‌شود؛ چشمِ والد دقیقاً روی عدد
/// می‌نشیند بدون اینکه شلوغ شود.
class _PriceHeadline extends StatefulWidget {
  const _PriceHeadline();

  @override
  State<_PriceHeadline> createState() => _PriceHeadlineState();
}

class _PriceHeadlineState extends State<_PriceHeadline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<int> _typed;

  static const String _price = kFullVersionPriceDigits;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 140 * _price.length),
    );
    _typed = StepTween(begin: 0, end: _price.length).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const FandoghiPremium(
          size: 84,
          mood: FandoghiMood.celebrating,
          showParticles: true,
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 1400.ms, color: const Color(0x66FFD54F)),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _typed,
                builder: (context, _) {
                  final shown = _price.substring(0, _typed.value);
                  final done = _typed.value == _price.length;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFA726),
                            Color(0xFFF06292),
                            Color(0xFFBA68C8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          shown.isEmpty ? ' ' : shown,
                          style: AppFonts.vazirmatn(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedOpacity(
                        opacity: done ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          'تومان',
                          style: AppFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF6C5CE7),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Text(
                kFullVersionPriceWords,
                style: AppFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                ),
              )
                  .animate()
                  .fadeIn(delay: 900.ms, duration: 500.ms)
                  .slideY(begin: 0.4, end: 0),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: const Color(0xFFFFC107)),
                ),
                child: Text(
                  'یک‌بار پرداخت • برای همیشه',
                  style: AppFonts.vazirmatn(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF8D6E00),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1200.ms)
                  .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
            ],
          ),
        ),
      ],
    );
  }
}

/// A parent-facing, one-time purchase surface — PREMIUM V2
/// پیشنهاد ۴۱ — پرداخت امن کافه‌بازار + اعتماد والد
Future<void> showFullVersionPaywall(BuildContext context, {String? featureName}) async {
  final bought = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SecureWindowScope(
      child: _FullVersionSheetPremium(featureName: featureName),
    ),
  );
  if (bought == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('نسخه کامل فعال شد؛ همه دنیاها آماده بازی‌اند! 🎉'),
      backgroundColor: Color(0xFF16803C),
    ));
  }
}

class _FullVersionSheetPremium extends StatefulWidget {
  const _FullVersionSheetPremium({this.featureName});
  final String? featureName;
  @override
  State<_FullVersionSheetPremium> createState() => _FullVersionSheetPremiumState();
}

class _FullVersionSheetPremiumState extends State<_FullVersionSheetPremium> {
  bool _loading = false;

  Future<bool> _parentGate() async {
    final random = Random();
    final a = random.nextInt(6) + 4;
    final b = random.nextInt(5) + 2;
    final correctAnswer = '${a + b}';
    final answer = TextEditingController();
    final allowed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.family_restroom_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 12),
              Text('ورود والدین', style: AppFonts.vazirmatn(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436))),
              const SizedBox(height: 8),
              const Text('برای ادامه، پاسخ این سؤال را وارد کنید:', style: TextStyle(color: Color(0xFF636E72), fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                child: Text('$a + $b = ؟', style: AppFonts.vazirmatn(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answer,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436)),
                decoration: InputDecoration(
                  hintText: 'جواب را بنویس',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FE),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.lg), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.lg), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
                onSubmitted: (_) {
                  final normalized = _normalizeDigits(answer.text.trim());
                  Navigator.pop(dialogContext, normalized == correctAnswer);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(dialogContext, false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))), child: Text('انصراف', style: AppFonts.vazirmatn(fontWeight: FontWeight.w700, color: Colors.red)))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: () { final normalized = _normalizeDigits(answer.text.trim()); Navigator.pop(dialogContext, normalized == correctAnswer); }, style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg))), child: Text('تأیید', style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, color: Colors.white)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    answer.dispose();
    return allowed ?? false;
  }

  Future<void> _buy() async {
    HapticFeedback.mediumImpact();
    if (!await _parentGate() || !mounted) return;
    setState(() => _loading = true);
    final ok = await Monetization.purchaseFullVersion();
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      HapticFeedback.heavyImpact();
      await ContentAccess.refresh();
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
          title: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.error_outline_rounded, color: Colors.red)), const SizedBox(width: 10), Text('پرداخت کامل نشد', style: AppFonts.vazirmatn(fontWeight: FontWeight.w900))]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('لطفاً اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.', style: AppFonts.vazirmatn(fontSize: 14, height: 1.6)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F8FF), borderRadius: BorderRadius.circular(AppRadii.md)),
                child: Row(children: [const Icon(Icons.help_outline_rounded, size: 18, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text('اگر قبلاً خریدی انجام دادی، «بازیابی خرید» را بزن.', style: AppFonts.vazirmatn(fontSize: 12)))]),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('باشه', style: AppFonts.vazirmatn(color: AppColors.primary))),
            FilledButton(onPressed: () async { Navigator.pop(ctx); if (await Monetization.restoreFullVersion()) { await ContentAccess.refresh(); if (mounted) Navigator.pop(context, true); } }, style: FilledButton.styleFrom(backgroundColor: AppColors.primary), child: Text('بازیابی خرید', style: AppFonts.vazirmatn(color: Colors.white))),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData.light(useMaterial3: true).copyWith(textTheme: ThemeData.light(useMaterial3: true).textTheme.apply(bodyColor: const Color(0xFF2D3436), displayColor: const Color(0xFF2D3436))),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)), boxShadow: AppShadows.strong),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  // هدر پریمیوم
                  const _PriceHeadline(),
                  const SizedBox(height: 12),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFF06292), Color(0xFFBA68C8)]).createShader(bounds),
                    child: Text('✨ نسخه کامل — یک‌بار برای همیشه', textAlign: TextAlign.center, style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF00B894).withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadii.pill), border: Border.all(color: const Color(0xFF00B894).withOpacity(0.25))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF00B894)),
                        const SizedBox(width: 6),
                        Text(widget.featureName == null ? 'همه بازی‌ها + داستان‌ها + کارتون‌ها' : '«${widget.featureName}» + همه دنیاها', style: AppFonts.vazirmatn(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF00695C))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // کارت قیمت
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)]),
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      boxShadow: AppShadows.colored(AppColors.primary, opacity: 0.3),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(AppRadii.pill)),
                                    child: Text('پرداخت یک‌باره', style: AppFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black87)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('بدون تمدید ماهانه', style: AppFonts.vazirmatn(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('دسترسی همیشگی به همه محتوا', style: AppFonts.vazirmatn(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(SmartConversion.familyPackCopy(widget.featureName), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, height: 1.5)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.lg)),
                          child: Column(
                            children: [
                              Text('قیمت نسخه کامل', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(kFullVersionPriceDigits, style: AppFonts.vazirmatn(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                              Text(kFullVersionPriceWords, style: AppFonts.vazirmatn(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  // مزایا 5 تایی
                  ...[
                    ('همه بازی‌ها و دنیاهای آموزشی', '🎮', '۱۶ بازی + ۳۰ حیوان + آزمایشگاه رنگ'),
                    ('۱۰ داستان تعاملی + ۱۰ لالایی', '📚', 'با صدای فندقی و انتخاب کودک'),
                    ('بدون تبلیغ، کاملاً آفلاین', '🔒', 'حریم خصوصی کودک — COPPA'),
                    ('بروزرسانی‌های آینده رایگان', '🎁', 'هر محتوای جدید بدون پرداخت دوباره'),
                    ('پشتیبانی مستقیم تلگرام', '💬', '@Parsaappsadmin — پاسخ ۲۴ ساعته'),
                  ].map((b) => _PremiumBenefit(icon: b.$2, title: b.$1, subtitle: b.$3)).toList(),
                  const SizedBox(height: 14),
                  // نشان اعتماد
                  Row(
                    children: [
                      _TrustBadge(icon: Icons.security_rounded, label: 'پرداخت امن', sub: 'کافه‌بازار'),
                      const SizedBox(width: 8),
                      _TrustBadge(icon: Icons.block_rounded, label: 'بدون تبلیغ', sub: '۱۰۰٪'),
                      const SizedBox(width: 8),
                      _TrustBadge(icon: Icons.offline_bolt_rounded, label: 'آفلاین', sub: 'کامل'),
                      const SizedBox(width: 8),
                      _TrustBadge(icon: Icons.support_agent_rounded, label: 'پشتیبانی', sub: 'تلگرام'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _buy,
                      icon: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                      label: Text(_loading ? 'در حال اتصال امن...' : 'خرید امن — $kFullVersionPriceDigits تومان', style: AppFonts.vazirmatn(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
                        shadowColor: AppColors.primary.withOpacity(0.4),
                        elevation: 8,
                      ),
                    ),
                  ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh_rounded, size: 14, color: AppColors.primary),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                HapticFeedback.lightImpact();
                                if (await Monetization.restoreFullVersion()) {
                                  await ContentAccess.refresh();
                                  if (mounted) Navigator.pop(context, true);
                                }
                              },
                        child: Text('بازیابی خرید قبلی', style: AppFonts.vazirmatn(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: Colors.black26)),
                      const SizedBox(width: 8),
                      Text('فقط برای والدین', style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('با خرید، قوانین کافه‌بازار و حریم خصوصی آفلاین اپ را می‌پذیری.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.black38, height: 1.4)),
                ],
              ),
            ),
          ),
        ),
      );

}

class _PremiumBenefit extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  const _PremiumBenefit({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(AppRadii.md), border: Border.all(color: AppColors.primary.withOpacity(0.12))),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppFonts.vazirmatn(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF2D3436))),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.3)),
                ],
              ),
            ),
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00B894), size: 20),
          ],
        ),
      );
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _TrustBadge({required this.icon, required this.label, required this.sub});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(AppRadii.lg), border: Border.all(color: AppColors.primary.withOpacity(0.08))),
          child: Column(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(label, style: AppFonts.vazirmatn(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436))),
              Text(sub, style: TextStyle(fontSize: 9, color: Colors.black45, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
