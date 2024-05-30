import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../view_model/index.dart';
import '../common/index.dart';
import 'photo_picker/index.dart';
import 'result_image.dart';

class CameraView extends ConsumerWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.read(cameraNotifierProvider);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return camera == null
            ? const ErrorContentView(text: 'カメラがありません。')
            : Stack(
                children: [
                  PhotoPickerView(
                    camera: camera,
                    requestImage:
                        ref.read(requestAwsNotifierProvider.notifier).sendImage,
                    aspectRatio: constraints.maxWidth / constraints.maxHeight,
                  ),
                  const ResultImageView(),
                ],
              );
      },
    );
  }
}
