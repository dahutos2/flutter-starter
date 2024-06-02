import 'dart:typed_data';

import 'package:meta/meta.dart';

@immutable
class Result {
  final Uint8List byte; // 画像のバイナリ
  final String text; // 結果の文言

  const Result({
    required this.byte,
    required this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      (other is Result && other.byte == byte && other.text == text);

  @override
  int get hashCode => Object.hash(runtimeType, byte, text);
}
