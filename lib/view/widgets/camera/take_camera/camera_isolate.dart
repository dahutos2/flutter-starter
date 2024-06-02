import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imglib;

/// 画面を固まらせないために、別スレッドでカメラの処理を行うクラス。
class CameraIsolate {
  CameraIsolate._();

  /// バイト配列の画像を特定のアスペク比で切り取る。
  static Future<Uint8List?> cropImageToAspectRatio(
    Uint8List bytes,
    double aspectRatio,
  ) async {
    final Map<String, dynamic> imageData = {
      'bytes': bytes,
      'aspectRatio': aspectRatio,
    };

    return await compute(_clipImage, imageData);
  }

  static Uint8List? _clipImage(Map<String, dynamic> imageData) {
    final Uint8List bytes = imageData['bytes'];
    final double aspectRatio = imageData['aspectRatio'];

    final originalImage = imglib.decodeImage(bytes);
    if (originalImage == null) return null;

    final double originalWidth = originalImage.width.toDouble();
    final double originalHeight = originalImage.height.toDouble();
    final double originalAspectRatio = originalWidth / originalHeight;

    // ignore: avoid_multiple_declarations_per_line
    double scaledWidth, scaledHeight;
    if (originalAspectRatio > aspectRatio) {
      // 元画像の方が幅の比が大きい
      scaledWidth = originalHeight * aspectRatio;
      scaledHeight = originalHeight;
    } else {
      // 元画像の方が高さの比が大きい
      scaledWidth = originalWidth;

      // 0で割らないようにする
      scaledHeight = originalWidth / max(aspectRatio, 1e-10);
    }

    final int cropX = (originalWidth - scaledWidth) ~/ 2;
    final int cropY = (originalHeight - scaledHeight) ~/ 2;
    final int cropWidth = scaledWidth.toInt();
    final int cropHeight = scaledHeight.toInt();

    final imglib.Image croppedImage = imglib.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    return Uint8List.fromList(imglib.encodePng(croppedImage));
  }
}
