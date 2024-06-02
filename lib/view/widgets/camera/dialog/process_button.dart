import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../view_model/index.dart';

class ProcessButtonView extends ConsumerWidget {
  final Uint8List imageBytes;

  const ProcessButtonView({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // ダイアログを閉じる
              Navigator.of(context).pop();
              ref.read(cameraDialogNotifierProvider.notifier).sendIsOpen(false);
            },
            icon: const Icon(Icons.cancel),
            label: const Text('閉じる'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(requestAwsNotifierProvider.notifier)
                  .sendImage(imageBytes);
            },
            icon: const Icon(Icons.send),
            label: const Text('AIに依頼'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF448AFF),
            ),
          ),
        ],
      ),
    );
  }
}
