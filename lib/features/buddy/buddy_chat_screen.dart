import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../core/ai_system.dart';
import '../../core/audio_service.dart';
import '../../core/game_data.dart';
import '../../shared/widgets/fandoghi_v2.dart';

/// ────────────────────────────────────────────────────────────
/// 💬 فاز ۴۸: دوست خیالی فندقی — گفتگوی آفلاین قانون‌محور
///
/// نه ChatGPT، نه اینترنت: فقط ۱۰+ پاسخ مهربانانه بر اساس کلمه‌های
/// کلیدی. کودک می‌تواند با فندقی حرف بزند و همدلی یاد بگیرد.
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

  @override
  void initState() {
    super.initState();
    final name = GameData.childName.isNotEmpty ? GameData.childName : 'دوست من';
    _messages.add(_ChatMessage(
      fromFandoghi: true,
      text: 'سلام $name! من فندقی‌ام 🌰 اینجا همیشه گوش می‌کنم؛ هر چی دوست داری بنویس!',
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(fromFandoghi: false, text: text));
      _messages.add(_ChatMessage(
        fromFandoghi: true,
        text: AI.buddyReply(text, childName: GameData.childName),
      ));
      _controller.clear();
    });
    // فندقی با صدای خودش پاسخ کوتاه می‌دهد (TTS)
    final reply = AI.buddyReply(text, childName: GameData.childName);
    AudioService.speak(reply.replaceAll(RegExp(r'[«»🌰😊🎉😴🎮📖🤗🌙🔍👂]'), ' '));
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
        title: const Text('دوست من فندقی 💬'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _messageBubble(_messages[index]),
            ),
          ),
          SafeArea(
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
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(_ChatMessage message) {
    final isMine = !message.fromFandoghi;
    return Align(
      alignment: isMine ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primary.withOpacity(0.25)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 6 : 18),
            bottomRight: Radius.circular(isMine ? 18 : 6),
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
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool fromFandoghi;
  final String text;

  const _ChatMessage({required this.fromFandoghi, required this.text});
}
