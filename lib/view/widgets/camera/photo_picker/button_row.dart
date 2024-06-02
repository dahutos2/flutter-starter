import 'package:flutter/material.dart';
import 'image_button.dart';

class ButtonRowView extends StatelessWidget {
  final bool isScanning;
  final VoidCallback pickImageFromGallery;
  final VoidCallback pickImageFromCamera;

  const ButtonRowView({
    super.key,
    required this.isScanning,
    required this.pickImageFromGallery,
    required this.pickImageFromCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageButtonView(
          icon: Icons.photo_library,
          label: 'ギャラリー',
          color: const Color(0xFF009688),
          isScanning: isScanning,
          onPressed: pickImageFromGallery,
        ),
        const SizedBox(width: 16),
        ImageButtonView(
          icon: Icons.camera_alt,
          label: 'カメラ',
          color: const Color(0xFF3F51B5),
          isScanning: isScanning,
          onPressed: pickImageFromCamera,
        ),
      ],
    );
  }
}
