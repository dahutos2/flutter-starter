import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../view_model/index.dart';
import 'camera_dialog_content.dart';

class CameraDialogView extends ConsumerWidget {
  const CameraDialogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(cameraDialogNotifierProvider);
    if (isOpen == false) {
      return const SizedBox.shrink();
    }

    // ダイアログが表示中であれば閉じる
    if (ModalRoute.of(context)?.isCurrent != true) {
      Navigator.of(context).pop();
    }

    // isOpenがTrueの場合は、ダイアログを開く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false, // ダイアログ外のタップで閉じないようにする
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16.0),
              child: const CameraDialogContentView(),
            ),
          );
        },
      );
    });

    // ダイアログ表示中はこのウィジェット自体は何も表示しない
    return const SizedBox.shrink();
  }
}
