import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../../data/datasources/hive_player_store.dart';

/// یک نقاشی ذخیره‌شدهٔ کودک — فقط داخل خودِ اپ، نه گالری گوشی.
class DrawingRecord {
  final String id;
  final String createdDay;
  final String fileName;

  const DrawingRecord({
    required this.id,
    required this.createdDay,
    required this.fileName,
  });

  Map<String, String> toJson() => {
        'id': id,
        'day': createdDay,
        'file': fileName,
      };

  static DrawingRecord? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id']?.toString() ?? '';
    final day = raw['day']?.toString() ?? '';
    final file = raw['file']?.toString() ?? '';
    if (id.isEmpty || file.isEmpty) return null;
    return DrawingRecord(id: id, createdDay: day, fileName: file);
  }
}

/// آلبوم آفلاین نقاشی. فایل‌ها در پوشهٔ خصوصی برنامه می‌مانند.
class DrawingAlbum {
  DrawingAlbum._();

  static const String _indexKey = 'drawing_album_v1';
  static const int maxDrawings = 24;

  static Directory? _overrideDir;
  static bool _memoryOnly = false;
  static final Map<String, Uint8List> _memoryPng = <String, Uint8List>{};
  static List<DrawingRecord> _cached = <DrawingRecord>[];
  static bool _loaded = false;

  static void useMemoryForTesting({bool clear = true}) {
    _memoryOnly = true;
    _overrideDir = null;
    if (clear) {
      _memoryPng.clear();
      _cached = <DrawingRecord>[];
      _loaded = true;
    }
  }

  static void useDirectoryForTesting(Directory dir) {
    _memoryOnly = false;
    _overrideDir = dir;
    _memoryPng.clear();
    _cached = <DrawingRecord>[];
    _loaded = false;
  }

  static Future<void> load() async {
    if (_loaded) return;
    final raw = await HivePlayerStore.readValue(_indexKey);
    _cached = _decodeIndex(raw);
    _loaded = true;
  }

  static List<DrawingRecord> get items => List<DrawingRecord>.unmodifiable(_cached);

  static Future<DrawingRecord?> savePng(Uint8List bytes, {String? today}) async {
    if (bytes.isEmpty) return null;
    await load();
    final now = DateTime.now();
    final day = today ??
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final id = 'd${now.millisecondsSinceEpoch}';
    final fileName = '$id.png';

    if (_memoryOnly) {
      _memoryPng[id] = Uint8List.fromList(bytes);
    } else {
      try {
        final dir = await _dir();
        await File('${dir.path}/$fileName').writeAsBytes(bytes, flush: true);
      } catch (_) {
        return null;
      }
    }

    final record = DrawingRecord(id: id, createdDay: day, fileName: fileName);
    _cached = [record, ..._cached];
    while (_cached.length > maxDrawings) {
      final dropped = _cached.removeLast();
      await _deleteFile(dropped);
    }
    await _persistIndex();
    return record;
  }

  static Future<Uint8List?> loadBytes(String id) async {
    await load();
    if (_memoryOnly) return _memoryPng[id];
    DrawingRecord? record;
    for (final item in _cached) {
      if (item.id == id) record = item;
    }
    if (record == null) return null;
    try {
      final dir = await _dir();
      final file = File('${dir.path}/${record.fileName}');
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  static Future<void> delete(String id) async {
    await load();
    DrawingRecord? found;
    for (final item in _cached) {
      if (item.id == id) found = item;
    }
    if (found == null) return;
    _cached = _cached.where((item) => item.id != id).toList();
    await _deleteFile(found);
    await _persistIndex();
  }

  static Future<void> clearAll() async {
    await load();
    for (final item in List<DrawingRecord>.from(_cached)) {
      await _deleteFile(item);
    }
    _cached = <DrawingRecord>[];
    _memoryPng.clear();
    await _persistIndex();
  }

  static List<DrawingRecord> _decodeIndex(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return <DrawingRecord>[];
      }
    }
    if (raw is! List) return <DrawingRecord>[];
    return raw.map(DrawingRecord.fromJson).whereType<DrawingRecord>().toList();
  }

  static Future<void> _persistIndex() async {
    final encoded = jsonEncode(_cached.map((e) => e.toJson()).toList());
    await HivePlayerStore.writeValue(_indexKey, encoded);
  }

  static Future<void> _deleteFile(DrawingRecord record) async {
    _memoryPng.remove(record.id);
    if (_memoryOnly) return;
    try {
      final dir = await _dir();
      final file = File('${dir.path}/${record.fileName}');
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static Future<Directory> _dir() async {
    if (_overrideDir != null) {
      return _overrideDir!.create(recursive: true);
    }
    final root = await getApplicationDocumentsDirectory();
    return Directory('${root.path}/drawings').create(recursive: true);
  }
}
