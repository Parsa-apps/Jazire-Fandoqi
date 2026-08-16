/// ۱۰ دنیای مهارت زندگی — محتوای بومی برای کودکان ۳ تا ۸ سال ایران.
class LifeSkillQuestion {
  final String id;
  final String prompt;
  final String emoji;
  final List<String> options;
  final int correctIndex;
  final String fact;
  final String vocab;

  const LifeSkillQuestion({
    required this.id,
    required this.prompt,
    required this.emoji,
    required this.options,
    required this.correctIndex,
    required this.fact,
    this.vocab = '',
  });
}

class LifeSkillTopic {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String skill;
  final List<String> tags;
  final List<LifeSkillQuestion> questions;

  const LifeSkillTopic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.skill,
    required this.tags,
    required this.questions,
  });
}

class LifeSkillsData {
  LifeSkillsData._();

  static LifeSkillTopic? byId(String id) {
    for (final t in topics) {
      if (t.id == id) return t;
    }
    return null;
  }

  static const List<LifeSkillTopic> topics = [
    LifeSkillTopic(
      id: 'days',
      title: 'روزهای هفته',
      subtitle: 'شنبه تا جمعه با فندقی',
      emoji: '📅',
      skill: 'time',
      tags: ['هفته', 'تقویم'],
      questions: [
        LifeSkillQuestion(id: 'd1', prompt: 'اولین روز هفته در ایران کدام است؟', emoji: '🌅', options: ['شنبه', 'یکشنبه', 'جمعه', 'دوشنبه'], correctIndex: 0, fact: 'هفته ایرانی از شنبه شروع می‌شود.', vocab: 'شنبه'),
        LifeSkillQuestion(id: 'd2', prompt: 'آخرین روز هفته و روز تعطیل رسمی کدام است؟', emoji: '🕌', options: ['پنجشنبه', 'جمعه', 'شنبه', 'چهارشنبه'], correctIndex: 1, fact: 'جمعه در ایران روز تعطیل رسمی است.', vocab: 'جمعه'),
        LifeSkillQuestion(id: 'd3', prompt: 'روز بعد از شنبه چیست؟', emoji: '➡️', options: ['دوشنبه', 'یکشنبه', 'سه‌شنبه', 'جمعه'], correctIndex: 1, fact: 'بعد از شنبه، یکشنبه می‌آید.', vocab: 'یکشنبه'),
        LifeSkillQuestion(id: 'd4', prompt: 'چند روز در یک هفته هست؟', emoji: '7️⃣', options: ['پنج', 'شش', 'هفت', 'هشت'], correctIndex: 2, fact: 'هر هفته ۷ روز دارد.', vocab: 'هفته'),
        LifeSkillQuestion(id: 'd5', prompt: 'روز وسط هفته معمولاً کدام است؟', emoji: '📅', options: ['سه‌شنبه', 'شنبه', 'جمعه', 'یکشنبه'], correctIndex: 0, fact: 'سه‌شنبه تقریباً وسط هفته است.', vocab: 'سه‌شنبه'),
        LifeSkillQuestion(id: 'd6', prompt: 'قبل از جمعه چه روزی است؟', emoji: '🔙', options: ['شنبه', 'پنجشنبه', 'چهارشنبه', 'دوشنبه'], correctIndex: 1, fact: 'پنجشنبه روز قبل از جمعه است.', vocab: 'پنجشنبه'),
        LifeSkillQuestion(id: 'd7', prompt: 'اگر امروز دوشنبه باشد، فردا چیست؟', emoji: '🔮', options: ['یکشنبه', 'سه‌شنبه', 'چهارشنبه', 'شنبه'], correctIndex: 1, fact: 'بعد از دوشنبه، سه‌شنبه می‌آید.', vocab: 'فردا'),
        LifeSkillQuestion(id: 'd8', prompt: 'کدام روز معمولاً مدرسه دارد؟', emoji: '🏫', options: ['جمعه', 'شنبه', 'هر دو تعطیل‌اند', 'هیچ‌کدام'], correctIndex: 1, fact: 'بیشتر مدرسه‌ها شنبه تا چهارشنبه باز هستند.', vocab: 'مدرسه'),
      ],
    ),
    LifeSkillTopic(
      id: 'months',
      title: 'ماه‌های شمسی',
      subtitle: 'فروردین تا اسفند',
      emoji: '🌷',
      skill: 'time',
      tags: ['ماه', 'سال'],
      questions: [
        LifeSkillQuestion(id: 'm1', prompt: 'اولین ماه سال شمسی چیست؟', emoji: '🌸', options: ['فروردین', 'اردیبهشت', 'مهر', 'دی'], correctIndex: 0, fact: 'سال نو با فروردین و نوروز شروع می‌شود.', vocab: 'فروردین'),
        LifeSkillQuestion(id: 'm2', prompt: 'آخرین ماه سال کدام است؟', emoji: '❄️', options: ['بهمن', 'آذر', 'اسفند', 'شهریور'], correctIndex: 2, fact: 'اسفند ماه پایانی سال است.', vocab: 'اسفند'),
        LifeSkillQuestion(id: 'm3', prompt: 'ماه مهر مال کدام فصل است؟', emoji: '🍂', options: ['بهار', 'تابستان', 'پاییز', 'زمستان'], correctIndex: 2, fact: 'مهر شروع پاییز و مدرسه است.', vocab: 'مهر'),
        LifeSkillQuestion(id: 'm4', prompt: 'چند ماه در سال شمسی هست؟', emoji: '📅', options: ['۱۰', '۱۱', '۱۲', '۱۳'], correctIndex: 2, fact: 'سال ۱۲ ماه دارد.', vocab: 'سال'),
        LifeSkillQuestion(id: 'm5', prompt: 'ماه تیر معمولاً چه هوایی دارد؟', emoji: '☀️', options: ['برفی', 'گرم تابستانی', 'بارانی پاییزی', 'خنک بهاری'], correctIndex: 1, fact: 'تیر وسط تابستان است.', vocab: 'تابستان'),
        LifeSkillQuestion(id: 'm6', prompt: 'یلدا در کدام ماه است؟', emoji: '🍉', options: ['آذر', 'دی', 'بهمن', 'مهر'], correctIndex: 0, fact: 'شب یلدا پایان آذر است.', vocab: 'یلدا'),
        LifeSkillQuestion(id: 'm7', prompt: 'ماه بعد از فروردین چیست؟', emoji: '🌼', options: ['خرداد', 'اردیبهشت', 'تیر', 'اسفند'], correctIndex: 1, fact: 'اردیبهشت ماه گل‌هاست.', vocab: 'اردیبهشت'),
        LifeSkillQuestion(id: 'm8', prompt: 'کدام ماه زمستان است؟', emoji: '⛄', options: ['مرداد', 'دی', 'فروردین', 'شهریور'], correctIndex: 1, fact: 'دی، بهمن و اسفند زمستان‌اند.', vocab: 'زمستان'),
      ],
    ),
    LifeSkillTopic(
      id: 'opposites',
      title: 'متضادها',
      subtitle: 'بزرگ و کوچک، بالا و پایین',
      emoji: '⚖️',
      skill: 'concepts',
      tags: ['متضاد', 'مفهوم'],
      questions: [
        LifeSkillQuestion(id: 'o1', prompt: 'متضاد «بزرگ» چیست؟', emoji: '🐘', options: ['کوچک', 'بلند', 'سنگین', 'سریع'], correctIndex: 0, fact: 'فیل بزرگ است و مورچه کوچک.', vocab: 'کوچک'),
        LifeSkillQuestion(id: 'o2', prompt: 'متضاد «بالا» چیست؟', emoji: '⬆️', options: ['چپ', 'پایین', 'جلو', 'دور'], correctIndex: 1, fact: 'آسمان بالا و زمین پایین است.', vocab: 'پایین'),
        LifeSkillQuestion(id: 'o3', prompt: 'متضاد «روز» چیست؟', emoji: '☀️', options: ['صبح', 'شب', 'ظهر', 'فردا'], correctIndex: 1, fact: 'روز روشن است و شب تاریک.', vocab: 'شب'),
        LifeSkillQuestion(id: 'o4', prompt: 'متضاد «سرد» چیست؟', emoji: '🧊', options: ['نرم', 'گرم', 'تر', 'تیز'], correctIndex: 1, fact: 'یخ سرد است و چای گرم.', vocab: 'گرم'),
        LifeSkillQuestion(id: 'o5', prompt: 'متضاد «باز» چیست؟', emoji: '🚪', options: ['بسته', 'نرم', 'سبک', 'تازه'], correctIndex: 0, fact: 'در را باز یا بسته می‌کنیم.', vocab: 'بسته'),
        LifeSkillQuestion(id: 'o6', prompt: 'متضاد «سریع» چیست؟', emoji: '🐇', options: ['بلند', 'آهسته', 'نزدیک', 'پر'], correctIndex: 1, fact: 'خرگوش سریع است و لاک‌پشت آهسته.', vocab: 'آهسته'),
        LifeSkillQuestion(id: 'o7', prompt: 'متضاد «پر» چیست؟', emoji: '🥛', options: ['خالی', 'تر', 'شیرین', 'گرد'], correctIndex: 0, fact: 'لیوان می‌تواند پر یا خالی باشد.', vocab: 'خالی'),
        LifeSkillQuestion(id: 'o8', prompt: 'متضاد «خوشحال» چیست؟', emoji: '😊', options: ['بلند', 'ناراحت', 'گرسنه', 'تمیز'], correctIndex: 1, fact: 'احساس‌ها هم متضاد دارند.', vocab: 'ناراحت'),
      ],
    ),
    LifeSkillTopic(
      id: 'rhymes',
      title: 'قافیه‌ها',
      subtitle: 'کلمه‌هایی که هم‌صدا تمام می‌شوند',
      emoji: '🎵',
      skill: 'vocab',
      tags: ['شعر', 'صدا'],
      questions: [
        LifeSkillQuestion(id: 'r1', prompt: 'کدام کلمه با «ماه» هم‌قافیه است؟', emoji: '🌙', options: ['راه', 'سیب', 'میز', 'ابر'], correctIndex: 0, fact: 'ماه و راه هر دو با «اه» تمام می‌شوند.', vocab: 'قافیه'),
        LifeSkillQuestion(id: 'r2', prompt: 'کدام کلمه با «گل» هم‌قافیه است؟', emoji: '🌸', options: ['میز', 'پل', 'نان', 'آب'], correctIndex: 1, fact: 'گل و پل هم‌قافیه‌اند.', vocab: 'گل'),
        LifeSkillQuestion(id: 'r3', prompt: 'کدام کلمه با «باران» هم‌قافیه است؟', emoji: '🌧️', options: ['یاران', 'کتاب', 'سیب', 'میز'], correctIndex: 0, fact: 'باران و یاران هر دو با «ان» تمام می‌شوند.', vocab: 'باران'),
        LifeSkillQuestion(id: 'r4', prompt: 'کدام کلمه با «خورشید» هم‌قافیه نیست؟', emoji: '☀️', options: ['امید', 'سفید', 'میز', 'جدید'], correctIndex: 2, fact: 'میز با بقیه هم‌قافیه نیست.', vocab: 'خورشید'),
        LifeSkillQuestion(id: 'r5', prompt: '«شب» با کدام هم‌قافیه است؟', emoji: '🌃', options: ['مهتاب', 'تب', 'صبح', 'روز'], correctIndex: 1, fact: 'شب و تب هر دو با «ب» تمام می‌شوند.', vocab: 'شب'),
        LifeSkillQuestion(id: 'r6', prompt: 'کدام جفت هم‌قافیه‌اند؟', emoji: '🎶', options: ['سیب و موز', 'نان و جان', 'میز و صندلی', 'آب و نان'], correctIndex: 1, fact: 'نان و جان هر دو با «ان» تمام می‌شوند.', vocab: 'نان'),
        LifeSkillQuestion(id: 'r7', prompt: '«دوست» با کدام هم‌قافیه است؟', emoji: '🤝', options: ['پوست', 'کتاب', 'درخت', 'آسمان'], correctIndex: 0, fact: 'دوست و پوست هم‌قافیه‌اند.', vocab: 'دوست'),
        LifeSkillQuestion(id: 'r8', prompt: 'شعر کودکانه معمولاً چه دارد؟', emoji: '📝', options: ['قافیه و وزن شاد', 'فقط عدد', 'نقشه', 'جدول'], correctIndex: 0, fact: 'قافیه شعر را آهنگین می‌کند.', vocab: 'شعر'),
      ],
    ),
    LifeSkillTopic(
      id: 'iran_geo',
      title: 'ایران من',
      subtitle: 'دریا، کوه و شهرهای ایران',
      emoji: '🇮🇷',
      skill: 'concepts',
      tags: ['ایران', 'جغرافیا'],
      questions: [
        LifeSkillQuestion(id: 'g1', prompt: 'پایتخت ایران کدام شهر است؟', emoji: '🏛️', options: ['تهران', 'شیراز', 'تبریز', 'مشهد'], correctIndex: 0, fact: 'تهران پایتخت ایران است.', vocab: 'پایتخت'),
        LifeSkillQuestion(id: 'g2', prompt: 'دریای شمال ایران چه نام دارد؟', emoji: '🌊', options: ['خلیج فارس', 'دریای خزر', 'دریای عمان', 'اقیانوس هند'], correctIndex: 1, fact: 'شمال ایران به دریای خزر می‌رسد.', vocab: 'خزر'),
        LifeSkillQuestion(id: 'g3', prompt: 'جنوب ایران به کدام آب می‌رسد؟', emoji: '🚤', options: ['دریای خزر', 'خلیج فارس', 'رود نیل', 'دریاچه ارومیه'], correctIndex: 1, fact: 'خلیج فارس در جنوب ایران است.', vocab: 'خلیج'),
        LifeSkillQuestion(id: 'g4', prompt: 'بلندترین قله ایران کدام است؟', emoji: '⛰️', options: ['دماوند', 'الوند', 'تفتان', 'سبلان'], correctIndex: 0, fact: 'دماوند بلندترین کوه ایران است.', vocab: 'دماوند'),
        LifeSkillQuestion(id: 'g5', prompt: 'شهر شعر و باغ‌های ایران کدام است؟', emoji: '🌹', options: ['شیراز', 'یزد', 'قم', 'اهواز'], correctIndex: 0, fact: 'شیراز را شهر شعر و باغ می‌نامند.', vocab: 'شیراز'),
        LifeSkillQuestion(id: 'g6', prompt: 'پرچم ایران چند رنگ اصلی دارد؟', emoji: '🚩', options: ['۲', '۳', '۴', '۵'], correctIndex: 1, fact: 'سبز، سفید و قرمز رنگ‌های پرچم‌اند.', vocab: 'پرچم'),
        LifeSkillQuestion(id: 'g7', prompt: 'کدام شهر به حرم امام رضا معروف است؟', emoji: '🕌', options: ['اصفهان', 'مشهد', 'کرمان', 'رشت'], correctIndex: 1, fact: 'مشهد شهر زیارتی شرق ایران است.', vocab: 'مشهد'),
        LifeSkillQuestion(id: 'g8', prompt: 'اصفهان به چه معروف است؟', emoji: '🌉', options: ['پل‌های تاریخی و میدان نقش جهان', 'اسکی روی برف', 'بندر نفت', 'جنگل انبوه شمال'], correctIndex: 0, fact: 'نقش جهان یکی از زیباترین میدان‌های جهان است.', vocab: 'اصفهان'),
      ],
    ),
    LifeSkillTopic(
      id: 'traffic',
      title: 'ایمنی خیابان',
      subtitle: 'چراغ راهنما و عبور امن',
      emoji: '🚦',
      skill: 'concepts',
      tags: ['ترافیک', 'ایمنی'],
      questions: [
        LifeSkillQuestion(id: 't1', prompt: 'چراغ قرمز یعنی چه؟', emoji: '🔴', options: ['بایست', 'برو', 'بدو', 'بپر'], correctIndex: 0, fact: 'قرمز یعنی توقف کامل.', vocab: 'توقف'),
        LifeSkillQuestion(id: 't2', prompt: 'چراغ سبز یعنی چه؟', emoji: '🟢', options: ['بایست', 'اگر مسیر خالی است برو', 'برعکس برو', 'بدو وسط خیابان'], correctIndex: 1, fact: 'سبز یعنی عبور با احتیاط.', vocab: 'عبور'),
        LifeSkillQuestion(id: 't3', prompt: 'از خیابان از کجا رد شویم؟', emoji: '🚶', options: ['وسط ماشین‌ها', 'خط عابر پیاده', 'پشت کامیون', 'از روی چمن وسط'], correctIndex: 1, fact: 'همیشه از خط عابر و با بزرگ‌تر رد شو.', vocab: 'عابر'),
        LifeSkillQuestion(id: 't4', prompt: 'در ماشین باید چه کار کنیم؟', emoji: '🚗', options: ['کمربند ببندیم', 'دست از پنجره بیرون ببریم', 'در را باز کنیم', 'بلند شویم'], correctIndex: 0, fact: 'کمربند جان ما را حفظ می‌کند.', vocab: 'کمربند'),
        LifeSkillQuestion(id: 't5', prompt: 'صدای آژیر آمبولانس یعنی چه؟', emoji: '🚑', options: ['راه را باز کنیم', 'دنبالش بدویم', 'بایستیم وسط جاده', 'بوق بزنیم'], correctIndex: 0, fact: 'آمبولانس برای کمک به بیمار عجله دارد.', vocab: 'آمبولانس'),
        LifeSkillQuestion(id: 't6', prompt: 'چراغ زرد یعنی چه؟', emoji: '🟡', options: ['عجله کن', 'آماده توقف شو', 'برقص', 'برگرد'], correctIndex: 1, fact: 'زرد یعنی کمی دیگر قرمز می‌شود.', vocab: 'احتیاط'),
        LifeSkillQuestion(id: 't7', prompt: 'توپ اگر به خیابان رفت چه کنیم؟', emoji: '⚽', options: ['بدون نگاه بدویم', 'اول به بزرگ‌تر بگوییم', 'چشم‌بسته برویم', 'پشت ماشین قایم شویم'], correctIndex: 1, fact: 'هیچ توپی از ایمنی تو مهم‌تر نیست.', vocab: 'ایمنی'),
        LifeSkillQuestion(id: 't8', prompt: 'در پیاده‌رو باید از کدام سمت برویم؟', emoji: '👟', options: ['با آرامش و کنار بزرگ‌تر', 'وسط خیابان', 'روی چرخ ماشین', 'خلاف چراغ'], correctIndex: 0, fact: 'پیاده‌رو جای عابر است، خیابان جای ماشین.', vocab: 'پیاده‌رو'),
      ],
    ),
    LifeSkillTopic(
      id: 'hygiene',
      title: 'بهداشت من',
      subtitle: 'دست شستن، دندان و خواب',
      emoji: '🧼',
      skill: 'body',
      tags: ['بهداشت', 'سلامت'],
      questions: [
        LifeSkillQuestion(id: 'h1', prompt: 'قبل از غذا چه کار کنیم؟', emoji: '🍽️', options: ['دست‌ها را با آب و صابون بشوییم', 'فقط دستمال خشک بکشیم', 'هیچ‌کار', 'با خاک پاک کنیم'], correctIndex: 0, fact: 'صابون میکروب‌ها را می‌شوید.', vocab: 'صابون'),
        LifeSkillQuestion(id: 'h2', prompt: 'بعد از دستشویی چه کار کنیم؟', emoji: '🚽', options: ['دست بشوییم', 'مستقیم غذا بخوریم', 'به چشم دست بزنیم', 'فراموش کنیم'], correctIndex: 0, fact: 'شستن دست بعد از دستشویی خیلی مهم است.', vocab: 'بهداشت'),
        LifeSkillQuestion(id: 'h3', prompt: 'دندان‌ها را چند بار در روز مسواک بزنیم؟', emoji: '🪥', options: ['هیچ', 'حداقل دو بار', 'فقط جمعه', 'ماهی یک‌بار'], correctIndex: 1, fact: 'صبح و شب مسواک دوست دندان است.', vocab: 'مسواک'),
        LifeSkillQuestion(id: 'h4', prompt: 'وقتی عطسه می‌کنیم چه کنیم؟', emoji: '🤧', options: ['به سمت دوست عطسه کنیم', 'دهان را با دستمال یا آرنج بپوشانیم', 'فریاد بزنیم', 'در را باز کنیم و بدویم'], correctIndex: 1, fact: 'پوشاندن دهان جلوی پخش میکروب را می‌گیرد.', vocab: 'عطسه'),
        LifeSkillQuestion(id: 'h5', prompt: 'برای خواب خوب چه کار کنیم؟', emoji: '🌙', options: ['نور کم و مسواک و قصه آرام', 'نوشابه و کارتون تند', 'دویدن تا نیمه‌شب', 'غذای خیلی سنگین'], correctIndex: 0, fact: 'خواب کافی مغز را قوی می‌کند.', vocab: 'خواب'),
        LifeSkillQuestion(id: 'h6', prompt: 'ناخن‌ها را چرا کوتاه می‌کنیم؟', emoji: '💅', options: ['برای تمیزی و جلوگیری از میکروب', 'برای تیزتر شدن', 'چون زشت است فقط', 'لازم نیست'], correctIndex: 0, fact: 'زیر ناخن بلند میکروب جمع می‌شود.', vocab: 'ناخن'),
        LifeSkillQuestion(id: 'h7', prompt: 'آب آشامیدنی باید چگونه باشد؟', emoji: '💧', options: ['تمیز و از شیر یا بطری سالم', 'از چاله خیابان', 'از گلدان', 'هر مایعی'], correctIndex: 0, fact: 'فقط آب سالم بنوش.', vocab: 'آب'),
        LifeSkillQuestion(id: 'h8', prompt: 'میوه‌ها را قبل از خوردن چه کنیم؟', emoji: '🍎', options: ['بشوییم', 'با خاک پاک کنیم', 'همان‌طور گاز بزنیم', 'در فریزر بگذاریم و نشوییم'], correctIndex: 0, fact: 'شست‌وشوی میوه گرد و غبار را می‌برد.', vocab: 'میوه'),
      ],
    ),
    LifeSkillTopic(
      id: 'money',
      title: 'پول و تومان',
      subtitle: 'سکه، خرید و پس‌انداز',
      emoji: '🪙',
      skill: 'math',
      tags: ['پول', 'تومان'],
      questions: [
        LifeSkillQuestion(id: 'n1', prompt: 'واحد پول ایران چیست؟', emoji: '🇮🇷', options: ['تومان / ریال', 'دلار', 'یورو', 'لیر'], correctIndex: 0, fact: 'ما با تومان و ریال خرید می‌کنیم.', vocab: 'تومان'),
        LifeSkillQuestion(id: 'n2', prompt: 'اگر ۲ سکه ۱ تومانی داشته باشی جمعش چند است؟', emoji: '🪙', options: ['۱', '۲', '۳', '۰'], correctIndex: 1, fact: '۱+۱ می‌شود ۲.', vocab: 'جمع'),
        LifeSkillQuestion(id: 'n3', prompt: 'پس‌انداز یعنی چه؟', emoji: '🐷', options: ['خرج کردن همه پول همین حالا', 'نگه داشتن بخشی از پول برای بعد', 'دور ریختن سکه', 'قرض گرفتن همیشگی'], correctIndex: 1, fact: 'قلک به ما کمک می‌کند صبور باشیم.', vocab: 'پس‌انداز'),
        LifeSkillQuestion(id: 'n4', prompt: 'نان ۵ تومان است و تو ۷ تومان داری. باقی‌مانده؟', emoji: '🍞', options: ['۲', '۱۲', '۵', '۰'], correctIndex: 0, fact: '۷ منهای ۵ می‌شود ۲.', vocab: 'باقی'),
        LifeSkillQuestion(id: 'n5', prompt: 'قبل از خرید چه کار هوشمندانه‌ای است؟', emoji: '🛒', options: ['فکر کنیم لازم است یا نه', 'هر چه دیدیم بخریم', 'پول دیگران را برداریم', 'گریه کنیم'], correctIndex: 0, fact: 'خرید با فکر یعنی بزرگ شدن.', vocab: 'خرید'),
        LifeSkillQuestion(id: 'n6', prompt: 'سکه معمولاً از چیست؟', emoji: '⚙️', options: ['فلز', 'نان', 'ابر', 'چوب نرم'], correctIndex: 0, fact: 'سکه فلزی است و اسکناس کاغذی.', vocab: 'سکه'),
        LifeSkillQuestion(id: 'n7', prompt: 'اگر چیزی گران‌تر از پولت باشد چه کنی؟', emoji: '🤔', options: ['صبر کنیم یا چیز ارزان‌تر بخریم', 'بدون پرداخت برداریم', 'قهر کنیم و بشکنیم', 'گریه تا شب'], correctIndex: 0, fact: 'صبر و انتخاب دوباره نشانه هوش است.', vocab: 'صبر'),
        LifeSkillQuestion(id: 'n8', prompt: '۲ تومان و ۲ تومان و ۲ تومان جمعش چند است؟', emoji: '🍦', options: ['۵', '۶', '۲', '۳'], correctIndex: 1, fact: '۲+۲+۲ می‌شود ۶. این جمع است، هنوز ضرب یاد نمی‌گیریم.', vocab: 'جمع'),
      ],
    ),
    LifeSkillTopic(
      id: 'weather',
      title: 'لباس و هوا',
      subtitle: 'چه بپوشیم وقتی هوا عوض می‌شود',
      emoji: '🌦️',
      skill: 'weather',
      tags: ['هوا', 'لباس'],
      questions: [
        LifeSkillQuestion(id: 'w1', prompt: 'هوای برفی چه لباسی می‌خواهد؟', emoji: '❄️', options: ['مایو', 'کاپشن و دستکش', 'دمپایی تنها', 'تی‌شرت نازک'], correctIndex: 1, fact: 'سرما را با لباس گرم جواب می‌دهیم.', vocab: 'کاپشن'),
        LifeSkillQuestion(id: 'w2', prompt: 'روز بارانی چه چیزی لازم است؟', emoji: '🌧️', options: ['چتر یا بارانی', 'عینک آفتابی فقط', 'کلاه ساحلی', 'هیچ'], correctIndex: 0, fact: 'چتر ما را خشک نگه می‌دارد.', vocab: 'چتر'),
        LifeSkillQuestion(id: 'w3', prompt: 'روز خیلی آفتابی تابستان؟', emoji: '🌞', options: ['لباس خنک و کلاه و آب', 'پالتوی پشمی', 'چکمه برف', 'شیلنگ آتش‌نشانی'], correctIndex: 0, fact: 'آفتاب زیاد به کلاه و آب نیاز دارد.', vocab: 'کلاه'),
        LifeSkillQuestion(id: 'w4', prompt: 'اگر هوا ابری و سرد شد چه کنیم؟', emoji: '☁️', options: ['یک لایه لباس اضافه کنیم', 'همه لباس را درآوریم', 'پابرهنه برویم', 'یخ بخوریم'], correctIndex: 0, fact: 'لایه‌لایه پوشیدن هوشمندانه است.', vocab: 'لایه'),
        LifeSkillQuestion(id: 'w5', prompt: 'کدام نشانه هوای گرم است؟', emoji: '🌡️', options: ['عرق کردن و آفتاب تند', 'بخار دهان در سرما', 'یخ روی شیشه', 'برف'], correctIndex: 0, fact: 'بدن با عرق خودش را خنک می‌کند.', vocab: 'گرما'),
        LifeSkillQuestion(id: 'w6', prompt: 'چکمه پلاستیکی برای کدام هواست؟', emoji: '👢', options: ['باران و گل', 'صحرای خشک', 'اتاق خواب', 'استخر سرپوشیده'], correctIndex: 0, fact: 'چکمه پا را از گل و آب حفظ می‌کند.', vocab: 'چکمه'),
        LifeSkillQuestion(id: 'w7', prompt: 'عینک آفتابی چه کمکی می‌کند؟', emoji: '🕶️', options: ['چشم را از نور تند حفظ می‌کند', 'ما را نامرئی می‌کند', 'باران را بند می‌آورد', 'دندان را سفید می‌کند'], correctIndex: 0, fact: 'نور تند به چشم آسیب می‌زند.', vocab: 'عینک'),
        LifeSkillQuestion(id: 'w8', prompt: 'فصل مناسب کاشت گل در ایران؟', emoji: '🌱', options: ['بهار', 'وسط زمستان یخی', 'فقط شب یلدا', 'هیچ‌وقت'], correctIndex: 0, fact: 'بهار فصل شکوفه و کاشتن است.', vocab: 'بهار'),
      ],
    ),
    LifeSkillTopic(
      id: 'observe',
      title: 'چشم تیزبین',
      subtitle: 'سایه، چیز گمشده و دقت',
      emoji: '🔍',
      skill: 'memory',
      tags: ['دقت', 'سایه'],
      questions: [
        LifeSkillQuestion(id: 'v1', prompt: 'سایه درخت معمولاً شبیه چیست؟', emoji: '🌳', options: ['شکل خود درخت روی زمین', 'یک ماشین', 'یک ماهی', 'ابر مربع'], correctIndex: 0, fact: 'سایه شکل جسم را دنبال می‌کند.', vocab: 'سایه'),
        LifeSkillQuestion(id: 'v2', prompt: 'سایه کی بلندتر است؟', emoji: '🌅', options: ['صبح زود یا عصر', 'ظهر دقیق', 'شب کامل بدون ماه', 'زیر آب'], correctIndex: 0, fact: 'وقتی خورشید کج است سایه دراز می‌شود.', vocab: 'ظهر'),
        LifeSkillQuestion(id: 'v3', prompt: 'در گروه 🍎🍎🍌🍎 کدام فرق دارد؟', emoji: '👀', options: ['موز', 'همه سیب‌اند', 'هیچ‌کدام', 'فقط رنگ'], correctIndex: 0, fact: 'یک موز بین سیب‌ها قایم شده.', vocab: 'تفاوت'),
        LifeSkillQuestion(id: 'v4', prompt: 'اگر میز ۴ پایه دارد و یکی دیده نمی‌شود؟', emoji: '🪑', options: ['احتمالاً پشت پایه دیگر پنهان است', 'میز پرنده است', 'پایه وجود ندارد ابدی', 'باید بشکنیم'], correctIndex: 0, fact: 'گاهی چیزها از زاویه دیده نمی‌شوند.', vocab: 'زاویه'),
        LifeSkillQuestion(id: 'v5', prompt: 'صدای گربه کدام است؟', emoji: '🐱', options: ['میو', 'عوعو', 'ما', 'ایووو'], correctIndex: 0, fact: 'گربه میو می‌کند و سگ عوعو.', vocab: 'میو'),
        LifeSkillQuestion(id: 'v6', prompt: 'کدام سایه به توپ گرد می‌خورد؟', emoji: '⚽', options: ['دایره', 'مثلث تیز', 'ستاره', 'هلال باریک'], correctIndex: 0, fact: 'توپ گرد سایه گرد می‌سازد.', vocab: 'دایره'),
        LifeSkillQuestion(id: 'v7', prompt: '۳ پرنده روی سیم بودند، یکی پرید. چند تا ماند؟', emoji: '🐦', options: ['۲', '۳', '۴', '۰'], correctIndex: 0, fact: '۳ منهای ۱ می‌شود ۲.', vocab: 'شمارش'),
        LifeSkillQuestion(id: 'v8', prompt: 'کدام کار به «دقت دیدن» کمک می‌کند؟', emoji: '🔎', options: ['آرام نگاه کردن و مقایسه', 'چشمک سریع بدون نگاه', 'چشم بستن', 'دویدن'], correctIndex: 0, fact: 'کارآگاه‌های کوچک آرام نگاه می‌کنند.', vocab: 'دقت'),
      ],
    ),
  ];
}
