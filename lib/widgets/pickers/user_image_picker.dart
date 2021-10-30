import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(this.imagePickFn, {Key? key}) : super(key: key);

  final void Function(File pickedImage) imagePickFn;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  bool _picked = false;

  @override
  void initState() {
    super.initState();
    _picked = false;
  }

  Future<void> _pickImage() async {
    final pickedImageFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);

    if (pickedImageFile != null) {
      _picked = true;
    }

    setState(() {
      _pickedImage = File(pickedImageFile!.path);
    });
    widget.imagePickFn(_pickedImage!);
  }

  ImageProvider pick() {
    if (_picked) {
      return FileImage(File(_pickedImage!.path));
    } else {
      return const AssetImage('image/images.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.grey[700],
          backgroundImage: pick(),
        ),
        const SizedBox(
          height: 2,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          label: const Text('Add Image'),
          icon: const Icon(Icons.image),
        )
      ],
    );
  }
}
