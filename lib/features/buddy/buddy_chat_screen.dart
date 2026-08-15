import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/app_colors.dart';
import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/ai_system.dart';
import '../../core/audio_service.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/child_touch_target.dart';
import '../../shared/widgets/fandoghi_v2.dart';

/// ────────────────────────────────────────────────────────────
/// 💬 دوست من فندقی — دفترچه رازها و گفتگوی صوتی-حسی
///
/// ۶ حالت هیجانی صوتی سریع + گفتگوی آفلاین و هوش هیجانی
/// ────────────────────────────────────────────────────────────
class BuddyChatScreen extends StatefulWidget {
  const BuddyChatScreen({super.key});

  @override
  State<BuddyChatScreen> createState() => _BuddyChatScreenState();
}

class _BuddyChatScreenState extends State<BuddyChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];

  static const List<(_MoodChip)> _moods = [
    _MoodChip('🌟 خوشحالم', 'خیلی خوشحالم! امروز روز خوبی برام بود.', 'خیلی عالیه! خنده‌هات مثل خورشید می‌درخشه و من از خوشحالی تو شادم! 🌟', Color(0xFFFFD700)),
    _MoodChip('😴 خسته‌ام', 'امروز خیلی بازی کردم و خسته‌ام.', 'کمی استراحت کن دوست خوبم، یه لیوان آب خنک بخور و چشم‌هات رو ببند 😴', Color(0xFF636E72)),
    _MoodChip('😠 عصبانیم', 'خیلی عصبانی هستم!', 'می‌فهمم! گاهی چیزها اونطور که می‌خوایم نمیشه. بیا ۳ تا نفس عمیق بکشیم تا آروم بشیم 🧘', Color(0xFFFF6B6B)),
    _MoodChip('😢 ناراحتم', 'امروز دلم گرفته و ناراحتم.', 'من اینجام کنارت، غصه نخور. گریه کردن اشکالی نداره، بعدش با هم یه بازی قشنگ می‌کنیم 💧', Color(0xFF74B9FF)),
    _MoodChip('🌙 دلتنگم', 'دلم برای کسی تنگ شده.', 'دلتنگی نشونه اینه که چقدر قلبت مهربونه دوست من! می‌تونی یه نقاشی قشنگ براش بکشی 💌', Color(0xFFFF6B9E)),
    _MoodChip('😨 نگرانم', 'از یه چیزی نگرانم و می‌ترسم.', 'من کنارت هستم، شجاع باش! هر مشکلی یه راه حل داره دوست کوچولوی من 🌙', Color(0xFF6C5CE7)),
  ];

  @override
  void initState() {
    super.initState();
    final name = GameData.childName.isNotEmpty ? GameData.childName : 'دوست من';
    _messages.add(_ChatMessage(
      fromFandoghi: true,
      text: 'سلام $name! من فندقی‌ام 🌰 اینجا همیشه گوش می‌کنم؛ حال امروزت رو از گزینه‌های بالا انتخاب کن یا برام بنویس!',
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(AudioService.speak('سلام! من فندقی‌ام. حالت چطوره دوست من؟'));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectMood(_MoodChip mood) {
    HapticFeedback.selectionClick();
    setState(() {
      _messages.add(_ChatMessage(fromFandoghi: false, text: mood.childText));
      _messages.add(_ChatMessage(fromFandoghi: true, text: mood.reply));
    });
    _speakText(mood.reply);
    _scrollToBottom();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final reply = AI.buddyReply(text, childName: GameData.childName);
    setState(() {
      _messages.add(_ChatMessage(fromFandoghi: false, text: text));
      _messages.add(_ChatMessage(fromFandoghi: true, text: reply));
      _controller.clear();
    });
    _speakText(reply);
    _scrollToBottom();
  }

  void _speakText(String rawText) {
    final clean = rawText.replaceAll(RegExp(r'[«»🌰😊🎉😴🎮📖🤗🌙🔍👂🌟💧🧘💌]'), ' ');
    AudioService.speak(clean);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        title: Text(
          'دوست من فندقی 💬',
          style: AppFonts.vazirmatn(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        leading: ChildTouchTarget(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildMoodChipsRow(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messageBubble(_messages[index]),
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMoodChipsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Text(
              'حالت چطوره؟ روی یک حس بزن تا با فندقی حرف بزنی:',
              style: AppFonts.vazirmatn(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _moods.map((mood) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _selectMood(mood),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: mood.color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(color: mood.color.withOpacity(0.5)),
                      ),
                      child: Text(
                        mood.title,
                        style: AppFonts.vazirmatn(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'به فندقی چیزی بگو...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: _send,
              icon: const Icon(Icons.send_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(52, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageBubble(_ChatMessage message) {
    final isMine = !message.fromFandoghi;
    return Align(
      alignment: isMine ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 4 : 18),
            bottomRight: Radius.circular(isMine ? 18 : 4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.fromFandoghi) ...[
              const FandoghiV2(size: 28),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
            ),
            if (message.fromFandoghi) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _speakText(message.text);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up_rounded, size: 16, color: Colors.amberAccent),
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0),
    );
  }
}

class _ChatMessage {
  final bool fromFandoghi;
  final String text;

  const _ChatMessage({required this.fromFandoghi, required this.text});
}

class _MoodChip {
  final String title;
  final String childText;
  final String reply;
  final Color color;

  const _MoodChip(this.title, this.childText, this.reply, this.color);
}
