import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewView extends StatelessWidget {
  final CameraController controller;
  final double aspectRatio;

  const CameraPreviewView({
    Key? key,
    required this.controller,
    required this.aspectRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Transform.scale(
        scale: controller.value.aspectRatio * aspectRatio,
        child: Center(
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
