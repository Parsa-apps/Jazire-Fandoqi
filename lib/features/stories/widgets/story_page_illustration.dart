import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/app_fonts.dart';
import '../../../core/audio_service.dart';
import '../../../core/learning_content/children_stories_data.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🎨 STORY PAGE ILLUSTRATION — تصویرسازی جذاب صفحات داستان
/// اگر تصویر AI کش/موجود بود آن را نشان می‌دهد؛
/// در غیر این صورت یک تصویرسازی برداری و انیمیشنی بی‌نظیر می‌سازد
/// ═══════════════════════════════════════════════════════════════
class StoryPageIllustration extends StatelessWidget {
  final ChildrenStory story;
  final ChildrenStoryPage page;
  final VoidCallback? onTap;

  /// تعامل حرفه‌ای: ضربه روی تصویر → پخش افکت صوتی + انیمیشن
  final bool enableInteractive;

  const StoryPageIllustration({
    super.key,
    required this.story,
    required this.page,
    this.onTap,
    this.enableInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = GestureDetector(
      onTap: () {
        if (enableInteractive) {
          AudioService.tap();
          if (onTap != null) onTap!();
        } else {
          if (onTap != null) onTap!();
        }
      },
      onDoubleTap: () {
        if (enableInteractive) {
          AudioService.select();
          HapticFeedback.mediumImpact();
        }
      },
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: story.gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: story.themeColor.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ۱. تصویرسازی اصلی (اگر فایل PNG در assets باشد)
              if (page.imageAsset != null)
                Image.asset(
                  page.imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDecorativeCanvas();
                  },
                )
              else
                _buildDecorativeCanvas(),

              // ۲. گرادیان لایه پایین برای خوانایی متن روی عکس
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 90,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // ۳. برچسب شماره صفحه و عنوان لایه
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'صفحه ${page.pageNumber}',
                        style: AppFonts.vazirmatn(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        page.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ۴. آیکون بزرگ‌نمایی تصویر در گوشه بالا
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.amberAccent,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return content;
  }

  Widget _buildDecorativeCanvas() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // پس‌زمینه ستاره‌های درخشان و نورهای فانتزی
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          left: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // ستاره‌های کوچک تزئینی
        const Positioned(
          top: 24,
          left: 40,
          child: Text('✨', style: TextStyle(fontSize: 22)),
        ),
        const Positioned(
          top: 60,
          right: 30,
          child: Text('🌟', style: TextStyle(fontSize: 18)),
        ),
        const Positioned(
          bottom: 70,
          right: 50,
          child: Text('💫', style: TextStyle(fontSize: 24)),
        ),
        // ایموجی یا نماد بزرگ شخصیت و تم صفحه در مرکز
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                page.fallbackEmoji,
                style: const TextStyle(fontSize: 76),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.08, 1.08),
                    duration: 1600.ms,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${story.coverEmoji} ${story.title}',
                  style: AppFonts.vazirmatn(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
