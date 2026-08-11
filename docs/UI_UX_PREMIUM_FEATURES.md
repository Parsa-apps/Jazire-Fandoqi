# 🎨 راهنمای ویژگی‌های UI/UX پریمیوم

## 📦 فایل‌های جدید اضافه شده

### 1. سیستم ذرات جشن (`particle_celebration.dart`)

سیستم جشن‌گیری حرفه‌ای برای جشن برد بازی:

```dart
import 'package:amoozesh_fandoghi/shared/widgets/premium/particle_celebration.dart';

// استفاده ساده
ParticleCelebration(
  particleCount: 80,
  duration: Duration(milliseconds: 3000),
  colors: [
    Color(0xFFFF6B6B),
    Color(0xFFFF8E53),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFC084FC),
  ],
  onComplete: () => print('جشن تمام شد!'),
)

// پوشش جشن برای کل صفحه
ConfettiOverlay(
  isActive: _showCelebration,
  child: YourPage(),
  onComplete: () {},
)

// انفجار ستاره‌ای
StarBurst(
  position: Offset(100, 200),
  starCount: 5,
  onComplete: () {},
)
```

### 2. کارت شیشه‌ای (`glass_card.dart`)

کارت‌های با افکت بلور و شیشه‌ای:

```dart
import 'package:amoozesh_fandoghi/shared/widgets/premium/glass_card.dart';

// کارت ساده
GlassCard(
  child: Text('محتوای کارت'),
  blur: 16,
  borderRadius: 24,
)

// کارت با افکت لمس
GlassCard(
  onTap: () => print('کارت لمس شد!'),
  child: YourContent(),
)

// کارت با گرادیان
GlassCard(
  gradient: LinearGradient(
    colors: [Colors.purple, Colors.blue],
  ),
  child: YourContent(),
)
```

### 3. دکمه درخشان (`glass_card.dart`)

دکمه‌های با افکت نور و درخشش:

```dart
GlowingButton(
  onPressed: () => print('دکمه لمس شد!'),
  glowColor: Color(0xFF6C5CE7),
  glowRadius: 20,
  gradient: LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
  ),
  child: Text('بازی کن! 🎮'),
)
```

### 4. حلقه پیشرفت (`glass_card.dart`)

نمایش پیشرفت با انیمیشن:

```dart
ProgressRing(
  progress: 0.75, // 75%
  size: 100,
  strokeWidth: 10,
  progressGradient: LinearGradient(
    colors: [Colors.purple, Colors.blue],
  ),
  child: Text('۷۵٪'),
)

// نمایش درصد
ProgressRing(
  progress: 0.5,
  showPercentage: true,
)
```

### 5. تزئینات موج‌دار (`glass_card.dart`)

موج‌های متحرک برای پس‌زمینه:

```dart
WaveDecoration(
  color: Color(0xFF6C5CE7),
  height: 60,
  isAnimated: true,
  waveCount: 3,
)
```

### 6. متن نئون (`glass_card.dart`)

متن با افکت درخشش نئون:

```dart
NeonText(
  text: 'آموزش فندقی',
  glowColor: Color(0xFF6C5CE7),
  glowRadius: 8,
  isAnimated: true,
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
  ),
)
```

### 7. کارت بازی سه‌بعدی (`premium_animations.dart`)

کارت‌های با افکت کج‌شدن سه‌بعدی:

```dart
GameCard3D(
  title: 'الفبا',
  subtitle: 'یادگیری حروف',
  emoji: '🔤',
  gradientStart: Color(0xFF6C5CE7),
  gradientEnd: Color(0xFFA29BFE),
  glowColor: Color(0xFF6C5CE7),
  onTap: () => print('کارت لمس شد!'),
  isLocked: false,
  progress: 0.5,
)
```

### 8. پوشش موفقیت (`premium_animations.dart`)

نمایش پیام موفقیت با انیمیشن:

```dart
SuccessOverlay(
  title: 'آفرین! 🎉',
  subtitle: 'تو برنده شدی!',
  emoji: '🏆',
  displayDuration: Duration(seconds: 3),
  onDismiss: () => print('پوشش بسته شد'),
)
```

### 9. اسکرولر افقی بازی‌ها (`premium_animations.dart`)

