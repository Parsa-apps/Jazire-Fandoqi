import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/game_data.dart';
import '../../core/logger_service.dart';

const int _maxProfilePhotoBytes = 20 * 1024 * 1024;

/// Opens the profile editor and keeps gallery selection transactional:
/// a newly selected file replaces the old photo only after the user saves.
Future<void> showProfileEditor(BuildContext context) async {
  final name = TextEditingController(text: GameData.childName);
  final initialPhotoPath = GameData.profilePhotoPath;
  String? photo = initialPhotoPath.isEmpty ? null : initialPhotoPath;
  String? stagedPhotoPath;
  String? committedPhotoPath;
  String selectedAvatar = GameData.avatar;
  bool isPickingPhoto = false;

  Future<void> pickPhoto(
    BuildContext sheetContext,
    StateSetter setSheetState,
  ) async {
    if (isPickingPhoto) return;
    setSheetState(() => isPickingPhoto = true);

    try {
      final picker = ImagePicker();
      final image = await _recoverOrPickPhoto(picker);
      if (image == null) return;

      final savedPath = await _persistProfilePhoto(image);
      if (!sheetContext.mounted) {
        await _deleteFile(savedPath);
        return;
      }

      final previousStagedPath = stagedPhotoPath;
      setSheetState(() {
        stagedPhotoPath = savedPath;
        photo = savedPath;
      });

      if (previousStagedPath != null && previousStagedPath != savedPath) {
        await _deleteFile(previousStagedPath);
      }
    } on PlatformException catch (error, stackTrace) {
      LoggerService.e('Profile gallery selection failed', error, stackTrace);
      if (sheetContext.mounted) {
        _showPhotoError(sheetContext, _messageForPlatformError(error));
      }
    } on _ProfilePhotoException catch (error, stackTrace) {
      LoggerService.e('Invalid profile photo rejected', error, stackTrace);
      if (sheetContext.mounted) {
        _showPhotoError(sheetContext, error.message);
      }
    } catch (error, stackTrace) {
      LoggerService.e('Profile photo processing failed', error, stackTrace);
      if (sheetContext.mounted) {
        _showPhotoError(
          sheetContext,
          'عکس انتخاب‌شده قابل استفاده نیست؛ لطفاً عکس دیگری انتخاب کنید.',
        );
      }
    } finally {
      if (sheetContext.mounted) {
        setSheetState(() => isPickingPhoto = false);
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
                onTap: isPickingPhoto
                    ? null
                    : () => pickPhoto(context, setState),
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
                        child: _ProfileAvatarPreview(
                          photoPath: photo,
                          selectedAvatar: selectedAvatar,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C43D9),
                        shape: BoxShape.circle,
                      ),
                      child: isPickingPhoto
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: isPickingPhoto
                    ? null
                    : () => pickPhoto(context, setState),
                icon: isPickingPhoto
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined, size: 20),
                label: Text(
                  isPickingPhoto ? 'در حال آماده‌سازی عکس…' : 'انتخاب از گالری',
                ),
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
                    onTap: isPickingPhoto
                        ? null
                        : () => setState(() {
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
                  onPressed: isPickingPhoto
                      ? null
                      : () {
                          committedPhotoPath = photo ?? '';
                          GameData.updateProfile(
                            name: name.text,
                            photoPath: committedPhotoPath,
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

  // A dismissed sheet must not delete the user's current photo. Conversely,
  // selecting an avatar or saving a new image should remove obsolete files.
  try {
    if (committedPhotoPath == null) {
      if (stagedPhotoPath != null) await _deleteFile(stagedPhotoPath!);
      return;
    }

    if (stagedPhotoPath != null && stagedPhotoPath != committedPhotoPath) {
      await _deleteFile(stagedPhotoPath!);
    }
    if (initialPhotoPath.isNotEmpty &&
        initialPhotoPath != committedPhotoPath) {
      await _deleteOwnedProfilePhoto(initialPhotoPath);
    }
  } catch (error, stackTrace) {
    LoggerService.e('Profile photo cleanup failed', error, stackTrace);
  }
}

/// Android can destroy MainActivity while the system gallery is open. The
/// official picker stores that result, so consume it before starting a new
/// request. This turns a perceived restart/close into a recoverable selection.
Future<XFile?> _recoverOrPickPhoto(ImagePicker picker) async {
  final lostData = await picker.retrieveLostData();
  if (!lostData.isEmpty) {
    final recoveredFiles = lostData.files;
    if (recoveredFiles != null && recoveredFiles.isNotEmpty) {
      return recoveredFiles.first;
    }
    if (lostData.exception != null) throw lostData.exception!;
  }

  return picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1200,
    maxHeight: 1200,
    imageQuality: 88,
    requestFullMetadata: false,
  );
}

Future<String> _persistProfilePhoto(XFile image) async {
  final source = File(image.path);
  if (!await source.exists()) {
    throw const _ProfilePhotoException('فایل عکس انتخاب‌شده پیدا نشد.');
  }

  final sourceSize = await source.length();
  if (sourceSize <= 0) {
    throw const _ProfilePhotoException('فایل عکس انتخاب‌شده خالی است.');
  }
  if (sourceSize > _maxProfilePhotoBytes) {
    throw const _ProfilePhotoException(
      'حجم عکس خیلی زیاد است؛ لطفاً عکس کوچک‌تری انتخاب کنید.',
    );
  }

  final profileDirectory = await _getProfileDirectory();
  final id = DateTime.now().microsecondsSinceEpoch;
  final temporary = File('${profileDirectory.path}/.profile_photo_$id.tmp');
  final destination = File('${profileDirectory.path}/profile_photo_$id.img');

  try {
    await source.copy(temporary.path);
    if (!await temporary.exists() || await temporary.length() <= 0) {
      throw const _ProfilePhotoException('ذخیره عکس کامل نشد؛ دوباره تلاش کنید.');
    }
    final saved = await temporary.rename(destination.path);
    return saved.path;
  } catch (_) {
    await _deleteFile(temporary.path);
    rethrow;
  }
}

Future<Directory> _getProfileDirectory() async {
  final documents = await getApplicationDocumentsDirectory();
  final directory = Directory('${documents.path}/profile');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return directory;
}

Future<void> _deleteOwnedProfilePhoto(String path) async {
  final directory = await _getProfileDirectory();
  final prefix = '${directory.path}${Platform.pathSeparator}';
  if (!path.startsWith(prefix)) return;

  final fileName = path.substring(prefix.length);
  if (!fileName.startsWith('profile_photo_')) return;
  await _deleteFile(path);
}

Future<void> _deleteFile(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } catch (_) {
    // Best-effort cleanup must never make profile editing fail.
  }
}

String _messageForPlatformError(PlatformException error) {
  final code = error.code.toLowerCase();
  if (code.contains('denied') || code.contains('permission')) {
    return 'دسترسی به عکس‌ها داده نشد. لطفاً از تنظیمات دستگاه اجازه دسترسی بدهید.';
  }
  if (code == 'already_active') {
    return 'انتخاب‌گر عکس باز است؛ لطفاً همان پنجره را کامل کنید.';
  }
  return 'گالری باز نشد؛ لطفاً دوباره تلاش کنید.';
}

void _showPhotoError(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(content: Text(message)),
  );
}

class _ProfileAvatarPreview extends StatelessWidget {
  const _ProfileAvatarPreview({
    required this.photoPath,
    required this.selectedAvatar,
  });

  final String? photoPath;
  final String selectedAvatar;

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      return Image.file(
        File(photoPath!),
        fit: BoxFit.cover,
        width: 92,
        height: 92,
        cacheWidth: 276,
        cacheHeight: 276,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    if (selectedAvatar.startsWith('assets/')) {
      return Image.asset(
        selectedAvatar,
        fit: BoxFit.cover,
        width: 92,
        height: 92,
      );
    }
    return Center(
      child: Text(
        selectedAvatar,
        style: const TextStyle(fontSize: 42),
      ),
    );
  }
}

class _ProfilePhotoException implements Exception {
  const _ProfilePhotoException(this.message);

  final String message;

  @override
  String toString() => message;
}
