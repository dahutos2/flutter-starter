import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../view_model/index.dart';
import 'process_button.dart';
import 'result_image.dart';
import 'result_text.dart';

class CameraDialogContentView extends ConsumerWidget {
  const CameraDialogContentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(resultNotifierProvider);
    if (result == null) return const SizedBox.shrink();

    final isRequesting = ref.watch(requestAwsNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: ResultImageView(imageBytes: result.byte)),
        const SizedBox(height: 16),
        ResultTextView(isRequesting: isRequesting, resultText: result.text),
        const SizedBox(height: 16),
        ProcessButtonView(imageBytes: result.byte),
      ],
    );
  }
}