لیست افقی قابل اسکرول بازی‌ها:

```dart
HorizontalGameScroller(
  games: [
    GameCard3D(...),
    GameCard3D(...),
    GameCard3D(...),
  ],
  itemWidth: 160,
  itemHeight: 200,
  spacing: 16,
  onGameSelected: (index) => print('بازی $index انتخاب شد'),
)
```

### 10. چیدمان واکنش‌گرا (`responsive_grid.dart`)

گرید واکنش‌گرا:

```dart
ResponsiveGrid(
  children: yourWidgets,
  minCrossAxisCount: 2,
  maxCrossAxisCount: 4,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  childAspectRatio: 1,
)
```

ستون واکنش‌گرا:

```dart
ResponsiveColumn(
  children: yourWidgets,
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
)
```

ردیف واکنش‌گرا:

```dart
ResponsiveRow(
  children: yourWidgets,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
)
```

### 11. دروازه والدین پیشرفته (`premium_components.dart`)

سوال ریاضی برای ورود والدین:

```dart
AdvancedParentGate(
  difficulty: 1, // 1: جمع ساده، 2: جمع بزرگ، 3: ضرب
  onApproved: () => print('والدین تأیید شد'),
  onCancelled: () => print('انصراف داده شد'),
)
```

### 12. صندوق جایزه (`premium_components.dart`)

انیمیشن صندوق جایزه:

```dart
RewardChest(
  coins: 50,
  onOpened: () => print('صندوق باز شد!'),
)
```

### 13. نمودار راداری مهارت‌ها (`premium_components.dart`)

نمایش مهارت‌های کودک:

```dart
SkillRadarChart(
  skills: {
    'الفبا': 0.8,
    'اعداد': 0.6,
    'رنگ‌ها': 0.9,
    'حیوانات': 0.7,
  },
  size: 200,
)
```

### 14. سیستم طراحی پریمیوم (`premium_design_system.dart`)

متغیرهای طراحی یکپارچه:

```dart
import 'package:amoozesh_fandoghi/app/premium_design_system.dart';

// فاصله‌ها
PremiumSpacing.md
PremiumSpacing.cardRadius
PremiumSpacing.cardPadding

// سایزها
PremiumSizing.buttonHeightMd
PremiumSizing.avatarLg
PremiumSizing.touchTargetMin

// گرادیان‌های پس‌زمینه
BackgroundGradients.ocean
BackgroundGradients.sunset
BackgroundGradients.getByTimeOfDay() // بر اساس زمان روز

// رنگ‌ها
PremiumColors.success
PremiumColors.premium
PremiumColors.gold

// سایه‌ها
PremiumShadows.card(context)
PremiumShadows.glow(color)
PremiumShadows.soft()

// انیمیشن‌ها
PremiumAnimations.normal
PremiumAnimations.elasticOut
```

---

## 🚀 استفاده در صفحه اصلی

### به‌روزرسانی داشبورد با جشن خودکار

```dart
class _DashboardState extends ConsumerState<DashboardTab>
    with TickerProviderStateMixin {
  // ...
  bool _showCelebration = false;

  Future<void> _openGame(String route, String gameName) async {
    // ...
    Navigator.pushNamed(context, route).then((_) {
      if (mounted) {
        // جشن برد!
        setState(() => _showCelebration = true);
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) setState(() => _showCelebration = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConfettiOverlay(
        isActive: _showCelebration,
        child: YourContent(),
      ),
    );
  }
}
```

---

## 🎯 نکات بهینه‌سازی

1. **کش انیمیشن‌ها**: AnimationController ها را در dispose فراموش نکنید
2. **بهینه‌سازی ذرات**: تعداد ذرات را برای گوشی‌های ضعیف کاهش دهید
3. **Blur**: مقدار blur را زیاد نکنید (16-20 بهینه است)
4. **سایه‌ها**: از boxShadow با opacity کم استفاده کنید

---

## 📱 سازگاری

- ✅ اندروید ۵.۰ به بالا
- ✅ iOS ۱۲ به بالا
- ✅ گوشی‌های کوچک (۳۲۰dp)
- ✅ تبلت‌ها
- ✅ حالت تاریک/روشن
