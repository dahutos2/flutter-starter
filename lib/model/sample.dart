import 'package:meta/meta.dart';

@immutable
class Sample {
  final String url; // 画像のURL
  final String result; // 結果の文言

  const Sample({
    required this.url,
    required this.result,
  });

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      (other is Sample && other.url == url && other.result == result);

  @override
  int get hashCode => Object.hash(runtimeType, url, result);
}
