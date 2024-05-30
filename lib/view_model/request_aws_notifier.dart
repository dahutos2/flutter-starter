import 'dart:async';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/index.dart';
import 'result_image_notifier.dart';

final requestAwsNotifierProvider = NotifierProvider<_RequestAwsNotifier, bool>(
  _RequestAwsNotifier.new,
);

class _RequestAwsNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> sendImage(Uint8List? image) async {
    try {
      state = true;
      await Future.delayed(const Duration(seconds: 2));
      const url =
          "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/c293d1e2e91cf65bb56739f123d14388_600.jpg";
      const result = "今日、ケンタッキーにしない？";
      const resultImage = ResultImage(url: url, result: result);
      ref.read(resultImageNotifierProvider.notifier).setResult(resultImage);

      // resultImageNotifierの状態がnullになるまで待つ
      await _waitForClear();
    } finally {
      state = false;
    }
  }

  Future<void> _waitForClear() async {
    final completer = Completer<void>();
    final sub = ref.listen<ResultImage?>(
      resultImageNotifierProvider,
      (previous, next) {
        if (next == null && !completer.isCompleted) {
          completer.complete();
        }
      },
    );
    await completer.future;
    sub.close();
  }
}
