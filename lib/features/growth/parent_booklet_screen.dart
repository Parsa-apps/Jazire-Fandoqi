import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/app_legal.dart';

class ParentBookletScreen extends StatelessWidget {
  const ParentBookletScreen({super.key});

  static const _tips = <(String, String)>[
    ('۱۰ دقیقه طلایی', 'روزی ده دقیقه یادگیری متمرکز بهتر از یک ساعت پراکنده است. فندقی همان ده دقیقه را هدف می‌گیرد.'),
    ('قانون خواب', 'یک ساعت ثابت برای خواب انتخاب کنید. اپ بعد از آن فقط لالایی پخش می‌کند.'),
    ('نه به مقایسه', 'هر کودک ریتم خودش را دارد. گزارش هفتگی برای فهمیدن است، نه مسابقه با بچه همسایه.'),
    ('یادگیری با بدن', 'بعد از بازی صفحه، یک حرکت واقعی: شستن دست، چیدن میوه، رد شدن از خط عابر با شما.'),
    ('قصه قبل خواب', 'یک داستان کوتاه و لالایی، مغز را از حالت هیجان به آرامش می‌برد.'),
    ('بدون شرمساری', 'اگر جواب غلط بود فندقی سرزنش نمی‌کند. شما هم همان لحن را در خانه ادامه دهید.'),
    ('چند فرزند', 'روی یک گوشی تا سه پروفایل بسازید تا پیشرفت‌ها قاطی نشود.'),
    ('اعتماد شما', 'هیچ داده کودکی به اینترنت نمی‌رود. اگر سوالی بود: ${AppLegal.telegramHandle}'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کتابچه کوتاه والدین')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _tips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final tip = _tips[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i + 1}. ${tip.$1}', style: AppFonts.vazirmatn(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 6),
                Text(tip.$2, style: const TextStyle(height: 1.6)),
              ],
            ),
          );
        },
      ),
    );
  }
}
