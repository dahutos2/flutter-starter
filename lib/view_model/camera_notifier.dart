import 'dart:async';

import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// カメラの初期化とカメラデバイスの管理を行います。
///
/// 推奨されるステート変数名: `camera`
///
/// 利用可能なメソッド:
/// - `initialize`: カメラを初期化します。
/// - `switchCamera`: 現在のカメラを切り替えます。
final cameraNotifierProvider =
    NotifierProvider<_CameraNotifier, CameraDescription?>(
  _CameraNotifier.new,
);

class _CameraNotifier extends Notifier<CameraDescription?> {
  List<CameraDescription>? _cameras;
  int _currentIndex = 0;

  @override
  CameraDescription? build() {
    return null;
  }

  /// カメラを初期化します。
  ///
  /// 利用可能なカメラデバイスを取得し、最初のカメラデバイスを状態に設定します。
  Future<void> initialize() async {
    // 利用可能なカメラデバイスを取得する
    // 見つからない場合は、何もしない
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    // 外カメラ（背面カメラ）を探す
    _currentIndex = _cameras!.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    // 外カメラが見つからない場合は最初のカメラを初期カメラとして設定
    if (_currentIndex == -1) {
      _currentIndex = 0;
    }

    state = _cameras![_currentIndex];
  }

  /// 現在のカメラを切り替えます。
  ///
  /// 次のカメラにインデックスを移動し、状態を更新します。
  void switchCamera() {
    if (_cameras == null || _cameras!.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % _cameras!.length;
    state = _cameras![_currentIndex];
  }
}
