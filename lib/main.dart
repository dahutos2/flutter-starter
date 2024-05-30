import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'view/index.dart';
import 'view_model/index.dart';

void main() async {
  // 他のすべてのコードがフレームワークの初期化後に実行されるようにする
  WidgetsFlutterBinding.ensureInitialized();

  // 画面の向きを固定する
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 非同期初期化処理
  final container = ProviderContainer();
  await container.read(cameraNotifierProvider.notifier).initialize();

  runApp(
    ProviderScope(
      parent: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // ヘッダー部分に「debug」という文言を表示しないようにする
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
