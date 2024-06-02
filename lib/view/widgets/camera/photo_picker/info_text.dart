import 'package:flutter/material.dart';

class InfoTextView extends StatelessWidget {
  const InfoTextView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Color(0xFF009688),
              size: 28.0,
            ),
            SizedBox(width: 4),
            Text(
              '画像を選んでAIと大喜利を楽しもう！',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF009688),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'ギャラリーまたはカメラから画像を選択し\nAIが生成する大喜利を楽しんでください！',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xDD000000),
          ),
        ),
        SizedBox(height: 16),
        Text(
          '下のボタンから画像を選択してください',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xDD000000),
          ),
        ),
      ],
    );
  }
}
