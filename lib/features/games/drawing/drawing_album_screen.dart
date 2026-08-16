import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../app/app_fonts.dart';
import '../../../core/drawing/drawing_album.dart';
import '../../../core/growth/persian_digits.dart';
import '../../../shared/widgets/child_touch_target.dart';

/// آلبوم نقاشی‌های ذخیره‌شده روی خود دستگاه — بدون گالری گوشی.
class DrawingAlbumScreen extends StatefulWidget {
  const DrawingAlbumScreen({super.key});

  @override
  State<DrawingAlbumScreen> createState() => _DrawingAlbumScreenState();
}

class _DrawingAlbumScreenState extends State<DrawingAlbumScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    DrawingAlbum.load().then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _open(DrawingRecord record) async {
    final bytes = await DrawingAlbum.loadBytes(record.id);
    if (!mounted || bytes == null) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Text(
              'روز ${PersianDigits.toFa(record.createdDay)}',
              style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await DrawingAlbum.delete(record.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) setState(() {});
            },
            child: const Text('پاک کردن'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = DrawingAlbum.items;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E7),
        title: Text(
          'آلبوم نقاشی من',
          style: AppFonts.vazirmatn(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? Center(
                    child: Text(
                      'هنوز نقاشی ذخیره‌شده‌ای نداری.\nدر کارگاه نقاشی بکش و «ذخیره کن» را بزن.',
                      textAlign: TextAlign.center,
                      style: AppFonts.vazirmatn(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ChildTouchTarget(
                        onTap: () => _open(item),
                        child: _Thumb(record: item),
                      );
                    },
                  ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final DrawingRecord record;
  const _Thumb({required this.record});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: DrawingAlbum.loadBytes(record.id),
      builder: (context, snap) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFCC80), width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: snap.data == null
              ? const Center(child: Text('🎨', style: TextStyle(fontSize: 32)))
              : Image.memory(snap.data!, fit: BoxFit.cover),
        );
      },
    );
  }
}
