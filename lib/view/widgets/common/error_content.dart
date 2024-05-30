import 'package:flutter/material.dart';

class ErrorContentView extends StatelessWidget {
  final String text;
  const ErrorContentView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF8E8E93),
      child: Center(
        child: Text(
          text,
          softWrap: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
