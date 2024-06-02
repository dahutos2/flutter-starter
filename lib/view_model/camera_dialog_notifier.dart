import 'package:hooks_riverpod/hooks_riverpod.dart';

/// カメラダイアログが開いているか閉じているかを示すブール値の状態を提供します。
///
/// 推奨されるステート変数名: `isOpen`
///
/// 利用可能なメソッド:
/// - `sendIsOpen`: カメラダイアログが開いているかどうかの状態を更新します。
final cameraDialogNotifierProvider =
    NotifierProvider<_CameraDialogNotifier, bool>(
  _CameraDialogNotifier.new,
);

class _CameraDialogNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  /// カメラダイアログを開閉します。
  ///
  /// [isOpen] - `true` はダイアログが開いていることを示し、`false` は閉じていることを示します。
  void sendIsOpen(bool isOpen) {
    state = isOpen;
  }
}
