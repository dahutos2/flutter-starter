import 'package:meta/meta.dart';

@immutable
class History {
  final String url; // 画像のURL
  final String text; // 結果の文言

  const History({
    required this.url,
    required this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      (other is History && other.url == url && other.text == text);

  @override
  int get hashCode => Object.hash(runtimeType, url, text);
}
