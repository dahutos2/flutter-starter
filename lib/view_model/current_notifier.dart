import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/index.dart';

final currentPageNotifierProvider =
    NotifierProvider<CurrentPageNotifier, PageType>(
  CurrentPageNotifier.new,
);

class CurrentPageNotifier extends Notifier<PageType> {
  @override
  PageType build() {
    return PageType.home;
  }

  void setType(PageType type) {
    state = type;
  }
}
