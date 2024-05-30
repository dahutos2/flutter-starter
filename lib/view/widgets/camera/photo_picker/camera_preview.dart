import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewView extends StatelessWidget {
  final CameraController controller;
  final double aspectRatio;
  final double zoomLevel;
  final ValueChanged<double> onZoomLevelChanged;

  const CameraPreviewView({
    Key? key,
    required this.controller,
    required this.aspectRatio,
    required this.zoomLevel,
    required this.onZoomLevelChanged,
  }) : super(key: key);

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double scaleChange = _computeScaleChange(details.scale, zoomLevel);
    onZoomLevelChanged((zoomLevel + scaleChange).clamp(1.0, 8.0));
  }

  double _computeScaleChange(double currentScale, double zoomLevel) {
    double scaleDifference = currentScale - zoomLevel;
    double baseRate = 0.05;

    return scaleDifference > 0 ? baseRate : -baseRate;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Transform.scale(
        scale: controller.value.aspectRatio * aspectRatio,
        child: Center(
          child: GestureDetector(
            onScaleUpdate: _handleScaleUpdate,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}
