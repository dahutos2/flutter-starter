import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/index.dart';

final resultImageNotifierProvider =
    NotifierProvider<_ResultImageNotifier, ResultImage?>(
  _ResultImageNotifier.new,
);

class _ResultImageNotifier extends Notifier<ResultImage?> {
  @override
  ResultImage? build() {
    return null;
  }

  void setResult(ResultImage? result) {
    state = result;
  }
}
