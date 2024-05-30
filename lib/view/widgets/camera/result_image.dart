import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../view_model/index.dart';

class ResultImageView extends ConsumerWidget {
  const ResultImageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultImage = ref.watch(resultImageNotifierProvider);

    if (resultImage == null) {
      return const SizedBox.shrink(); // resultImageがnullの場合、何も表示しない
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false, // ダイアログ外のタップで閉じないようにする
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 45),
                    Image.network(resultImage.url),
                    const SizedBox(height: 20),
                    Text(resultImage.result),
                    const SizedBox(height: 20),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref
                          .read(resultImageNotifierProvider.notifier)
                          .setResult(null);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });

    return const SizedBox.shrink(); // ダイアログ表示中はこのウィジェット自体は何も表示しない
  }
}
