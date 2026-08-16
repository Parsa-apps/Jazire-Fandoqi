import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release configuration has no gallery or media access capability', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final profileEditor =
        File('lib/features/profile/profile_editor.dart').readAsStringSync();

    expect(manifest, isNot(contains('READ_EXTERNAL_STORAGE')));
    expect(manifest, isNot(contains('WRITE_EXTERNAL_STORAGE')));
    expect(manifest, isNot(contains('READ_MEDIA_IMAGES')));
    expect(manifest, isNot(contains('READ_MEDIA_VISUAL_USER_SELECTED')));
    expect(manifest, isNot(contains('UCropActivity')));
    expect(pubspec, isNot(contains('image_picker:')));
    expect(pubspec, isNot(contains('image_cropper:')));
    expect(profileEditor, isNot(contains('ImagePicker')));
    expect(profileEditor, isNot(contains('ImageCropper')));

    final album =
        File('lib/core/drawing/drawing_album.dart').readAsStringSync();
    expect(album, contains('getApplicationDocumentsDirectory'));
    expect(album, isNot(contains('getExternalStorageDirectory')));
    expect(album, isNot(contains('Gal.putImage')));
  });

  test('all 20 bundled avatars exist', () {
    for (var index = 0; index < 20; index++) {
      final avatar = File('assets/avatars/avatar_$index.webp');
      expect(avatar.existsSync(), isTrue, reason: avatar.path);
      expect(avatar.lengthSync(), greaterThan(1024), reason: avatar.path);
    }
  });
}
