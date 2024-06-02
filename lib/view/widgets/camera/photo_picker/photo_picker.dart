import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/index.dart';
import 'button_row.dart';
import 'info_text.dart';

class PhotoPickerView extends StatefulWidget {
  final Future<void> Function(Uint8List) requestImage;

  const PhotoPickerView({
    super.key,
    required this.requestImage,
  });

  @override
  State<PhotoPickerView> createState() => _PhotoPickerViewState();
}

class _PhotoPickerViewState extends State<PhotoPickerView> {
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isScanning = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted) return;
        final pickedFile = await _picker.pickImage(source: source);
        if (pickedFile == null) return;
        final bytes = await File(pickedFile.path).readAsBytes();
        await File(pickedFile.path).delete();

        if (!mounted) return;
        await widget.requestImage(bytes);
      } finally {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: InfoTextView(),
            ),
            ButtonRowView(
              isScanning: _isScanning,
              pickImageFromGallery: () => _pickImage(ImageSource.gallery),
              pickImageFromCamera: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
        if (_isScanning)
          const Center(
            child: LoadView(),
          ),
      ],
    );
  }
}
