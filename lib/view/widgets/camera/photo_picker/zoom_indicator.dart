import 'package:flutter/material.dart';

class ZoomIndicatorView extends StatelessWidget {
  final double zoomLevel;

  const ZoomIndicatorView({Key? key, required this.zoomLevel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: MediaQuery.of(context).size.width * 0.5 - 30,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0x88000000),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          '${zoomLevel.toStringAsFixed(1)} ×',
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
