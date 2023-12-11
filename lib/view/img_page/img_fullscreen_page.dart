import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ImgFullScreenPage extends HookConsumerWidget {
  const ImgFullScreenPage({
    super.key,
    required this.img,
    required this.onCancel,
  });
  final Uint8List img;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = MediaQuery.of(context).size.height;
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final top = useState<double>(0);
    final left = useState<double>(0);
    final backgroundOpacity = useState<double>(1);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(backgroundOpacity.value),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: top.value,
              left: left.value,
              child: Draggable(
                onDragEnd: (details) {
                  if (details.offset.dx.abs() > safeAreaWidth / 2.5 ||
                      details.offset.dy.abs() > safeAreaHeight / 4) {
                    onCancel();
                  } else {
                    backgroundOpacity.value = 0.9;
                    top.value = 0;
                    left.value = 0;
                  }
                },
                onDraggableCanceled: (_, details) {
                  backgroundOpacity.value = 0.9;
                  top.value = 0;
                  left.value = 0;
                },
                onDragUpdate: (details) {
                  top.value += details.delta.dy;
                  left.value += details.delta.dx;
                  if (top.value < 0) {
                    backgroundOpacity.value = top.value.abs() * 2;
                  } else {
                    backgroundOpacity.value = top.value.abs() * 2;
                  }
                  backgroundOpacity.value = 1 -
                      (backgroundOpacity.value + left.value.abs()) /
                          (safeAreaHeight + safeAreaWidth);
                },
                feedback: mainWidget(context),
                childWhenDragging: Container(),
                child: mainWidget(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mainWidget(BuildContext context) {
    final safeAreaHeight = MediaQuery.of(context).size.height;
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return Container(
      alignment: Alignment.topRight,
      height: safeAreaHeight * 0.9,
      width: safeAreaWidth * 1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(image: MemoryImage(img), fit: BoxFit.cover),
      ),
      child: Padding(
        padding: EdgeInsets.all(safeAreaWidth * 0.02),
        child: GestureDetector(
          onTap: () => onCancel(),
          child: Icon(
            Icons.close,
            color: Colors.white.withOpacity(0.6),
            size: safeAreaWidth / 12,
          ),
        ),
      ),
    );
  }
}
