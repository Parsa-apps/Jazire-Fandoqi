import 'dart:math';

/// ────────────────────────────────────────────────────────────
/// 📚 فاز ۲۲-۲۸: آکادمی محتوای آموزشی هسته
///
/// یک مرجع داده مرکزی برای همه آکادمی‌ها (اعداد، رنگ، شکل،
/// حیوانات ایران، میوه/بدن، شغل/احساس، مفاهیم). هر کارت =
/// `LearningCard` و هر بازی = موضوعی از `learningTopics`.
/// موتور بازی مشترک (`AcademyGame`) با همین داده‌ها کار می‌کند.
/// ────────────────────────────────────────────────────────────
class LearningCard {
  final String id;
  final String name; // نام فارسی
  final String emoji; // تصویر (بدون فایل سنگین)
  final String sound; // متن خوانده‌شده با TTS
  final String? fact; // نکته آموزشی اختیاری

  const LearningCard({
    required this.id,
    required this.name,
    required this.emoji,
    required this.sound,
    this.fact,
  });
}

class LearningTopic {
  final String id;
  final String title;
  final String skill; // کلید مهارت در GameData.skills
  final List<LearningCard> cards;

  const LearningTopic({
    required this.id,
    required this.title,
    required this.skill,
    required this.cards,
  });

  /// انتخاب `count` کارت تصادفی بدون تکرار (برای هر دور بازی).
  List<LearningCard> pickRandom(int count, {int seed = 0}) {
    final pool = List<LearningCard>.of(cards);
    pool.shuffle(Random(seed + DateTime.now().millisecond));
    return pool.take(count).toList();
  }
}

/// ─────────────── فاز ۲۲: اعداد ۱ تا ۲۰ ───────────────
const List<LearningCard> _numbersCards = <LearningCard>[
  LearningCard(id: 'n1', name: 'یک', emoji: '1️⃣', sound: 'یک'),
  LearningCard(id: 'n2', name: 'دو', emoji: '2️⃣', sound: 'دو'),
  LearningCard(id: 'n3', name: 'سه', emoji: '3️⃣', sound: 'سه'),
  LearningCard(id: 'n4', name: 'چهار', emoji: '4️⃣', sound: 'چهار'),
  LearningCard(id: 'n5', name: 'پنج', emoji: '5️⃣', sound: 'پنج'),
  LearningCard(id: 'n6', name: 'شش', emoji: '6️⃣', sound: 'شش'),
  LearningCard(id: 'n7', name: 'هفت', emoji: '7️⃣', sound: 'هفت'),
  LearningCard(id: 'n8', name: 'هشت', emoji: '8️⃣', sound: 'هشت'),
  LearningCard(id: 'n9', name: 'نه', emoji: '9️⃣', sound: 'نه'),
  LearningCard(id: 'n10', name: 'ده', emoji: '🔟', sound: 'ده'),
  LearningCard(id: 'n11', name: 'یازده', emoji: '🍎', sound: 'یازده'),
  LearningCard(id: 'n12', name: 'دوازده', emoji: '🍏', sound: 'دوازده'),
  LearningCard(id: 'n13', name: 'سیزده', emoji: '🍊', sound: 'سیزده'),
  LearningCard(id: 'n14', name: 'چهارده', emoji: '🍇', sound: 'چهارده'),
  LearningCard(id: 'n15', name: 'پانزده', emoji: '🍉', sound: 'پانزده'),
  LearningCard(id: 'n16', name: 'شانزده', emoji: '🍒', sound: 'شانزده'),
  LearningCard(id: 'n17', name: 'هفده', emoji: '🍑', sound: 'هفده'),
  LearningCard(id: 'n18', name: 'هجده', emoji: '🍍', sound: 'هجده'),
  LearningCard(id: 'n19', name: 'نوزده', emoji: '🥝', sound: 'نوزده'),
  LearningCard(id: 'n20', name: 'بیست', emoji: '🎂', sound: 'بیست'),
];

