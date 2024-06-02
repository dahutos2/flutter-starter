import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/index.dart';

/// 現在のページを示す [PageType] の状態を提供します。
///
/// 推奨されるステート変数名: `currentType`
///
/// 利用可能なメソッド:
/// - `setType`: 現在のページのタイプを設定します。
final currentPageNotifierProvider =
    NotifierProvider<_CurrentPageNotifier, PageType>(
  _CurrentPageNotifier.new,
);

class _CurrentPageNotifier extends Notifier<PageType> {
  @override
  PageType build() {
    return PageType.home;
  }

  /// 現在のページのタイプを設定します。
  ///
  /// [type] - 設定するページのタイプ
  void setType(PageType type) {
    state = type;
  }
}
