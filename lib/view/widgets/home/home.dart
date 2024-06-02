import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../view_model/index.dart';
import '../common/index.dart';
import 'history_content.dart';
import 'main_history_content.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 履歴リストの状態を監視する
    final historyList = ref.watch(historyNotifierProvider);

    // データ取得の状態を監視する
    final fetchFuture = ref.watch(fetchHistoryFutureProvider);

    return RefreshIndicator(
      // 引っ張って更新するためのコールバック
      onRefresh: () async {
        // fetchFutureProviderをリフレッシュしてデータを再取得する
        final _ = await ref.refresh(fetchHistoryFutureProvider.future);
      },
      child: Stack(
        children: [
          // 履歴リストを表示するためのListView
          ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                // 最初のアイテムには特別なビューを表示
                return MainHistoryContentView(
                  imageUrl: historyList[index].url,
                  text: historyList[index].text,
                );
              } else {
                // 残りのアイテムには標準のビューを表示
                return HistoryContentView(
                  imageUrl: historyList[index].url,
                  text: historyList[index].text,
                );
              }
            },
          ),

          // データを取得中の場合はロードインジケータを表示
          if (fetchFuture.isLoading) const Center(child: LoadView()),
        ],
      ),
    );
  }
}
