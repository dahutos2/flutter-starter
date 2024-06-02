import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../common/index.dart';
import 'camera_controls.dart';
import 'camera_helper.dart';
import 'camera_preview.dart';

class TakeCameraView extends StatefulWidget {
  final CameraDescription camera;
  final Future<void> Function(Uint8List) requestImage;
  final VoidCallback switchCamera;
  final double aspectRatio;

  const TakeCameraView({
    super.key,
    required this.camera,
    required this.requestImage,
    required this.switchCamera,
    this.aspectRatio = 11 / 14,
  });

  @override
  State<TakeCameraView> createState() => _TakeCameraViewState();
}

class _TakeCameraViewState extends State<TakeCameraView> {
  late CameraHelper _cameraHelper;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _cameraHelper = CameraHelper(widget.camera);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant TakeCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.camera != oldWidget.camera) {
      _cameraHelper.controller.setDescription(widget.camera);
    }
  }

  @override
  void dispose() {
    _cameraHelper.dispose();
    super.dispose();
  }

  bool _isMounted() => mounted;

  void _setScanningState(bool isScanning) {
    setState(() {
      _isScanning = isScanning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _cameraHelper.initializeControllerFuture,
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
                    controller: _cameraHelper.controller,
                    aspectRatio: widget.aspectRatio,
                  ),
                  CameraControlsView(
                    isScanning: _isScanning,
                    pickFromGallery: () => _cameraHelper.pickFromGallery(
                      requestImage: widget.requestImage,
                      setScanningState: _setScanningState,
                      isMounted: _isMounted,
                    ),
                    startRecording: () => _cameraHelper.startRecording(
                      requestImage: widget.requestImage,
                      aspectRatio: widget.aspectRatio,
                      setScanningState: _setScanningState,
                      isMounted: _isMounted,
                    ),
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
