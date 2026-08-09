/// ────────────────────────────────────────────────────────────
/// 📖 فاز ۲۹: داستان‌های تعاملی فارسی (شاخه‌ای)
///
/// هر داستان یک گراف از گره‌هاست؛ کودک در هر گره انتخاب می‌کند
/// و مسیر داستان عوض می‌شود. راوی = فندقی (TTS آفلاین).
/// ────────────────────────────────────────────────────────────
class StoryChoice {
  final String label;
  final String nextId;

  const StoryChoice(this.label, this.nextId);
}

class StoryNode {
  final String id;
  final String text;
  final String emoji;
  final List<StoryChoice> choices;

  const StoryNode(this.id, this.text, this.emoji, [this.choices = const []]);
}

class Story {
  final String id;
  final String title;
  final String emoji;
  final Map<String, StoryNode> nodes;
  final String startNode;

  const Story({
    required this.id,
    required this.title,
    required this.emoji,
    required this.nodes,
    required this.startNode,
  });

  StoryNode node(String id) => nodes[id] ?? nodes[startNode]!;
}

/// ده داستان کوتاه با پیام اخلاقی (SEL) — هرکدام ۳-۴ انتخاب.
const List<Story> interactiveStories = <Story>[
  Story(
    id: 'helpful_rabbit',
    title: 'فندقی کمک‌کننده',
    emoji: '🐰',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'یک روز فندقی در جنگل راه می‌رفت که صدای گریه شنید. کی گریه می‌کرد؟',
          '🌲', [StoryChoice('یک جوجه‌گنجشک کوچولو', 'bird'), StoryChoice('یک خرگوش دیگر', 'rabbit')]),
      'bird': StoryNode('bird',
          'جوجه‌گنجشک از لانه‌اش افتاده بود. فندقی چه کار کند؟',
          '🐦', [StoryChoice('کمکش کند به لانه برگردد', 'help'), StoryChoice('تنها بگذاردش و برود', 'leave')]),
      'rabbit': StoryNode('rabbit',
          'خرگوش کوچولو راه خانه‌اش را گم کرده بود. فندقی چه می‌کند؟',
          '🐇', [StoryChoice('دنبال خانه‌اش بگردد', 'find'), StoryChoice('با هم بازی کنند', 'play')]),
      'help': StoryNode('help',
          'فندقی با شاخه‌ها پل ساخت و جوجه را به لانه رساند. جوجه‌گنجشک خوشحال شد!',
          '❤️', [StoryChoice('ادامه', 'end_happy')]),
      'leave': StoryNode('leave',
          'فندقی رفت ولی دلش شاد نبود. برگشت و کمک کرد! جوجه‌گنجشک گفت: «مرسی!»',
          '💛', [StoryChoice('ادامه', 'end_happy')]),
      'find': StoryNode('find',
          'فندقی از روباه پرسید و خانه خرگوش را پیدا کردند. خرگوش خیلی خوشحال شد!',
          '🏡', [StoryChoice('ادامه', 'end_happy')]),
      'play': StoryNode('play',
          'با هم بازی کردند و بعد فندقی خانه خرگوش را پیدا کرد. دوستی برد!',
          '🎈', [StoryChoice('ادامه', 'end_happy')]),
      'end_happy': StoryNode('end_happy',
          'کمک کردن دل آدم را خوشحال می‌کند! تو هم می‌توانی کمک‌کننده باشی. 🌟',
          '🏆'),
    },
  ),
  Story(
    id: 'brave_star',
    title: 'ستاره شجاع',
    emoji: '⭐',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'ستاره کوچولو از آسمان به زمین افتاد و تاریکی را دید. ترسیده بود. چه کند؟',
          '🌙', [StoryChoice('شجاع باشد و جلو برود', 'go'), StoryChoice('گریه کند', 'cry')]),
      'go': StoryNode('go',
          'ستاره جلو رفت و یک بچه‌گربه‌ی گمشده دید که می‌لرزید.',
          '🐱', [StoryChoice('نورش را روشن کند', 'light'), StoryChoice('بترسد و فرار کند', 'run')]),
      'cry': StoryNode('cry',
          'اشک‌های ستاره نور شد! با خودش گفت: «من می‌توانم بدرخشم!»',
          '💧', [StoryChoice('ادامه', 'light')]),
      'light': StoryNode('light',
          'ستاره نورش را روشن کرد و گربه راه خانه‌اش را پیدا کرد. شجاعت یعنی همین!',
          '✨', [StoryChoice('ادامه', 'end')]),
      'run': StoryNode('run',
          'ستاره دوید ولی برگشت؛ گربه به کمک نیاز داشت. شجاع بود و برگشت!',
          '💫', [StoryChoice('ادامه', 'light')]),
      'end': StoryNode('end',
          'شجاعت یعنی حتی وقتی می‌ترسی، کار درست را انجام بدهی. تو شجاعی! 🌟',
          '🏆'),
    },
  ),
  Story(
    id: 'sharing_cake',
    title: 'کیک مشترک',
    emoji: '🍰',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'فندقی یک کیک پخت و خیلی خوشمزه بود. دوستش روباه هم آمد.',
          '🍰', [StoryChoice('کیک را تقسیم کند', 'share'), StoryChoice('تنها بخورد', 'selfish')]),
      'share': StoryNode('share',
          'دو تکه کردند و با هم خوردند. خنده‌شان تا آسمان رفت!',
          '😄', [StoryChoice('ادامه', 'end')]),
      'selfish': StoryNode('selfish',
          'فندقی تنها خورد ولی لذت نبرد. پیش روباه رفت و عذرخواهی کرد و نصف کیک را داد.',
          '💛', [StoryChoice('ادامه', 'end')]),
      'end': StoryNode('end',
          'چیزی که تقسیم می‌شود، دو برابر شیرین است! 🍯',
          '🏆'),
    },
  ),
  Story(
    id: 'little_gardener',
    title: 'باغبان کوچولو',
    emoji: '🌱',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'فندقی یک دانه‌ی کوچولو کاشت. هر روز باید چه کند؟',
          '🌱', [StoryChoice('آب بدهد و مواظبت کند', 'care'), StoryChoice('یادش برود', 'forget')]),
      'care': StoryNode('care',
          'فندقی هر روز آب داد و با مهربانی حرف زد. یک روز جوانه سبز شد!',
          '🌿', [StoryChoice('ادامه', 'end')]),
      'forget': StoryNode('forget',
          'دانه تشنه بود. فندقی یادش آمد و سریع آب داد. هیچ وقت دیر نیست!',
          '💧', [StoryChoice('ادامه', 'end')]),
      'end': StoryNode('end',
          'صبر و مراقبت، گل‌های زیبا می‌سازد. تو هم مثل باغبان باش! 🌸',
          '🏆'),
    },
  ),
  Story(
    id: 'noisy_parrot',
    title: 'طوطی پرحرف',
    emoji: '🦜',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'طوطی همه‌جا بلند حرف می‌زد و بچه‌ها را اذیت می‌کرد. فندقی چه کند؟',
          '🦜', [StoryChoice('به او بگوید آرام باشد', 'tell'), StoryChoice('با او بدرفتاری کند', 'mean')]),
      'tell': StoryNode('tell',
          'فندقی گفت: «وقتی آرام حرف بزنی، همه بهتر گوش می‌کنند!» طوطی یاد گرفت.',
          '🤝', [StoryChoice('ادامه', 'end')]),
      'mean': StoryNode('mean',
          'فندقی عصبانی شد ولی بعد پشیمان شد و با مهربانی توضیح داد. طوطی فهمید.',
          '💛', [StoryChoice('ادامه', 'end')]),
      'end': StoryNode('end',
          'با مهربانی، همه چیز حل می‌شود! 🕊️',
          '🏆'),
    },
  ),
  Story(
    id: 'moon_wish',
    title: 'آرزوی ماه',
    emoji: '🌙',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'ماه کوچولو دلش می‌خواست روی زمین بازی کند. فندقی به او گفت: «بپر پایین!»',
          '🌙', [StoryChoice('بپرد', 'jump'), StoryChoice('بترسد', 'afraid')]),
      'jump': StoryNode('jump',
          'ماه پرید و توی دریاچه افتاد و مثل یک قایق نقره‌ای شنا کرد!',
          '🌊', [StoryChoice('ادامه', 'end')]),
      'afraid': StoryNode('afraid',
          'ماه گفت «می‌ترسم!» فندقی گفت: «ترسیدن اشکالی ندارد. آرام آرام!» ماه پرید.',
          '💫', [StoryChoice('ادامه', 'end')]),
      'end': StoryNode('end',
          'گاهی برای رسیدن به آرزو، فقط یک قدم (یک پرش!) لازم است. 🌟',
          '🏆'),
    },
  ),
  Story(
    id: 'first_day',
    title: 'اولین روز مدرسه',
    emoji: '🎒',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'فندقی اولین روز مدرسه بود و دلش می‌لرزید. کلاس پر از بچه‌های جدید بود.',
          '🏫', [StoryChoice('سلام کند', 'hi'), StoryChoice('گوشه بنشیند', 'hide')]),
      'hi': StoryNode('hi',
          'فندقی سلام کرد و همه جواب دادند. یک دوست جدید پیدا کرد!',
          '👋', [StoryChoice('ادامه', 'end')]),
      'hide': StoryNode('hide',
          'فندقی گوشه نشست ولی دلش تنگ شد. یک بچه گفت «بیا با هم بازی کنیم!»',
          '🧸', [StoryChoice('ادامه', 'end')]),
      'end': StoryNode('end',
          'مدرسه جای دوست‌یابی است! تو هم شجاعانه سلام کن. 🎈',
          '🏆'),
    },
  ),
  Story(
    id: 'sick_friend',
    title: 'دوست مریض',
    emoji: '🤒',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'خرس کوچولو مریض شده بود و خانه بود. فندقی چه کار خوبی می‌تواند کند؟',
          '🐻', [StoryChoice('به دیدنش برود', 'visit'), StoryChoice('بی‌خیالش شود', 'ignore')]),
      'visit': StoryNode('visit',
          'فندقی برایش سوپ گرم برد و قصه گفت. خرس حالش بهتر شد!',
          '🍲', [StoryChoice('ادامه', 'end')]),
      'ignore': StoryNode('ignore',
          'فندقی بازی کرد ولی دلمشغول بود. پیش خرس رفت و عذرخواهی کرد. خرس خوشحال شد!',
          '💛', [StoryChoice('ادامه', 'end')]),
      'end': StoryNode('end',
          'عیادت از مریض، دل را بزرگ می‌کند! ❤️',
          '🏆'),
    },
  ),
  Story(
    id: 'tiny_ant',
    title: 'مورچه‌ی سخت‌کوش',
    emoji: '🐜',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'مورچه‌ها دانه جمع می‌کردند. یکی از آن‌ها خیلی کوچک بود و عقب مانده بود.',
          '🐜', [StoryChoice('به او کمک کند', 'help'), StoryChoice('بخندد', 'laugh')]),
      'help': StoryNode('help',
          'فندقی دانه‌ها را به لانه‌ی مورچه‌ها رساند. همه تشکر کردند!',
          '🤝', [StoryChoice('ادامه', 'end')]),
      'laugh': StoryNode('laugh',
          'فندقی خندید ولی بعد دید مورچه‌ی کوچک خیلی تلاش می‌کند. کمکش کرد!',
          '💛', [StoryChoice('ادامه', 'end')]),
      'end': StoryNode('end',
          'کار تیمی، کار کوچولوها را هم بزرگ می‌کند! 🐝',
          '🏆'),
    },
  ),
  Story(
    id: 'clean_forest',
    title: 'جنگل پاکیزه',
    emoji: '🍃',
    startNode: 'start',
    nodes: {
      'start': StoryNode('start',
          'فندقی دید جنگل پر از زباله شده. چیکار کند؟',
          '🗑️', [StoryChoice('زباله‌ها را جمع کند', 'clean'), StoryChoice('برود و نگاه نکند', 'ignore')]),
      'clean': StoryNode('clean',
          'فندقی زباله‌ها را جمع کرد و سطل گذاشت. حیوانات خوشحال شدند!',
          '♻️', [StoryChoice('ادامه', 'end')]),
      'ignore': StoryNode('ignore',
          'فندقی رفت ولی دوباره برگشت؛ چون جنگل خانه‌ی همه است. تمیزش کرد!',
          '💚', [StoryChoice('ادامه', 'end')]),
      'end': StoryNode('end',
          'محیط زیست مال همه است؛ مواظبش باش! 🌍',
          '🏆'),
    },
  ),
];

Story storyById(String id) {
  for (final story in interactiveStories) {
    if (story.id == id) return story;
  }
  return interactiveStories.first;
}
