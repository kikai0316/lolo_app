import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'dart:ui' as ui;

import 'package:lolo_app/model/store_data.dart';

Widget mapButtonWidget(BuildContext context,
    {required Widget widget,
    required void Function()? onTap,
    required bool isLocation}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      height: safeAreaWidth * 0.15,
      width: safeAreaWidth * 0.15,
      decoration: BoxDecoration(
        color: isLocation ? blueColor2 : blackColor,
        border: Border.all(
          color: isLocation
              ? Colors.white.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: widget,
    ),
  );
}

class OnMarker extends HookConsumerWidget {
  const OnMarker({
    super.key,
    required this.storeData,
    required this.task,
  });
  final StoreData storeData;
  final void Function(Future<Uint8List?>) task;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repaintBoundaryKey = GlobalKey(debugLabel: storeData.id);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        alignment: Alignment.center,
        height: safeAreaWidth * 0.19,
        width: safeAreaWidth * 0.19,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: blueColor2.withOpacity(0.2),
          border: Border.all(color: blueColor.withOpacity(0.1)),
        ),
        child: Container(
            alignment: Alignment.center,
            height: safeAreaWidth * 0.115,
            width: safeAreaWidth * 0.115,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
            child: storeData.logo != null
                ? ClipOval(
                    child: Image.memory(
                      storeData.logo!,
                      fit: BoxFit.cover,
                      height: safeAreaWidth * 0.11,
                      width: safeAreaWidth * 0.11,
                      frameBuilder: (
                        BuildContext context,
                        Widget child,
                        int? frame,
                        bool wasSynchronouslyLoaded,
                      ) {
                        if (frame == null) {
                          return const SizedBox();
                        } else {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            task(getBytesFromWidget(repaintBoundaryKey));
                          });
                          return child;
                        }
                      },
                    ),
                  )
                : null),
      ),
    );
  }

  Future<Uint8List?> getBytesFromWidget(GlobalKey key) async {
    try {
      final RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}
