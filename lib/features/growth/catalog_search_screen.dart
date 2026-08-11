import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_fonts.dart';
import '../../app/design_tokens.dart';
import '../../core/audio_service.dart';
import '../../core/growth/growth.dart';

class CatalogSearchScreen extends StatefulWidget {
  const CatalogSearchScreen({super.key});

  @override
  State<CatalogSearchScreen> createState() => _CatalogSearchScreenState();
}

class _CatalogSearchScreenState extends State<CatalogSearchScreen> {
  final _controller = TextEditingController();
  List<CatalogItem> _results = CatalogSearch.query('');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String value) {
    setState(() => _results = CatalogSearch.query(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جستجو در جزیره')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onQuery,
              decoration: InputDecoration(
                hintText: 'بازی، قصه، کارتون یا مهارت…',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.lg), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('چیزی پیدا نشد — یک کلمه دیگر امتحان کن'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = _results[i];
                      return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        tileColor: Theme.of(context).colorScheme.surface,
                        leading: Text(item.emoji, style: const TextStyle(fontSize: 26)),
                        title: Text(item.title, style: AppFonts.vazirmatn(fontWeight: FontWeight.w800)),
                        subtitle: Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text(item.category, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          AudioService.tap();
                          Navigator.pushNamed(context, item.route);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
