import 'package:meta/meta.dart';

@immutable
class ResultImage {
  final String url; // 画像のURL
  final String result; // 結果の文言

  const ResultImage({
    required this.url,
    required this.result,
  });

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      (other is ResultImage && other.url == url && other.result == result);

  @override
  int get hashCode => Object.hash(runtimeType, url, result);
}
