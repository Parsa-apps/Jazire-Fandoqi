import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amoozesh_fandoghi/core/fandoghi_coach.dart';
import 'package:amoozesh_fandoghi/features/gateway/learning_library_screen.dart';

void main() {
  tearDown(() {
    FandoghiCoach.clear();
    FandoghiCoach.disablePersistentPresence();
  });

  testWidgets('PR80 learning hubs are discoverable from one library',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LearningLibraryScreen()),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('کتابخانه یادگیری 📚'), findsOneWidget);
    expect(find.text('دانشنامه حیوانات ایران'), findsOneWidget);
    expect(find.text('دنیای اعداد'), findsOneWidget);
    expect(find.text('شغل‌های قهرمانانه'), findsOneWidget);
    expect(find.text('مفاهیم اولیه'), findsOneWidget);
    expect(find.text('دنیای احساسات'), findsOneWidget);
  });
}
