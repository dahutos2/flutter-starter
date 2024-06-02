import 'dart:typed_data';

import 'package:flutter/material.dart';

class ResultImageView extends StatelessWidget {
  final Uint8List imageBytes;

  const ResultImageView({Key? key, required this.imageBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Image.memory(
          imageBytes,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
