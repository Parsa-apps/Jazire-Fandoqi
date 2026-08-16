import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/growth/parent_insights.dart';

void main() {
  group('ParentInsights', () {
    test('weeklyGoalRatio در بازه‌ی ۰..۱ می‌ماند', () {
      expect(ParentInsights.weeklyGoalRatio, inInclusiveRange(0.0, 1.0));
    });

    test('dailyBudgetRatio هرگز از ۱ بیشتر نمی‌شود', () {
      expect(ParentInsights.dailyBudgetRatio, inInclusiveRange(0.0, 1.0));
    });

    test('radarSkills دقیقاً ۸ مهارت برمی‌گرداند', () {
      final skills = ParentInsights.radarSkills();
      expect(skills.length, 8);
      for (final v in skills.values) {
        expect(v, inInclusiveRange(0, 100));
      }
    });

    test('alerts خالی نیست و همیشه حداقل یک اعلان دارد', () {
      expect(ParentInsights.alerts(), isNotEmpty);
    });

    test('teacherTips حداقل یک توصیه‌ی آفلاین دارد', () {
      final tips = ParentInsights.teacherTips();
      expect(tips, isNotEmpty);
      expect(tips.any((t) => t.emoji == '🤸'), isTrue);
    });

    test('strongestSkills و focusSkills حداکثر ۳ مورد برمی‌گردانند', () {
      expect(ParentInsights.strongestSkills().length, lessThanOrEqualTo(3));
      expect(ParentInsights.focusSkills().length, lessThanOrEqualTo(3));
    });

    test('trend دقیقاً ۷ روز است', () {
      expect(ParentInsights.trend().length, 7);
    });

    test('balanceLabel متنی غیر خالی است', () {
      expect(ParentInsights.balanceLabel, isNotEmpty);
    });
  });
}
