import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tutorial/model/page_type.dart';

import '../../../view_model/index.dart';

const double headerHeight = kToolbarHeight * 0.9;

class HeaderView extends ConsumerWidget implements PreferredSizeWidget {
  const HeaderView({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(headerHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentType = ref.watch(currentPageNotifierProvider);
    return AppBar(
      elevation: 0,
      title: Center(
        child: Text(
          _getTitle(currentType),
          style: const TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'ヒラギノ角ゴ ProN W3',
            color: Color(0xFF333333),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }

  String _getTitle(PageType type) {
    switch (type) {
      case PageType.home:
        return "大喜利";
      case PageType.camera:
        return "AIに聞く";
      case PageType.judge:
        return "判定";
      default:
        return "未定義のページ";
    }
  }
}
