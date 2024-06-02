import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/index.dart';

/// 履歴データ取得を管理するためのFutureProvider
///
/// このProviderは、データを非同期で取得し、状態管理を容易にします。
final fetchHistoryFutureProvider = FutureProvider<void>((ref) async {
  await ref.read(historyNotifierProvider.notifier).fetch();
});

/// 画像と大喜利の結果の履歴を管理します。
///
/// 推奨されるステート変数名: `historyList`
///
/// 利用可能なメソッド:
/// - `fetch`: 履歴を取得し、更新する
final historyNotifierProvider =
    NotifierProvider<_HistoryNotifier, List<History>>(
  _HistoryNotifier.new,
);

class _HistoryNotifier extends Notifier<List<History>> {
  @override
  List<History> build() {
    return [];
  }

  /// 履歴を取得し、更新する
  Future<void> fetch() async {
    // ランダムに並び替えて仮のデータを取得する
    await Future.delayed(const Duration(seconds: 2));
    final data = await _getAwsFetchData()
      ..shuffle();
    state = data;
  }

  Future<List<History>> _getAwsFetchData() async {
    return [
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/ad6a37c150f79a16d8562ad83ac8510c_600.jpg",
          text: "ログイン出来なさすぎてGoogle本社に来た"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/8e93489c2ab7c1ab4e07210fda9036ea_600.jpg",
          text: "パンにすら耳があるのに！"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/15c48f9f887c8c36a17603ef958870e9_600.jpg",
          text: "10問目の質問に答えることが"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/a308a12154690bc5048b71ac50e4e2e6_600.jpg",
          text: "アマゾンのプライム無料期間"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/402bb7fb82a65ce1513e9871c69b6772_600.jpg",
          text: "お前ならまだ女湯に入れる"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/4e8122c7b1125ebecd1db8dbb9f20e21_600.jpg",
          text: "人が食べてる所ジロジロ見ないでくれる？キモいんだけど？"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/b19ee6bb30340ae32917ec1a4ac89d90_600.jpg",
          text: "パラシュートはつけ"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/99db7e3367a4f919956db27ea54da5a8_600.jpg",
          text: "宿題は後です／ゲーム終わったら／お母さんに怒"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/717b0ea91a2bfb2b07a5f73d57b60767_600.jpg",
          text: "「人間の分際でこの我に餌やりなど100年早ﾓｸﾞﾓｸﾞﾓｸﾞﾓｸﾞ」"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/e0e25a48bd2d7881a963d621d01c156d_600.jpg",
          text: "蒸気なサザエさん"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/4bdb361e4e9982b9fb1be15c5c21f8de_600.jpg",
          text: "～、上着もねぇ、ズボンもねぇ、おかげでデベソがバ～レバレ"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/8ddf3d9ca5c68e0437462695bef55e44_600.jpg",
          text: "「僕は真剣なんです！」と伝えたら「私もよ」と返事をもらえたが思ったのと違う"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/514257a0588f7a31496280813638c8b0_600.jpg",
          text: "めっちゃ新しいやつじゃん！！うちまだWindows10だそ"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/0015bc414f1c8e1c4b8ae549d37c4ec6_600.jpg",
          text: "お金よ！ね？ケ"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/a5390e5524a74b6967f00bef043fae80_600.jpg",
          text: "各粒一斉にスタートしました！"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/7141b860624ef7e803f86aaec902b323_600.jpg",
          text: "ワンオペなんです"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/88b6642c14bd0ca19510bab4295849d1_600.jpg",
          text: "サンリオは退職しました。今は好きなことして生きてますよ。"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/655e3aba6381de4fa1ac184a032532ad_600.jpg",
          text: "崖に埋めた捕虜"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/162bf53295bef78532b99d717259cb61_600.jpg",
          text: "なぁ、ヤマトって給料いいの？"),
      const History(
          url:
              "https://d2dcan0armyq93.cloudfront.net/photo/odai/600/e1b996c52c845d00fac782a33c5d3123_600.jpg",
          text: "タンスの角「俺だって痛えよ！」"),
    ];
  }
}
