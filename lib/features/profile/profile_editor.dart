import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/game_data.dart';

Future<void> showProfileEditor(BuildContext context) async {
  final name = TextEditingController(text: GameData.childName);
  String? photo = GameData.profilePhotoPath.isEmpty ? null : GameData.profilePhotoPath;
  await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (sheetContext) => StatefulBuilder(builder: (context, setState) => Padding(
    padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.viewInsetsOf(context).bottom + 28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('ویرایش پروفایل', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18),
      GestureDetector(onTap: () async {
        final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 900, imageQuality: 85);
        if (image == null) return;
        final docs = await getApplicationDocumentsDirectory();
        final saved = await File(image.path).copy('${docs.path}/profile_photo.jpg');
        setState(() => photo = saved.path);
      }, child: CircleAvatar(radius: 46, backgroundImage: photo != null && File(photo!).existsSync() ? FileImage(File(photo!)) : null, child: photo == null ? const Icon(Icons.add_a_photo_rounded, size: 30) : null)),
      const SizedBox(height: 8), const Text('برای انتخاب عکس بزنید'), const SizedBox(height: 16),
      TextField(controller: name, maxLength: 24, decoration: const InputDecoration(labelText: 'نام کودک', border: OutlineInputBorder())),
      const SizedBox(height: 12), FilledButton(onPressed: () { GameData.updateProfile(name: name.text, photoPath: photo ?? ''); Navigator.pop(sheetContext); }, child: const Text('ذخیره تغییرات')),
    ]),
  )));
  name.dispose();
}
