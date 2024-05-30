import 'package:flutter/material.dart';

class CameraButtonView extends StatelessWidget {
  final bool isScanning;
  final VoidCallback startRecording;

  const CameraButtonView({
    Key? key,
    required this.isScanning,
    required this.startRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 撮影中は、撮影できない
      onTap: isScanning ? null : startRecording,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x4D1C1C1E),
        ),
        child: CustomPaint(
          painter: CameraButtonPainter(isScanning: isScanning),
        ),
      ),
    );
  }
}

class CameraButtonPainter extends CustomPainter {
  final bool isScanning;

  CameraButtonPainter({
    required this.isScanning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 内側の円を描画
    canvas.drawCircle(center, radius - 4, paint);

    // 外側の円を描画
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, paint);

    if (isScanning) {
      paint
        ..style = PaintingStyle.fill
        ..color = Colors.black.withOpacity(0.5);
      canvas.drawCircle(center, radius - 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CameraButtonPainter oldDelegate) {
    return oldDelegate.isScanning != isScanning;
  }
}
