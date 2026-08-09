import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/game_data.dart';

Future<void> showProfileEditor(BuildContext context) async {
  final name = TextEditingController(text: GameData.childName);
  String? photo = GameData.profilePhotoPath.isEmpty ? null : GameData.profilePhotoPath;
  String selectedAvatar = GameData.avatar;
  await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (sheetContext) => StatefulBuilder(builder: (context, setState) => Padding(
    padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.viewInsetsOf(context).bottom + 28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('ویرایش پروفایل', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18),
      GestureDetector(onTap: () async {
        try {
          final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 92);
          if (image == null) return;
          final cropped = await ImageCropper().cropImage(
            sourcePath: image.path,
            compressFormat: ImageCompressFormat.jpg,
            compressQuality: 88,
            maxWidth: 900,
            maxHeight: 900,
            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'برش عکس پروفایل',
                toolbarColor: const Color(0xFF6C43D9),
                toolbarWidgetColor: Colors.white,
                activeControlsWidgetColor: const Color(0xFF6C43D9),
                lockAspectRatio: true,
              ),
            ],
          );
          if (cropped == null || !await File(cropped.path).exists()) return;
          final docs = await getApplicationDocumentsDirectory();
          final destination = File('${docs.path}/profile_photo.jpg');
          final saved = await File(cropped.path).copy(destination.path);
          if (context.mounted) setState(() => photo = saved.path);
        } catch (_) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('انتخاب یا برش عکس انجام نشد؛ دوباره تلاش کنید.')),
          );
        }
      }, child: CircleAvatar(radius: 46, backgroundImage: photo != null && File(photo!).existsSync() ? FileImage(File(photo!)) : null, child: photo == null ? const Icon(Icons.add_a_photo_rounded, size: 30) : null)),
      const SizedBox(height: 8), const Text('برای انتخاب عکس خودت بزنید'), const SizedBox(height: 18),
      const Align(alignment: Alignment.centerRight, child: Text('یا یک آواتار آماده انتخاب کن', style: TextStyle(fontWeight: FontWeight.bold))),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: List.generate(6, (index) {
        final asset = 'assets/avatars/avatar_$index.png';
        final active = selectedAvatar == asset && photo == null;
        return GestureDetector(onTap: () => setState(() { selectedAvatar = asset; photo = null; }), child: AnimatedContainer(duration: const Duration(milliseconds: 180), width: 54, height: 54, padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: active ? const Color(0xFF6C43D9) : Colors.transparent, width: 3)), child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover))));
      })),
      const SizedBox(height: 16),
      TextField(controller: name, maxLength: 24, decoration: const InputDecoration(labelText: 'نام کودک', border: OutlineInputBorder())),
      const SizedBox(height: 12), FilledButton(onPressed: () { GameData.updateProfile(name: name.text, photoPath: photo ?? '', avatarIcon: selectedAvatar); Navigator.pop(sheetContext); }, child: const Text('ذخیره تغییرات')),
    ]),
  )));
  name.dispose();
}
