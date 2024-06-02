import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../view_model/index.dart';
import '../common/index.dart';
import 'dialog/index.dart';
import 'take_camera/index.dart';

class CameraView extends ConsumerWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.watch(cameraNotifierProvider);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return camera == null
            ? const ErrorContentView(text: 'カメラがありません。')
            : Stack(
                children: [
                  // PhotoPickerView(
                  //   requestImage: ref
                  //       .read(resultNotifierProvider.notifier)
                  //       .registerAndAwaitImageProcessing,
                  // ),
                  TakeCameraView(
                    camera: camera,
                    requestImage: ref
                        .read(resultNotifierProvider.notifier)
                        .registerAndAwaitImageProcessing,
                    switchCamera:
                        ref.read(cameraNotifierProvider.notifier).switchCamera,
                    aspectRatio: constraints.maxWidth / constraints.maxHeight,
                  ),
                  const CameraDialogView(),
                ],
              );
      },
    );
  }
}
