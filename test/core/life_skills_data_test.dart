import 'package:flutter_test/flutter_test.dart';

import 'package:jazireh_fandoghi/core/growth/life_skills_data.dart';

void main() {
  test('ten life-skill worlds exist with unique ids', () {
    expect(LifeSkillsData.topics.length, 10);
    final ids = LifeSkillsData.topics.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every topic has 8 valid questions', () {
    for (final topic in LifeSkillsData.topics) {
      expect(topic.questions.length, 8, reason: '${topic.id} should have 8 questions');
      final seen = <String>{};
      for (final q in topic.questions) {
        expect(q.options.length, 4, reason: '${topic.id}/${q.id} needs 4 options');
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: '${topic.id}/${q.id}');
        expect(q.options[q.correctIndex].trim(), isNotEmpty, reason: '${topic.id}/${q.id}');
        expect(q.prompt.trim(), isNotEmpty);
        expect(q.fact.trim(), isNotEmpty);
        expect(seen.add(q.id), isTrue, reason: 'duplicate question id ${q.id}');
      }
    }
  });

  test('byId resolves topics and returns null for unknown', () {
    expect(LifeSkillsData.byId('traffic')?.title, 'ایمنی خیابان');
    expect(LifeSkillsData.byId('does-not-exist'), isNull);
  });

  test('topics map to known GameData skills', () {
    const knownSkills = {
      'math', 'alphabet', 'memory', 'colors', 'shapes', 'animals',
      'counting', 'pattern', 'fruits', 'concepts', 'vocab', 'body',
      'vehicles', 'time', 'weather', 'emotions', 'jobs', 'stories',
      'lullaby',
    };
    for (final topic in LifeSkillsData.topics) {
      expect(knownSkills.contains(topic.skill), isTrue, reason: '${topic.id} uses unknown skill ${topic.skill}');
    }
  });
}
