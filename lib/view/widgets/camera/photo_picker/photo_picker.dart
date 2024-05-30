import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../common/index.dart';
import 'camera_isolate.dart';
import 'camera_preview.dart';
import 'zoom_indicator.dart';
import 'camera_controls.dart';

class PhotoPickerView extends StatefulWidget {
  final CameraDescription camera;
  final Future<void> Function(Uint8List?) requestImage;
  final double aspectRatio;

  const PhotoPickerView({
    super.key,
    required this.camera,
    required this.requestImage,
    this.aspectRatio = 11 / 14,
  });

  @override
  State<PhotoPickerView> createState() => _PhotoPickerViewState();
}

class _PhotoPickerViewState extends State<PhotoPickerView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isScanning = false;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(void Function() func) {
    if (mounted) {
      super.setState(func);
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isScanning = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.startImageStream(_processImage);
    });
  }

  Future<void> _processImage(CameraImage cameraImage) async {
    try {
      await _controller.stopImageStream();
      await _controller.pausePreview();
      if (!mounted) return;

      final bytes = await CameraIsolate.convertAndProcessCameraImage(
          cameraImage, widget.camera, widget.aspectRatio);
      await widget.requestImage(bytes);
    } finally {
      setState(() {
        _isScanning = false;
      });
      _controller.resumePreview();
    }
  }

  void _updateZoomLevel(double zoomLevel) {
    setState(() {
      _zoomLevel = zoomLevel;
    });
    _controller.setZoomLevel(_zoomLevel);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorContentView(text: '例外が発生しました。');
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: Stack(
                children: [
                  CameraPreviewView(
                    controller: _controller,
                    aspectRatio: widget.aspectRatio,
                    zoomLevel: _zoomLevel,
                    onZoomLevelChanged: _updateZoomLevel,
                  ),
                  ZoomIndicatorView(zoomLevel: _zoomLevel),
                  CameraControlsView(
                    isScanning: _isScanning,
                    startRecording: _startRecording,
                  ),
                  if (_isScanning)
                    const Center(
                      child: ColorfulLoadView(),
                    ),
                ],
              ),
            );
          } else {
            return const Center(
              child: ColorfulLoadView(),
            );
          }
        });
  }
}
