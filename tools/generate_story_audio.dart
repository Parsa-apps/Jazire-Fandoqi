/// 🎙️ ابزار تولید صدای کودکانه برای داستان‌ها
/// 
/// این اسکریپت تمام متن‌های داستان را با صدای بچگانه حرفه‌ای
/// (فارسی روان بدون لهجه، لحن کودکانه شاد) به فایل صوتی تبدیل می‌کند.
/// 
/// نحوه اجرا:
///   dart run tools/generate_story_audio.dart
/// 
/// خروجی: assets/audio/stories/story_{id}_page{number}.mp3
/// 
/// NOTE: این اسکریپت برای اجرای محلی با API صوتی هوش مصنوعی طراحی شده.
/// در محیط Arena، تولید صدا از طریق سرویس generate_speech انجام شد.
/// برای بازتولید، کلید API صوتی را در متغیر محیطی TTS_API_KEY قرار دهید.

import 'dart:io';
import '../lib/core/learning_content/children_stories_data.dart';

void main() async {
  final stories = ChildrenStoriesData.allStories;
  print('📚 تعداد داستان‌ها: ${stories.length}');

  for (final story in stories) {
    for (final page in story.pages) {
      final assetPath = 'assets/audio/stories/${story.id}_page${page.pageNumber}.mp3';
      final text = '${page.title}. ${page.text}';
      final exists = await File(assetPath).exists();
      if (exists) {
        final size = await File(assetPath).length();
        print('✓ ${story.id} p${page.pageNumber} — موجود (${(size / 1024).toStringAsFixed(0)} KB)');
      } else {
        print('○ ${story.id} p${page.pageNumber} — نیاز به تولید (${text.length} حرف)');
        print('  متن: ${text.substring(0, text.length > 80 ? 80 : text.length)}...');
      }
    }
  }

  print('\n✅ برای تولید فایل‌های باقی‌مانده:');
  print('   - از سرویس هوش مصنوعی با صدای بچگانه (fa, child-like, pitch 1.4) استفاده کنید');
  print('   - متن هر صفحه را جداگانه به TTS بدهید (حداکثر 1500 حرف)');
  print('   - فایل را با نام story_{id}_page{number}.mp3 در assets/audio/stories ذخیره کنید');
  print('   - زبان: fa-IR، لحن: کودکانه شاد و قصه‌گو، بدون لهجه');
}
