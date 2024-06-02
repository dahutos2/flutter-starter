import 'package:flutter/material.dart';

class ImageButtonView extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isScanning;
  final VoidCallback onPressed;

  const ImageButtonView({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isScanning,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isScanning ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isScanning ? const Color(0xFFE0E0E0) : color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFFFFFFFF)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
