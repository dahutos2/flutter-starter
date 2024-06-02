import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'camera_isolate.dart';

class CameraHelper {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  CameraController get controller => _controller;
  Future<void> get initializeControllerFuture => _initializeControllerFuture;

  CameraHelper(CameraDescription initialCamera) {
    _initializeCameraController(initialCamera);
  }

  void dispose() {
    _controller.dispose();
  }

  void _initializeCameraController(CameraDescription cameraDescription) {
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> pickFromGallery({
    required Future<void> Function(Uint8List) requestImage,
    required Function(bool) setScanningState,
    required bool Function() isMounted,
  }) async {
    if (!isMounted()) return;
    setScanningState(true);

    // ステートの変更による画面反映が完了後処理を呼び出す
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!isMounted()) return;

        // 画像を選択する
        await _controller.pausePreview();
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile =
            await picker.pickImage(source: ImageSource.gallery);

        // 画像が取得できない場合は、何もしない
        if (pickedFile == null || !isMounted()) return;
        final bytes = await File(pickedFile.path).readAsBytes();

        // 不要になった画像は削除する
        await File(pickedFile.path).delete();

        if (!isMounted()) return;
        await requestImage(bytes);
      } finally {
        // 画面遷移により、画面が存在しない場合は何もしないようにする
        if (isMounted()) {
          setScanningState(false);
          await _controller.resumePreview();
        }
      }
    });
  }

  Future<void> startRecording({
    required Future<void> Function(Uint8List) requestImage,
    required double aspectRatio,
    required Function(bool) setScanningState,
    required bool Function() isMounted,
  }) async {
    if (!isMounted()) return;
    setScanningState(true);

    // ステートの変更による画面反映が完了後処理を呼び出す
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!isMounted()) return;

        // 画像を撮影する
        final takeFile = await _controller.takePicture();
        await _controller.pausePreview();
        final bytes = await File(takeFile.path).readAsBytes();

        // 不要になった画像は削除する
        await File(takeFile.path).delete();

        // 画面に映っている部分を切り取る
        final cropImageBytes =
            await CameraIsolate.cropImageToAspectRatio(bytes, aspectRatio);
        if (cropImageBytes == null || !isMounted()) return;
        await requestImage(bytes);
      } finally {
        // 画面遷移により、画面が存在しない場合は何もしないようにする
        if (isMounted()) {
          setScanningState(false);
          await _controller.resumePreview();
        }
      }
    });
  }
}
