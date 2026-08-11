import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
import '../../core/growth/growth.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final words = VocabularyJournal.words;
    return Scaffold(
      appBar: AppBar(title: const Text('واژه‌نامه طلایی')),
      body: words.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'هنوز واژه‌ای ذخیره نشده. در قصه‌ها و مهارت زندگی، کلمه‌های طلایی اینجا جمع می‌شوند ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.7),
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: words.length,
              itemBuilder: (context, i) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFFCC80)),
                  ),
                  child: Text(
                    words[i],
                    textAlign: TextAlign.center,
                    style: AppFonts.vazirmatn(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                );
              },
            ),
    );
  }
}
