import 'dart:async';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/index.dart';
import 'camera_dialog_notifier.dart';

/// 画像と文字列の結果を管理する。
///
/// 推奨されるステート変数名: `result`
///
/// 利用可能なメソッド:
/// - `setResult(Result? result)`: 結果を設定するメソッド。
/// - `registerAndAwaitImageProcessing`: 画像を登録し、処理の完了を待機します。
final resultNotifierProvider = NotifierProvider<_ResultNotifier, Result?>(
  _ResultNotifier.new,
);

class _ResultNotifier extends Notifier<Result?> {
  @override
  Result? build() {
    return null;
  }

  /// 結果を設定するメソッド。
  ///
  /// [result] - 設定する結果のインスタンス（またはnull）。
  void setResult(Result? result) {
    state = result;
  }

  /// 画像を登録後、処理の完了まで待機する
  ///
  /// [image] - 登録する画像のバイトデータ
  Future<void> registerAndAwaitImageProcessing(Uint8List image) async {
    try {
      // 取得した画像を設定し、ダイアログを開く
      final resultImage = Result(byte: image, text: "");
      setResult(resultImage);
      ref.read(cameraDialogNotifierProvider.notifier).sendIsOpen(true);

      // ダイアログが閉じるのを待つ
      await _waitForCloseDialog();
    } finally {
      setResult(null);
    }
  }

  Future<void> _waitForCloseDialog() async {
    final completer = Completer<void>();
    final sub = ref.listen<bool>(
      cameraDialogNotifierProvider,
      (previous, next) {
        if (next == false && !completer.isCompleted) {
          completer.complete();
        }
      },
    );
    await completer.future;
    sub.close();
  }
}