/// ─────────────── فاز ۲۳: ۱۲ رنگ + ترکیب ───────────────
const List<LearningCard> _colorsCards = <LearningCard>[
  LearningCard(id: 'c1', name: 'قرمز', emoji: '🔴', sound: 'قرمز'),
  LearningCard(id: 'c2', name: 'زرد', emoji: '🟡', sound: 'زرد'),
  LearningCard(id: 'c3', name: 'آبی', emoji: '🔵', sound: 'آبی'),
  LearningCard(id: 'c4', name: 'سبز', emoji: '🟢', sound: 'سبز'),
  LearningCard(id: 'c5', name: 'نارنجی', emoji: '🟠', sound: 'نارنجی'),
  LearningCard(id: 'c6', name: 'بنفش', emoji: '🟣', sound: 'بنفش'),
  LearningCard(id: 'c7', name: 'صورتی', emoji: '🌸', sound: 'صورتی'),
  LearningCard(id: 'c8', name: 'قهوه‌ای', emoji: '🟤', sound: 'قهوه‌ای'),
  LearningCard(id: 'c9', name: 'سفید', emoji: '⚪', sound: 'سفید'),
  LearningCard(id: 'c10', name: 'سیاه', emoji: '⚫', sound: 'سیاه'),
  LearningCard(id: 'c11', name: 'خاکستری', emoji: '🩶', sound: 'خاکستری'),
  LearningCard(id: 'c12', name: 'طلایی', emoji: '🟨', sound: 'طلایی'),
];

/// قوانین آزمایشگاه رنگ: رنگ اول + رنگ دوم = نتیجه.
const Map<String, String> colorMixingRules = <String, String>{
  'آبی+زرد': 'سبز',
  'قرمز+زرد': 'نارنجی',
  'قرمز+آبی': 'بنفش',
  'آبی+سفید': 'آبی روشن',
  'زرد+سفید': 'کرم',
  'قرمز+سفید': 'صورتی',
};

/// ─────────────── فاز ۲۴: ۱۰ شکل ───────────────
const List<LearningCard> _shapesCards = <LearningCard>[
  LearningCard(id: 's1', name: 'دایره', emoji: '⭕', sound: 'دایره'),
  LearningCard(id: 's2', name: 'مربع', emoji: '🟨', sound: 'مربع'),
  LearningCard(id: 's3', name: 'مثلث', emoji: '🔺', sound: 'مثلث'),
  LearningCard(id: 's4', name: 'مستطیل', emoji: '📏', sound: 'مستطیل'),
  LearningCard(id: 's5', name: 'بیضی', emoji: '🥚', sound: 'بیضی'),
  LearningCard(id: 's6', name: 'ستاره', emoji: '⭐', sound: 'ستاره'),
  LearningCard(id: 's7', name: 'قلب', emoji: '❤️', sound: 'قلب'),
  LearningCard(id: 's8', name: 'لوزی', emoji: '💎', sound: 'لوزی'),
  LearningCard(id: 's9', name: 'هلال', emoji: '🌙', sound: 'هلال'),
  LearningCard(id: 's10', name: 'پنج‌ضلعی', emoji: '🛑', sound: 'پنج ضلعی'),
];

