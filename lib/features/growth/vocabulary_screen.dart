import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_fonts.dart';
import '../../core/content_access_policy.dart';
import '../../core/growth/growth.dart';
import '../../core/monetization.dart';
import '../shop/content_lock.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  /// نیمهٔ اولِ واژه‌ها (به ترتیبِ ثبت در دفترچه) رایگان است و نیمهٔ دوم
  /// فقط با نسخهٔ کامل. پیش‌فرض «خرید ندارد» (fail-closed): تا وقتی پاسخِ
  /// فروشگاه نرسیده، نیمهٔ پولی قفل می‌ماند.
  bool _hasFullVersion = false;

  @override
  void dispose() {
    Monetization.accessStatus.removeListener(_syncFullVersionAccess);
    super.dispose();
  }

  void _syncFullVersionAccess() {
    if (!mounted) return;
    final has = Monetization.accessStatus.value.isVerified;
    if (has != _hasFullVersion) setState(() => _hasFullVersion = has);
  }

  @override
  void initState() {
    super.initState();
    Monetization.accessStatus.addListener(_syncFullVersionAccess);
    _refreshEntitlement();
  }

  Future<void> _refreshEntitlement() async {
    final hasFullVersion = await Monetization.hasFullVersion();
    if (mounted && hasFullVersion != _hasFullVersion) {
      setState(() => _hasFullVersion = hasFullVersion);
    }
  }

  bool _isFree(String word, List<String> words) =>
      ContentAccessPolicy.isFreeHalfItem(word, words);

  bool _isLocked(String word, List<String> words) =>
      !_hasFullVersion && !_isFree(word, words);

  Future<void> _openWord(String word, List<String> words) async {
    final allowed = await ensureContentAccess(
      context,
      featureName: 'واژهٔ $word',
      isFree: _isFree(word, words),
    );
    if (!allowed) return;
    if (!mounted) return;
    unawaited(_refreshEntitlement());
  }

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
                final word = words[i];
                final locked = _isLocked(word, words);
                return GestureDetector(
                  onTap: () => _openWord(word, words),
                  child: LockedCardOverlay(
                    locked: locked,
                    badgeSize: 24,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFFCC80)),
                      ),
                      child: Text(
                        locked ? '🔒' : word,
                        textAlign: TextAlign.center,
                        style: AppFonts.vazirmatn(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
