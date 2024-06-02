import 'package:flutter/material.dart';

class HistoryContentView extends StatelessWidget {
  final String imageUrl;
  final String text;

  const HistoryContentView({
    super.key,
    required this.imageUrl,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 166,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 4),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12.0)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: 150,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(12.0)),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xDD000000),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