/// ─────────────── فاز ۲۵: ۳۰ حیوان بومی ایران ───────────────
const List<LearningCard> _animalsCards = <LearningCard>[
  LearningCard(id: 'a1', name: 'یوزپلنگ', emoji: '🐆', sound: 'یوزپلنگ ایرانی', fact: 'سریع‌ترین جانور دنیا'),
  LearningCard(id: 'a2', name: 'خرس قهوه‌ای', emoji: '🐻', sound: 'خرس قهوه‌ای', fact: 'زمستان را می‌خوابد'),
  LearningCard(id: 'a3', name: 'روباه', emoji: '🦊', sound: 'روباه', fact: 'دم پرپشتی دارد'),
  LearningCard(id: 'a4', name: 'گرگ', emoji: '🐺', sound: 'گرگ'),
  LearningCard(id: 'a5', name: 'پلنگ', emoji: '🐅', sound: 'پلنگ'),
  LearningCard(id: 'a6', name: 'آهو', emoji: '🦌', sound: 'آهو', fact: 'خیلی تند می‌دود'),
  LearningCard(id: 'a7', name: 'قوچ', emoji: '🐏', sound: 'قوچ', fact: 'شاخ‌های خمیده دارد'),
  LearningCard(id: 'a8', name: 'بز کوهی', emoji: '🐐', sound: 'بز کوهی'),
  LearningCard(id: 'a9', name: 'گوزن', emoji: '🦌', sound: 'گوزن'),
  LearningCard(id: 'a10', name: 'خرگوش', emoji: '🐰', sound: 'خرگوش', fact: 'گوش‌های بلند دارد'),
  LearningCard(id: 'a11', name: 'جوجه‌تیغی', emoji: '🦔', sound: 'جوجه تیغی', fact: 'بدنش خار دارد'),
  LearningCard(id: 'a12', name: 'سنجاب', emoji: '🐿️', sound: 'سنجاب', fact: 'گردو جمع می‌کند'),
  LearningCard(id: 'a13', name: 'موش', emoji: '🐭', sound: 'موش'),
  LearningCard(id: 'a14', name: 'گربه', emoji: '🐱', sound: 'گربه', fact: 'میشا می‌گوید'),
  LearningCard(id: 'a15', name: 'سگ', emoji: '🐶', sound: 'سگ', fact: 'وفادار است'),
  LearningCard(id: 'a16', name: 'اسب', emoji: '🐴', sound: 'اسب'),
  LearningCard(id: 'a17', name: 'الاغ', emoji: '🫏', sound: 'الاغ'),
  LearningCard(id: 'a18', name: 'شتر', emoji: '🐫', sound: 'شتر', fact: 'کوهان دارد'),
  LearningCard(id: 'a19', name: 'گاو', emoji: '🐮', sound: 'گاو', fact: 'شیر می‌دهد'),
  LearningCard(id: 'a20', name: 'گوسفند', emoji: '🐑', sound: 'گوسفند'),
  LearningCard(id: 'a21', name: 'مرغ', emoji: '🐔', sound: 'مرغ', fact: 'تخم می‌گذارد'),
  LearningCard(id: 'a22', name: 'خروس', emoji: '🐓', sound: 'خروس', fact: 'صبح بانگ می‌زند'),
  LearningCard(id: 'a23', name: 'اردک', emoji: '🦆', sound: 'اردک', fact: 'شناگر خوبی است'),
  LearningCard(id: 'a24', name: 'غاز', emoji: '🪿', sound: 'غاز'),
  LearningCard(id: 'a25', name: 'کبوتر', emoji: '🕊️', sound: 'کبوتر', fact: 'نماد صلح است'),
  LearningCard(id: 'a26', name: 'گنجشک', emoji: '🐦', sound: 'گنجشک'),
  LearningCard(id: 'a27', name: 'عقاب', emoji: '🦅', sound: 'عقاب', fact: 'شاه پرندگان است'),
  LearningCard(id: 'a28', name: 'شاهین', emoji: '🦅', sound: 'شاهین'),
  LearningCard(id: 'a29', name: 'لاک‌پشت', emoji: '🐢', sound: 'لاک پشت', fact: 'خیلی عمر می‌کند'),
  LearningCard(id: 'a30', name: 'ماهی', emoji: '🐟', sound: 'ماهی', fact: 'در آب زندگی می‌کند'),
];

/// ─────────────── فاز ۲۶: میوه/سبزیجات + بدن ───────────────
const List<LearningCard> _fruitsCards = <LearningCard>[
  LearningCard(id: 'f1', name: 'سیب', emoji: '🍎', sound: 'سیب'),
  LearningCard(id: 'f2', name: 'پرتقال', emoji: '🍊', sound: 'پرتقال'),
  LearningCard(id: 'f3', name: 'موز', emoji: '🍌', sound: 'موز'),
  LearningCard(id: 'f4', name: 'هندوانه', emoji: '🍉', sound: 'هندوانه'),
  LearningCard(id: 'f5', name: 'انگور', emoji: '🍇', sound: 'انگور'),
  LearningCard(id: 'f6', name: 'خیار', emoji: '🥒', sound: 'خیار'),
  LearningCard(id: 'f7', name: 'گوجه', emoji: '🍅', sound: 'گوجه'),
  LearningCard(id: 'f8', name: 'هویج', emoji: '🥕', sound: 'هویج'),
  LearningCard(id: 'f9', name: 'سیب‌زمینی', emoji: '🥔', sound: 'سیب زمینی'),
  LearningCard(id: 'f10', name: 'پیاز', emoji: '🧅', sound: 'پیاز'),
];

