import 'package:flutter/material.dart';

/// 🔬 آزمایشگاه علوم فندقی
///
/// شش آزمایشِ تعاملی که همه داخل خودِ برنامه و بدون اینترنت اجرا می‌شوند.
/// هر آزمایش سه بخش دارد: یک نمایشِ تعاملی، توضیحِ «چرا؟» و یک فعالیتِ
/// امن در خانه. هیچ آزمایشی به وسیلهٔ خطرناک یا حرارت نیاز ندارد.
enum ScienceKind {
  floatSink,
  magnet,
  lightMix,
  plant,
  staticElectricity,
  waterCycle,
}

class ScienceExperiment {
  final String id;
  final String title;
  final String emoji;
  final String subtitle;
  final ScienceKind kind;
  final String bigQuestion;
  final String explanation;
  final String homeActivity;
  final String safetyTip;
  final Color themeColor;
  final Color accentColor;

  const ScienceExperiment({
    required this.id,
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.kind,
    required this.bigQuestion,
    required this.explanation,
    required this.homeActivity,
    required this.safetyTip,
    required this.themeColor,
    required this.accentColor,
  });
}

class ScienceData {
  ScienceData._();

  static const List<ScienceExperiment> all = <ScienceExperiment>[
    ScienceExperiment(
      id: 'float_sink',
      title: 'شنا یا غرق؟',
      emoji: '💧',
      subtitle: 'چوب، سنگ و برگ در آب',
      kind: ScienceKind.floatSink,
      bigQuestion: 'چرا چوب روی آب می‌ماند و سنگ فرو می‌رود؟',
      explanation:
          'هر چیزی که سبک‌تر از آب باشد، روی آب شنا می‌کند. چوب سبک است و '
          'روی آب می‌ماند؛ سنگ سنگین‌تر از آب است و به پایین می‌رود. به این '
          'ویژگی «چگالی» می‌گوییم.',
      homeActivity:
          'یک کاسهٔ آب بردار و سه چیزِ بی‌خطر را امتحان کن: یک برگ، یک '
          'قاشقِ پلاستیکی و یک تکه چوب. کدام شنا می‌کند و کدام غرق می‌شود؟',
      safetyTip:
          'با آبِ سرد بازی کن، کاسه را روی زمینِ ثابت بگذار و بعد از بازی '
          'دستمالِ خیس را جمع کن.',
      themeColor: Color(0xFF0E7490),
      accentColor: Color(0xFF67E8F9),
    ),
    ScienceExperiment(
      id: 'magnet',
      title: 'آهنربای جادویی',
      emoji: '🧲',
      subtitle: 'چه چیزهایی جذب می‌شوند؟',
      kind: ScienceKind.magnet,
      bigQuestion: 'آهنربا چه چیزهایی را به خودش جذب می‌کند؟',
      explanation:
          'آهنربا فقط چیزهای آهنی را جذب می‌کند؛ مثل میخ و گیره. کاغذ، '
          'پلاستیک و چوب جذب نمی‌شوند. به نیرویی که از فاصله اثر می‌گذارد '
          '«نیروی مغناطیسی» می‌گوییم.',
      homeActivity:
          'یک آهنربا بردار و به درِ یخچال، یک قاشقِ آهنی و یک کاغذ نزدیک '
          'کن. ببین کدام‌ها جذب می‌شوند.',
      safetyTip:
          'آهنربا را از کارت بانکی و گوشی دور نگه دار و قطعه‌های کوچکِ '
          'آهنی را هرگز در دهان نگذار.',
      themeColor: Color(0xFF7C3AED),
      accentColor: Color(0xFFE9D5FF),
    ),
    ScienceExperiment(
      id: 'light_mix',
      title: 'کارگاه رنگ نور',
      emoji: '🌈',
      subtitle: 'قرمز + آبی = چه رنگی؟',
      kind: ScienceKind.lightMix,
      bigQuestion: 'وقتی رنگ‌های نور را با هم ترکیب کنیم چه می‌شود؟',
      explanation:
          'نورِ قرمز و سبز با هم زرد می‌سازند، سبز و آبی فیروزه‌ای، و قرمز '
          'و آبی ارغوانی. اگر هر سه رنگ با هم بتابند، نور سفید می‌شود. '
          'رنگین‌کمان هم از همین ترکیب‌ها ساخته شده است.',
      homeActivity:
          'با یک چراغ‌قوه و کاغذهای رنگیِ شفاف، نور را روی دیوارِ سفید '
          'بینداز و دو رنگ را روی هم بتابان.',
      safetyTip:
          'به نورِ چراغ‌قوه مستقیم نگاه نکن و چراغ‌قوه را روی چشم کسی '
          'نگیر.',
      themeColor: Color(0xFFB45309),
      accentColor: Color(0xFFFDE68A),
    ),
    ScienceExperiment(
      id: 'plant',
      title: 'باغِ کوچک',
      emoji: '🌱',
      subtitle: 'گیاه چطور بزرگ می‌شود؟',
      kind: ScienceKind.plant,
      bigQuestion: 'گیاه برای بزرگ شدن به چه چیزهایی نیاز دارد؟',
      explanation:
          'گیاه به آب، نورِ خورشید و هوا نیاز دارد. ریشه آب را از خاک '
          'می‌گیرد و برگ‌ها با نورِ خورشید غذا می‌سازند. اگر آب یا نور کم '
          'باشد، گیاه پژمرده می‌شود.',
      homeActivity:
          'یک دانهٔ لوبیا را در پنبهٔ نمدار بگذار و هر روز کمی آب بده. '
          'بعد از چند روز، ریشه و جوانه را ببین.',
      safetyTip:
          'بعد از کار با خاک، دست‌ها را با صابون بشور و دانه‌ها را در '
          'دهان نگذار.',
      themeColor: Color(0xFF15803D),
      accentColor: Color(0xFFBBF7D0),
    ),
    ScienceExperiment(
      id: 'static',
      title: 'بادکنکِ آهنربایی',
      emoji: '🎈',
      subtitle: 'برقِ ساکن و کاغذهای ریز',
      kind: ScienceKind.staticElectricity,
      bigQuestion: 'چرا بادکنکِ مالیده‌شده کاغذها را جذب می‌کند؟',
      explanation:
          'وقتی بادکنک را به مو یا پارچه می‌مالیم، بارِ الکتریکی روی آن '
          'جمع می‌شود. این بار می‌تواند کاغذهای بسیار سبک را به خودش '
          'نزدیک کند. به این پدیده «برقِ ساکن» می‌گوییم.',
      homeActivity:
          'بادکنک را به موهای خشک یا یک پارچهٔ پشمی بمال و به تکه‌های '
          'کوچکِ کاغذ نزدیک کن.',
      safetyTip:
          'بادکنک را به پریز، وسایل برقی و آتش نزدیک نکن. مالیدن شدید به '
          'مو باعث دردِ پوستِ سر می‌شود.',
      themeColor: Color(0xFF1D4ED8),
      accentColor: Color(0xFFBFDBFE),
    ),
    ScienceExperiment(
      id: 'water_cycle',
      title: 'سفرِ قطره',
      emoji: '🌧️',
      subtitle: 'از دریا به ابر و برگشت',
      kind: ScienceKind.waterCycle,
      bigQuestion: 'آبِ دریا چطور به آسمان می‌رود و دوباره برمی‌گردد؟',
      explanation:
          'خورشید آبِ دریا و رودخانه را گرم می‌کند و آن را به بخار تبدیل '
          'می‌کند. بخار بالا می‌رود، سرد می‌شود و ابر می‌سازد. وقتی ابر '
          'سنگین شد، باران می‌بارد و آب دوباره به زمین برمی‌گردد. به این '
          'چرخه، «چرخهٔ آب» می‌گوییم.',
      homeActivity:
          'یک کاسهٔ آب را زیر نورِ آفتاب بگذار و بعد از چند ساعت ببین '
          'سطحِ آب کمتر شده است. بخار به آسمان رفته است!',
      safetyTip:
          'آبِ داغ و بخار را نزدیک صورتت نیاور؛ برای دیدنِ بخار، از فاصله '
          'و پشتِ یک بزرگ‌تر نگاه کن.',
      themeColor: Color(0xFF0369A1),
      accentColor: Color(0xFF7DD3FC),
    ),
  ];

  static ScienceExperiment? byId(String id) {
    for (final experiment in all) {
      if (experiment.id == id) return experiment;
    }
    return null;
  }
}
