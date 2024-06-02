import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/index.dart';
import '../view_model/index.dart';
import 'widgets/index.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // キーボードが表示されても画面のコンテンツはサイズや位置が変わらないようにする
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFF8F5EF),
      appBar: HeaderView(),
      body: _SwitchView(),
      bottomNavigationBar: FooterView(),
    );
  }
}

class _SwitchView extends ConsumerWidget {
  const _SwitchView();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentType = ref.watch(currentPageNotifierProvider);

    switch (currentType) {
      case PageType.home:
        return const HomeView();
      case PageType.camera:
        return const CameraView();
      case PageType.judge:
        return const JudgeView();
      default:
        //　未定義の場合は、空のWidgetを返す
        return const SizedBox.shrink();
    }
  }
}