const List<LearningCard> _bodyCards = <LearningCard>[
  LearningCard(id: 'b1', name: 'سر', emoji: '👶', sound: 'سر'),
  LearningCard(id: 'b2', name: 'چشم', emoji: '👀', sound: 'چشم'),
  LearningCard(id: 'b3', name: 'گوش', emoji: '👂', sound: 'گوش'),
  LearningCard(id: 'b4', name: 'دهان', emoji: '👄', sound: 'دهان'),
  LearningCard(id: 'b5', name: 'دست', emoji: '✋', sound: 'دست'),
  LearningCard(id: 'b6', name: 'پا', emoji: '🦶', sound: 'پا'),
  LearningCard(id: 'b7', name: 'قلب', emoji: '❤️', sound: 'قلب', fact: 'بدون توقف می‌تپد'),
  LearningCard(id: 'b8', name: 'مغز', emoji: '🧠', sound: 'مغز', fact: 'فرمانده بدن است'),
  LearningCard(id: 'b9', name: 'بینی', emoji: '👃', sound: 'بینی'),
  LearningCard(id: 'b10', name: 'مو', emoji: '💇', sound: 'مو'),
];

/// ─────────────── فاز ۲۷: ۲۰ شغل + ۸ احساس ───────────────
const List<LearningCard> _jobsCards = <LearningCard>[
  LearningCard(id: 'j1', name: 'پزشک', emoji: '👨‍⚕️', sound: 'پزشک', fact: 'بیمارها را درمان می‌کند'),
  LearningCard(id: 'j2', name: 'معلم', emoji: '👩‍🏫', sound: 'معلم', fact: 'به بچه‌ها یاد می‌دهد'),
  LearningCard(id: 'j3', name: 'آتش‌نشان', emoji: '👨‍🚒', sound: 'آتش نشان', fact: 'آتش را خاموش می‌کند'),
  LearningCard(id: 'j4', name: 'پلیس', emoji: '👮', sound: 'پلیس', fact: 'امنیت را حفظ می‌کند'),
  LearningCard(id: 'j5', name: 'کشاورز', emoji: '👨‍🌾', sound: 'کشاورز', fact: 'غذا پرورش می‌دهد'),
  LearningCard(id: 'j6', name: 'نانوا', emoji: '👨‍🍳', sound: 'نانوا', fact: 'نان می‌پزد'),
  LearningCard(id: 'j7', name: 'راننده', emoji: '🚌', sound: 'راننده'),
  LearningCard(id: 'j8', name: 'خلبان', emoji: '👨‍✈️', sound: 'خلبان', fact: 'هواپیما را می‌راند'),
  LearningCard(id: 'j9', name: 'ملوان', emoji: '⛵', sound: 'ملوان'),
  LearningCard(id: 'j10', name: 'نقاش', emoji: '👨‍🎨', sound: 'نقاش'),
  LearningCard(id: 'j11', name: 'موسیقی‌دان', emoji: '🎵', sound: 'موسیقی دان'),
  LearningCard(id: 'j12', name: 'ورزشکار', emoji: '🏃', sound: 'ورزشکار'),
  LearningCard(id: 'j13', name: 'قصاب', emoji: '🥩', sound: 'قصاب'),
  LearningCard(id: 'j14', name: 'بقال', emoji: '🏪', sound: 'بقال'),
  LearningCard(id: 'j15', name: 'مکانیک', emoji: '🔧', sound: 'مکانیک'),
  LearningCard(id: 'j16', name: 'برق‌کار', emoji: '⚡', sound: 'برق کار'),
  LearningCard(id: 'j17', name: 'دندان‌پزشک', emoji: '🦷', sound: 'دندان پزشک'),
  LearningCard(id: 'j18', name: 'مهندس', emoji: '👷', sound: 'مهندس'),
  LearningCard(id: 'j19', name: 'کتابدار', emoji: '📚', sound: 'کتابدار'),
  LearningCard(id: 'j20', name: 'گل‌فروش', emoji: '💐', sound: 'گل فروش'),
];

