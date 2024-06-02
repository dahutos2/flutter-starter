import 'package:flutter/material.dart';

import '../../common/index.dart';

class ResultTextView extends StatelessWidget {
  final bool isRequesting;
  final String resultText;

  const ResultTextView(
      {Key? key, required this.isRequesting, required this.resultText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF9E9E9E)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: isRequesting
              ? const LoadView()
              : Text(
                  resultText.isEmpty ? "AIに聞いてみよう！" : resultText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: resultText.isEmpty
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF000000),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                ),
        ),
      ),
    );
  }
}
