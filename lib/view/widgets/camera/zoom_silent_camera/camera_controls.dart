import 'package:flutter/material.dart';

import 'camera_button.dart';

class CameraControlsView extends StatelessWidget {
  final bool isScanning;
  final VoidCallback pickFromGallery;
  final VoidCallback startRecording;
  final VoidCallback switchLensDirection;

  const CameraControlsView({
    Key? key,
    required this.isScanning,
    required this.pickFromGallery,
    required this.startRecording,
    required this.switchLensDirection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E).withOpacity(0.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x13747480),
              offset: Offset(0, 2),
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.photo_library),
              color: const Color(0xFFFFFFFF),
              iconSize: 40,
              onPressed: isScanning ? null : pickFromGallery,
            ),
            CameraButtonView(
              isScanning: isScanning,
              startRecording: startRecording,
            ),
            IconButton(
              icon: const Icon(Icons.autorenew),
              color: const Color(0xFFFFFFFF),
              iconSize: 40,
              onPressed: isScanning ? null : switchLensDirection,
            ),
          ],
        ),
      ),
    );
  }
}