const List<LearningCard> _emotionsCards = <LearningCard>[
  LearningCard(id: 'e1', name: 'شادی', emoji: '😄', sound: 'شادی'),
  LearningCard(id: 'e2', name: 'ناراحتی', emoji: '😢', sound: 'ناراحتی'),
  LearningCard(id: 'e3', name: 'خشم', emoji: '😠', sound: 'خشم'),
  LearningCard(id: 'e4', name: 'ترس', emoji: '😨', sound: 'ترس'),
  LearningCard(id: 'e5', name: 'تعجب', emoji: '😮', sound: 'تعجب'),
  LearningCard(id: 'e6', name: 'خستگی', emoji: '😪', sound: 'خستگی'),
  LearningCard(id: 'e7', name: 'عشق', emoji: '🥰', sound: 'عشق'),
  LearningCard(id: 'e8', name: 'آرامش', emoji: '😌', sound: 'آرامش'),
];

/// ─────────────── فاز ۲۸: مفاهیم اولیه ───────────────
const List<LearningCard> _conceptsCards = <LearningCard>[
  LearningCard(id: 'k1', name: 'بزرگ', emoji: '🐘', sound: 'بزرگ'),
  LearningCard(id: 'k2', name: 'کوچک', emoji: '🐜', sound: 'کوچک'),
  LearningCard(id: 'k3', name: 'روز', emoji: '☀️', sound: 'روز'),
  LearningCard(id: 'k4', name: 'شب', emoji: '🌙', sound: 'شب'),
  LearningCard(id: 'k5', name: 'بهار', emoji: '🌸', sound: 'بهار', fact: 'فصل شکوفه‌ها'),
  LearningCard(id: 'k6', name: 'تابستان', emoji: '🏖️', sound: 'تابستان', fact: 'فصل گرما'),
  LearningCard(id: 'k7', name: 'پاییز', emoji: '🍂', sound: 'پاییز', fact: 'برگ‌ها می‌ریزند'),
  LearningCard(id: 'k8', name: 'زمستان', emoji: '⛄', sound: 'زمستان', fact: 'فصل برف'),
  LearningCard(id: 'k9', name: 'آفتابی', emoji: '🌞', sound: 'هوای آفتابی'),
  LearningCard(id: 'k10', name: 'بارانی', emoji: '🌧️', sound: 'هوای بارانی'),
  LearningCard(id: 'k11', name: 'ابری', emoji: '☁️', sound: 'هوای ابری'),
  LearningCard(id: 'k12', name: 'برفی', emoji: '❄️', sound: 'هوای برفی'),
  LearningCard(id: 'k13', name: 'ساعت', emoji: '🕐', sound: 'ساعت'),
  LearningCard(id: 'k14', name: 'صبح', emoji: '🌅', sound: 'صبح'),
  LearningCard(id: 'k15', name: 'ظهر', emoji: '🌇', sound: 'ظهر'),
  LearningCard(id: 'k16', name: 'عصر', emoji: '🌆', sound: 'عصر'),
];

/// ثبت‌نام همه موضوعات — موتور بازی با همین فهرست کار می‌کند.
const List<LearningTopic> learningTopics = <LearningTopic>[
  LearningTopic(id: 'numbers', title: 'اعداد ۱ تا ۲۰', skill: 'counting', cards: _numbersCards),
  LearningTopic(id: 'colors', title: 'دنیای رنگ‌ها', skill: 'colors', cards: _colorsCards),
  LearningTopic(id: 'shapes', title: 'دنیای شکل‌ها', skill: 'shapes', cards: _shapesCards),
  LearningTopic(id: 'animals', title: 'حیوانات ایران', skill: 'animals', cards: _animalsCards),
  LearningTopic(id: 'fruits', title: 'میوه و سبزیجات', skill: 'fruits', cards: _fruitsCards),
  LearningTopic(id: 'body', title: 'اعضای بدن', skill: 'body', cards: _bodyCards),
  LearningTopic(id: 'jobs', title: 'شغل‌ها', skill: 'jobs', cards: _jobsCards),
  LearningTopic(id: 'emotions', title: 'احساسات', skill: 'emotions', cards: _emotionsCards),
  LearningTopic(id: 'concepts', title: 'مفاهیم اولیه', skill: 'concepts', cards: _conceptsCards),
];

LearningTopic? learningTopicById(String id) {
  for (final topic in learningTopics) {
    if (topic.id == id) return topic;
  }
  return null;
}
