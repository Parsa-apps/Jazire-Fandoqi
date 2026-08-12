import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/game_data.dart';

Future<void> showProfileEditor(BuildContext context) async {
  final name = TextEditingController(text: GameData.childName);
  String? photo =
      GameData.profilePhotoPath.isEmpty ? null : GameData.profilePhotoPath;
  String selectedAvatar = GameData.avatar;

  Future<void> pickPhoto(StateSetter setState) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 92,
      );
      if (image == null) return;

      String selectedPath = image.path;

      // برش تصویر با مدیریت خطا و fallback امن
      try {
        final cropped = await ImageCropper().cropImage(
          sourcePath: image.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 90,
          maxWidth: 800,
          maxHeight: 800,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'برش عکس پروفایل',
              toolbarColor: const Color(0xFF6C43D9),
              toolbarWidgetColor: Colors.white,
              activeControlsWidgetColor: const Color(0xFF6C43D9),
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              cropStyle: CropStyle.circle,
            ),
            IOSUiSettings(
              title: 'برش عکس پروفایل',
              cropStyle: CropStyle.circle,
              aspectRatioLockEnabled: true,
            ),
          ],
        );
        if (cropped != null) {
          selectedPath = cropped.path;
        }
      } catch (cropError) {
        debugPrint('Crop error (fallback to picked image): $cropError');
      }

      final file = File(selectedPath);
      if (!await file.exists()) return;

      final docs = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${docs.path}/profile');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destination =
          File('${profileDir.path}/profile_photo_$timestamp.jpg');
      final saved = await file.copy(destination.path);

      // پاک کردن عکس‌های قبلی پروفایل
      try {
        final entries = profileDir.listSync();
        for (final entry in entries) {
          if (entry is File && entry.path != saved.path) {
            try {
              entry.deleteSync();
            } catch (_) {}
          }
        }
      } catch (_) {}

      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      if (context.mounted) {
        setState(() {
          photo = saved.path;
        });
      }
    } catch (e) {
      debugPrint('Profile photo pick error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در انتخاب عکس؛ لطفاً دوباره تلاش کنید.'),
          ),
        );
      }
    }
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 28,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'ویرایش پروفایل',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => pickPhoto(setState),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF6C43D9),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C43D9).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: photo != null && File(photo!).existsSync()
                            ? Image.file(
                                File(photo!),
                                fit: BoxFit.cover,
                                width: 92,
                                height: 92,
                              )
                            : selectedAvatar.startsWith('assets/')
                                ? Image.asset(
                                    selectedAvatar,
                                    fit: BoxFit.cover,
                                    width: 92,
                                    height: 92,
                                  )
                                : Center(
                                    child: Text(
                                      selectedAvatar,
                                      style: const TextStyle(fontSize: 42),
                                    ),
                                  ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C43D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'برای انتخاب یا تغییر عکس ضربه بزنید',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'یا یک آواتار آماده انتخاب کن',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(6, (index) {
                  final asset = 'assets/avatars/avatar_$index.webp';
                  final active = selectedAvatar == asset && photo == null;
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedAvatar = asset;
                      photo = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 54,
                      height: 54,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active
                              ? const Color(0xFF6C43D9)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(asset, fit: BoxFit.cover),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: name,
                maxLength: 24,
                decoration: const InputDecoration(
                  labelText: 'نام کودک',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    GameData.updateProfile(
                      name: name.text,
                      photoPath: photo ?? '',
                      avatarIcon: selectedAvatar,
                    );
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('ذخیره تغییرات'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  name.dispose();
}
