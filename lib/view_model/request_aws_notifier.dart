import 'dart:async';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/index.dart';
import 'result_notifier.dart';

/// 現在のリクエストの状態（処理中かどうか）を示すブール値を保持する。
///
/// 推奨されるステート変数名: `isRequesting`
///
/// 利用可能なメソッド:
/// - `sendImage`: 画像をAWSに送信し、結果を取得する非同期メソッド。
final requestAwsNotifierProvider = NotifierProvider<_RequestAwsNotifier, bool>(
  _RequestAwsNotifier.new,
);

class _RequestAwsNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  /// 画像をAWSに送信し、結果を取得する非同期メソッド。
  ///
  /// [image] - 送信する画像のバイトデータ。
  Future<void> sendImage(Uint8List image) async {
    try {
      state = true;

      // ここでAWSから結果を取得する
      // 仮で固定の文字を入れる
      await Future.delayed(const Duration(seconds: 2));
      const resultText = "今日、ケンタッキーにしない？";

      final result = Result(byte: image, text: resultText);
      ref.read(resultNotifierProvider.notifier).setResult(result);
    } finally {
      state = false;
    }
  }
}
