import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/index.dart';

final currentPageNotifierProvider =
    NotifierProvider<_CurrentPageNotifier, PageType>(
  _CurrentPageNotifier.new,
);

class _CurrentPageNotifier extends Notifier<PageType> {
  @override
  PageType build() {
    return PageType.home;
  }

  void setType(PageType type) {
    state = type;
  }
}
