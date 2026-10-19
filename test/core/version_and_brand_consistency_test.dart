import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jazireh_fandoghi/core/growth/growth_store.dart';
import 'package:jazireh_fandoghi/core/growth/persian_digits.dart';
import 'package:jazireh_fandoghi/core/growth/whats_new.dart';

/// 🏷️ نسخه و نام اپ باید همه‌جا یکی باشند.
///
/// منبع حقیقت نسخه `pubspec.yaml` است. این تست جلوی جاماندن نسخهٔ قدیمی در
/// ثابت‌های اپ، صفحهٔ «تازه‌ها»، نام ورک‌فلوی ساخت و نام آرتیفکت‌ها را می‌گیرد
/// و مطمئن می‌شود نام قدیمی اپ به هیچ فایل متنی مخزن برنمی‌گردد — نام درست
/// همه‌جا «جزیره فندقی» است.
///
/// هنگام ارتقای نسخه این‌ها را با هم عوض کنید: `pubspec.yaml`،
/// `GrowthStore.appVersion`، `WhatsNew` و نام ورک‌فلو در تب Actions
/// (`.github/workflows/build-apk.yml`). نام آرتیفکت‌ها و تگ ریلیز نیازی به
/// ویرایش ندارند: مرحلهٔ `version` ورک‌فلو آن‌ها را از `pubspec.yaml`
/// می‌سازد.
void main() {
  test('app version constants match pubspec.yaml', () {
    final version = _PubspecVersion.read();

    expect(GrowthStore.appVersion, version.full,
        reason: 'GrowthStore.appVersion باید با pubspec.yaml یکی باشد');
    expect(WhatsNew.version, PersianDigits.toFa(version.full),
        reason: 'نسخهٔ صفحهٔ «تازه‌ها» باید با pubspec.yaml یکی باشد');
    expect(WhatsNew.buildNumber, '+${PersianDigits.toFa(version.build)}',
        reason: 'شمارهٔ بیلد صفحهٔ «تازه‌ها» باید با pubspec.yaml یکی باشد');
  });

  test('the GitHub build workflow shows the app name and current version', () {
    final version = _PubspecVersion.read();
    final workflow =
        File('.github/workflows/build-apk.yml').readAsStringSync();

    final workflowName = RegExp(
      '^name: Build APK & AAB - جزیره فندقی '
      'v${RegExp.escape(version.short)}\\s*\$',
      multiLine: true,
    );
    expect(workflowName.hasMatch(workflow), isTrue,
        reason: 'نام ورک‌فلو در تب Actions باید «جزیره فندقی '
            'v${version.short}» باشد');

    // نسخه در ورک‌فلو ثابت نیست: مرحلهٔ `version` آن را از pubspec.yaml
    // می‌خواند و نام آرتیفکت‌ها و تگ انتشار از خروجیٔ همان مرحله ساخته
    // می‌شوند، پس ارتقای نسخه دیگر چیزی را جا نمی‌گذارد.
    expect(workflow.contains('id: version'), isTrue,
        reason: 'ورک‌فلو باید مرحله‌ای با id: version داشته باشد که نسخه را '
            'از pubspec.yaml بخواند');
    expect(RegExp(r'version:.*pubspec\.yaml').hasMatch(workflow), isTrue,
        reason: 'نسخهٔ انتشار باید از pubspec.yaml خوانده شود، نه عدد ثابت');

    for (final flavor in const ['apk', 'aab']) {
      expect(
        workflow.contains('name: jazire_fandoqi_v'
            r'${{ steps.version.outputs.name }}'
            '_myket_production_$flavor'),
        isTrue,
        reason: 'نام آرتیفکت $flavor باید از خروجیِ مرحلهٔ version '
            'ساخته شود',
      );
    }

    final staleVersions = RegExp(r'jazire_fandoqi_v\d+\.\d+\.\d+_')
        .allMatches(workflow)
        .map((m) => m.group(0))
        .toList();
    expect(staleVersions, isEmpty,
        reason: 'نسخهٔ آرتیفکت‌ها باید از pubspec گرفته شود؛ نام ثابت با '
            'اولین ارتقای نسخه کهنه می‌شود');
    expect(workflow.contains('v${version.full}'), isFalse,
        reason: 'نسخهٔ انتشار (تگ ریلیز) نباید در ورک‌فلو ثابت نوشته شود');
    expect(workflow.contains('kudake_iran_v'), isFalse,
        reason: 'نام قدیمی آرتیفکت‌ها نباید برگردد');
  });

  test('no user-visible string hard-codes an app version number', () {
    // متنی مثل «نسخه ۶.۲» با اولین آپدیت کهنه می‌شود؛ نسخه باید از
    // GrowthStore.appVersion یا WhatsNew خوانده شود. کامنت‌ها آزادند.
    final hardCodedVersion = RegExp(
      'نسخه[\u0654\u200c]?\u06CC?\\s*[0-9\u06F0-\u06F9\u0660-\u0669]',
    );
    final offenders = <String>[];

    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in dartFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trimLeft();
        if (trimmed.startsWith('//') ||
            trimmed.startsWith('*') ||
            trimmed.startsWith('/*')) {
          continue;
        }
        if (!line.contains("'") && !line.contains('"')) continue;
        if (hardCodedVersion.hasMatch(line)) {
          offenders.add('${file.path}:${i + 1} → ${trimmed.trim()}');
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'نسخهٔ ثابت در متن قابل‌نمایش:\n${offenders.join('\n')}');
  });

  test('the old app name never comes back to any text file', () {
    // الگو بدون نوشتن خودِ نام قدیمی ساخته شده تا این فایل خودش را نگیرد؛
    // گونه‌های با فاصلهٔ مجازی و حروف عربی (ك) را هم پوشش می‌دهد.
    final oldAppName = RegExp('[کك]ود[کك]' r'[\s\u200c]*' 'دانا');
    final offenders = <String>[];

    for (final file in _repoTextFiles(Directory('.'))) {
      final text = utf8.decode(file.readAsBytesSync(), allowMalformed: true);
      final lines = const LineSplitter().convert(text);
      for (var i = 0; i < lines.length; i++) {
        if (oldAppName.hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'نام قدیمی اپ باید با «جزیره فندقی» جایگزین شود:\n'
            '${offenders.join('\n')}');
  });
}

class _PubspecVersion {
  const _PubspecVersion(this.major, this.minor, this.patch, this.build);

  final String major;
  final String minor;
  final String patch;
  final String build;

  /// مثل `7.1.0`
  String get full => '$major.$minor.$patch';

  /// مثل `7.1` — همان نسخه‌ای که در نام ورک‌فلو دیده می‌شود.
  String get short => '$major.$minor';

  static _PubspecVersion read() {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);
    if (match == null) {
      throw StateError('pubspec.yaml باید `version: X.Y.Z+N` داشته باشد');
    }
    return _PubspecVersion(
      match.group(1)!,
      match.group(2)!,
      match.group(3)!,
      match.group(4)!,
    );
  }
}

const _textExtensions = {
  '.dart',
  '.md',
  '.yml',
  '.yaml',
  '.txt',
  '.sh',
  '.py',
  '.kt',
  '.gradle',
  '.xml',
  '.json',
  '.html',
  '.properties',
};

/// خروجی‌های ساخت و کش‌ها جزو محتوای مخزن نیستند و بزرگ‌اند.
const _skippedDirectories = {
  '.git',
  '.dart_tool',
  '.gradle',
  '.idea',
  '.cxx',
  'build',
  'node_modules',
  'Pods',
  'qa-gate-log',
};

Iterable<File> _repoTextFiles(Directory directory) sync* {
  for (final entity in directory.listSync(followLinks: false)) {
    final name = entity.path.split(RegExp(r'[/\\]')).last;
    if (entity is Directory) {
      if (!_skippedDirectories.contains(name)) {
        yield* _repoTextFiles(entity);
      }
    } else if (entity is File) {
      final dot = name.lastIndexOf('.');
      if (dot > 0 &&
          _textExtensions.contains(name.substring(dot).toLowerCase())) {
        yield entity;
      }
    }
  }
}
