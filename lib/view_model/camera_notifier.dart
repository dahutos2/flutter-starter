import 'package:camera/camera.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final cameraNotifierProvider =
    NotifierProvider<_CameraNotifier, CameraDescription?>(
  _CameraNotifier.new,
);

class _CameraNotifier extends Notifier<CameraDescription?> {
  @override
  CameraDescription? build() {
    return null;
  }

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    state = cameras.first;
  }
}
