import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../model/index.dart';
import '../../../view_model/index.dart';

class FooterView extends ConsumerWidget {
  const FooterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BottomAppBar(
      color: Color(0xFFFFFFFF),
      child: Row(
        children: [
          _BottomNavItemView(PageType.home),
          _BottomNavItemView(PageType.camera),
          _BottomNavItemView(PageType.judge),
        ],
      ),
    );
  }
}

class _BottomNavItemView extends ConsumerWidget {
  final PageType type;
  const _BottomNavItemView(this.type);

  String _getLabel() {
    switch (type) {
      case PageType.home:
        return "ホーム";
      case PageType.camera:
        return "カメラ";
      case PageType.judge:
        return "判定";
      default:
        return "未定義";
    }
  }

  IconData _getIconData() {
    switch (type) {
      case PageType.home:
        return Icons.home;
      case PageType.camera:
        return Icons.add_a_photo;
      case PageType.judge:
        return Icons.question_mark;
      default:
        // 未定義の型の場合は、ハテナマーク
        return Icons.question_mark;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentType = ref.watch(currentPageNotifierProvider);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // 同じページの場合は何もしない
            if (currentType == type) return;
            ref.read(currentPageNotifierProvider.notifier).setType(type);
          },

          // 現在表示しているかどうかでアイコンの色を変える
          icon: Column(
            children: [
              Icon(
                _getIconData(),
                color: currentType == type
                    ? const Color(0xFFFF3B30)
                    : const Color(0xFF333333),
              ),
              Expanded(
                child: Text(
                  _getLabel(),
                  style: currentType == type
                      ? const TextStyle(fontSize: 13, color: Color(0xFFE90404))
                      : const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
