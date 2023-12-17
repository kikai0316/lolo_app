import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class LogoConfirmation extends HookConsumerWidget {
  LogoConfirmation({super.key, required this.img, required this.onTap});
  final Uint8List img;
  final void Function(Uint8List) onTap;
  final GlobalKey repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final imgData = useState<Uint8List>(img);
    final transform = useState<Matrix4>(Matrix4.identity());
    final lastRotation = useState(
      0.0,
    );
    final lastScale = useState(1.0);

    final lastFocalPoint = useState(Offset.zero);

    Future<Uint8List> capturePng() async {
      final RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final compressedResult =
          await FlutterImageCompress.compressWithList(pngBytes, quality: 100);
      return Uint8List.fromList(compressedResult);
    }

    return SafeArea(
      child: Scaffold(
        key: const ValueKey("main"),
        backgroundColor: Colors.black,
        body: Builder(
          builder: (
            BuildContext innerContext,
          ) {
            return Container(
              height: safeAreaHeight * 1,
              width: safeAreaWidth * 1,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RepaintBoundary(
                    key: repaintBoundaryKey,
                    child: Stack(
                      children: [
                        Transform(
                          transform: transform.value,
                          child: Container(
                            height: safeAreaWidth * 1,
                            width: safeAreaWidth * 1,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              image: DecorationImage(
                                image: MemoryImage(imgData.value),
                                fit: BoxFit.fitWidth,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onScaleStart: (details) {
                      lastScale.value = 1.0;
                      lastRotation.value = 0.0;
                      lastFocalPoint.value = details.focalPoint;
                    },
                    onScaleUpdate: (details) {
                      final scaleDelta = details.scale / lastScale.value;
                      final rotationDelta =
                          details.rotation - lastRotation.value;

                      // ピンチ操作の中心を計算
                      final appBarHeight =
                          Scaffold.of(innerContext).appBarMaxHeight ?? 0.0;
                      final focalPoint = vm.Matrix4.inverted(transform.value) *
                          vm.Vector4(
                            details.focalPoint.dx,
                            details.focalPoint.dy - appBarHeight,
                            0.0,
                            1.0,
                          );
                      // ignore: avoid_dynamic_calls
                      final double fpX = focalPoint[0] as double;
                      // ignore: avoid_dynamic_calls
                      final double fpY = focalPoint[1] as double;

                      // トランスフォームの更新
                      transform.value
                        ..translate(fpX, fpY)
                        ..rotateZ(rotationDelta)
                        ..scale(scaleDelta)
                        ..translate(-fpX, -fpY);

                      // ドラッグ移動の処理
                      final dx =
                          details.focalPoint.dx - lastFocalPoint.value.dx;
                      final dy =
                          details.focalPoint.dy - lastFocalPoint.value.dy;
                      transform.value =
                          // ignore: unnecessary_cast
                          Matrix4.translationValues(dx, dy, 0.0)
                              .multiplied(transform.value) as Matrix4;

                      lastScale.value = details.scale;
                      lastRotation.value = details.rotation;
                      lastFocalPoint.value = details.focalPoint;
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: TransparentCirclePainter(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: safeAreaWidth * 0.05,
                          right: safeAreaWidth * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < 2; i++) ...{
                            TextButton(
                              onPressed: i == 0
                                  ? () async {
                                      await getMobileImage(
                                        onSuccess: (value) async {
                                          if (context.mounted) {
                                            imgData.value = value;
                                          }
                                        },
                                        onError: () {
                                          errorSnackbar(
                                            context,
                                            message: "エラーが発生しました。",
                                          );
                                        },
                                      );
                                    }
                                  : () async {
                                      final getData = await capturePng();
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        onTap(getData);
                                      }
                                    },
                              style: ButtonStyle(
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors.white.withOpacity(0.3);
                                    }
                                    return Colors.transparent;
                                  },
                                ),
                              ),
                              child: nText(
                                i == 0 ? "他の画像を選択..." : "完了",
                                color: Colors.white,
                                fontSize: safeAreaWidth / 23,
                                bold: 700,
                              ),
                            ),
                          },
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(safeAreaWidth * 0.03),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 10.0,
                            ),
                          ],
                          color: Colors.white.withOpacity(1),
                          size: safeAreaWidth / 11,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(safeAreaWidth * 0.03),
                      child: GestureDetector(
                        onTap: () {
                          transform.value = Matrix4.identity();
                          lastRotation.value = 0.0;
                          lastScale.value = 1.0;
                          lastFocalPoint.value = Offset.zero;
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: safeAreaHeight * 0.037,
                          width: safeAreaWidth * 0.2,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1.0,
                              ),
                            ],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "元に戻す",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontFamily: "Normal",
                              fontVariations: const [
                                FontVariation("wght", 400),
                              ],
                              color: Colors.white,
                              fontSize: safeAreaWidth / 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class TransparentCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    Paint paint = Paint()..color = Colors.transparent;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    Path circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    Path backgroundPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      circlePath,
    );
    canvas.drawPath(
        backgroundPath, Paint()..color = Colors.black.withOpacity(0.8));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
