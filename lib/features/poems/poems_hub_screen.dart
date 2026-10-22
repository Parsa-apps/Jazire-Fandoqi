import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../core/audio_service.dart';
import '../../core/content_access_policy.dart';
import '../../core/learning_content/poems_data.dart';
import '../../core/monetization.dart';
import '../../shared/widgets/animated_gold_lock.dart';
import '../shop/full_version_paywall.dart';
import 'poem_reader_screen.dart';

/// 🎶 هاب شعرهای کودکانه — کارت‌های شاد با قفل نیمهٔ دوم (مثل لالایی‌کده).
class PoemsHubScreen extends StatefulWidget {
  const PoemsHubScreen({super.key});

  @override
  State<PoemsHubScreen> createState() => _PoemsHubScreenState();
}

class _PoemsHubScreenState extends State<PoemsHubScreen> {
  bool _hasFullVersion = false;

  @override
  void initState() {
    super.initState();
    Monetization.accessStatus.addListener(_onAccessChanged);
    _refreshEntitlement();
  }

  @override
  void dispose() {
    Monetization.accessStatus.removeListener(_onAccessChanged);
    super.dispose();
  }

  void _onAccessChanged() => _refreshEntitlement();

  Future<bool> _refreshEntitlement() async {
    final hasFullVersion = await Monetization.hasFullVersion();
    if (mounted && hasFullVersion != _hasFullVersion) {
      setState(() => _hasFullVersion = hasFullVersion);
    }
    return hasFullVersion;
  }

  bool _isLocked(Poem poem) =>
      !_hasFullVersion && !ContentAccessPolicy.isPoemFree(poem.id);

  Future<void> _openPoem(Poem poem) async {
    HapticFeedback.lightImpact();
    AudioService.poemChime();

    if (!ContentAccessPolicy.isPoemFree(poem.id) &&
        !await Monetization.hasFullVersion()) {
      if (!mounted) return;
      await showFullVersionPaywall(context, featureName: poem.title);
      if (!mounted || !await _refreshEntitlement()) return;
      if (!await Monetization.hasFullVersion()) return;
    }
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '/poem/${poem.id}'),
        builder: (_) => PoemReaderScreen(poem: poem),
      ),
    );
    if (mounted) setState(() {});
  }

  void _goBack() {
    HapticFeedback.selectionClick();
    AudioService.tap();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final poems = PoemsData.all;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF145C6B), Color(0xFF0B3B46), Color(0xFF06232B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(poems.length),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 188,
                  ),
                  itemCount: poems.length,
                  itemBuilder: (context, index) {
                    final poem = poems[index];
                    return _PoemCard(
                      poem: poem,
                      locked: _isLocked(poem),
                      onTap: () => _openPoem(poem),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎶 شعرهای کودکانه',
                  style: AppFonts.kids(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$count شعر شاد و ریتمیک — با خوانش صوتی',
                  style: AppFonts.vazirmatn(
                    color: const Color(0xFFB2EBF2),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PoemCard extends StatelessWidget {
  const _PoemCard({
    required this.poem,
    required this.locked,
    required this.onTap,
  });

  final Poem poem;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${poem.title} — ${poem.subtitle}',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: poem.gradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.75), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Text(poem.coverEmoji,
                            style: const TextStyle(fontSize: 34)),
                      ),
                      const Spacer(),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          poem.title,
                          style: AppFonts.kids(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        poem.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.headphones_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.85)),
                          const SizedBox(width: 4),
                          Text(
                            'شنیدنی',
                            style: AppFonts.vazirmatn(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (locked)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: ColoredBox(
                    color: Colors.black.withOpacity(0.42),
                    child: const Center(child: AnimatedGoldLock(size: 42)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
