import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/index.dart';
import 'camera_isolate.dart';
import 'camera_preview.dart';
import 'zoom_indicator.dart';
import 'camera_controls.dart';

class ZoomSilentCameraView extends StatefulWidget {
  final CameraDescription camera;
  final Future<void> Function(Uint8List) requestImage;
  final VoidCallback switchCamera;
  final double aspectRatio;

  const ZoomSilentCameraView({
    super.key,
    required this.camera,
    required this.requestImage,
    required this.switchCamera,
    this.aspectRatio = 11 / 14,
  });

  @override
  State<ZoomSilentCameraView> createState() => _ZoomSilentCameraViewState();
}

class _ZoomSilentCameraViewState extends State<ZoomSilentCameraView> {
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
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void didUpdateWidget(covariant ZoomSilentCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.camera != oldWidget.camera) {
      _controller.setDescription(widget.camera);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isScanning = true;
    });

    // ステートの変更による画面反映が完了後処理を呼び出す
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted) return;

        // 画像を選択する
        await _controller.pausePreview();
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile =
            await picker.pickImage(source: ImageSource.gallery);

        // 画像が取得できない場合は、何もしない
        if (pickedFile == null || !mounted) return;
        final bytes = await File(pickedFile.path).readAsBytes();

        // 不要になった画像は削除する
        await File(pickedFile.path).delete();

        if (!mounted) return;
        await widget.requestImage(bytes);
      } finally {
        // 画面遷移により、画面が存在しない場合は何もしないようにする
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
          await _controller.resumePreview();
        }
      }
    });
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
      if (!mounted) return;
      await _controller.stopImageStream();
      await _controller.pausePreview();
      final bytes = await CameraIsolate.convertAndProcessCameraImage(
          cameraImage, widget.camera, widget.aspectRatio);

      if (bytes == null || !mounted) return;
      await widget.requestImage(bytes);
    } finally {
      // 画面遷移により、画面が存在しない場合は何もしないようにする
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        await _controller.resumePreview();
      }
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
                    pickFromGallery: _pickFromGallery,
                    startRecording: _startRecording,
                    switchLensDirection: widget.switchCamera,
                  ),
                  if (_isScanning)
                    const Center(
                      child: LoadView(),
                    ),
                ],
              ),
            );
          } else {
            return const Center(
              child: LoadView(),
            );
          }
        });
  }
}
