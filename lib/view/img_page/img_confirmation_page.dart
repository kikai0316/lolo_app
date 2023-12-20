import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ImgConfirmation extends HookConsumerWidget {
  ImgConfirmation({super.key, required this.img, required this.onTap});
  final Uint8List img;
  final void Function(Uint8List) onTap;
  final GlobalKey repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final imgData = useState<Uint8List>(img);
    final colorData = useState<List<Color>>([]);
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

    useEffect(
      () {
        Future(() async {
          final getColor = await extractMainColorsFromImage(img);
          if (context.mounted) {
            colorData.value = getColor;
          }
        });
        return null;
      },
      [],
    );

    return SafeArea(
      child: Scaffold(
        key: const ValueKey("main"),
        backgroundColor: Colors.black,
        body: Builder(
          builder: (BuildContext innerContext) {
            return Container(
              height: safeAreaHeight * 1,
              width: safeAreaWidth * 1,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  if (colorData.value.isNotEmpty) ...{
                    RepaintBoundary(
                      key: repaintBoundaryKey,
                      child: Stack(
                        children: [
                          Container(
                            height: safeAreaHeight * 1,
                            width: safeAreaWidth * 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: FractionalOffset.topLeft,
                                end: FractionalOffset.bottomRight,
                                colors: [
                                  colorData.value[0].withOpacity(0.7),
                                  colorData.value[1].withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          ClipRect(
                            child: Transform(
                              transform: transform.value,
                              child: GestureDetector(
                                onScaleStart: (details) {
                                  lastScale.value = 1.0;
                                  lastRotation.value = 0.0;
                                  lastFocalPoint.value = details.focalPoint;
                                },
                                onScaleUpdate: (details) {
                                  final scaleDelta =
                                      details.scale / lastScale.value;
                                  final rotationDelta =
                                      details.rotation - lastRotation.value;

                                  // ピンチ操作の中心を計算
                                  final appBarHeight = Scaffold.of(innerContext)
                                          .appBarMaxHeight ??
                                      0.0;
                                  final focalPoint =
                                      vm.Matrix4.inverted(transform.value) *
                                          vm.Vector4(
                                            details.focalPoint.dx,
                                            details.focalPoint.dy -
                                                appBarHeight,
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
                                  final dx = details.focalPoint.dx -
                                      lastFocalPoint.value.dx;
                                  final dy = details.focalPoint.dy -
                                      lastFocalPoint.value.dy;
                                  transform.value =
                                      // ignore: unnecessary_cast
                                      Matrix4.translationValues(dx, dy, 0.0)
                                              .multiplied(transform.value)
                                          as Matrix4;

                                  lastScale.value = details.scale;
                                  lastRotation.value = details.rotation;
                                  lastFocalPoint.value = details.focalPoint;
                                },
                                child: Container(
                                  height: safeAreaHeight * 1,
                                  width: safeAreaWidth * 1,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(imgData.value),
                                      fit: BoxFit.fitWidth,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: safeAreaHeight * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (int i = 0; i < 2; i++) ...{
                              GestureDetector(
                                onTap: i == 0
                                    ? () async {
                                        await getMobileImage(
                                          onSuccess: (value) async {
                                            colorData.value = [];
                                            final getColor =
                                                await extractMainColorsFromImage(
                                              value,
                                            );
                                            if (context.mounted) {
                                              colorData.value = getColor;
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
                                child: Container(
                                  alignment: Alignment.center,
                                  height: safeAreaHeight * 0.05,
                                  width: safeAreaWidth * 0.45,
                                  decoration: BoxDecoration(
                                    color: i == 0 ? Colors.white : blueColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 1.0,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: nText(
                                    i == 0 ? "他の画像を選択..." : "完了",
                                    color: i == 0 ? blueColor : Colors.white,
                                    fontSize: safeAreaWidth / 30,
                                    bold: 700,
                                  ),
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
                  } else ...{
                    Container(
                      height: safeAreaHeight * 1,
                      width: safeAreaWidth * 1,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: loadinPage(
                        context: context,
                        isLoading: true,
                        text: null,
                      ),
                    ),
                  },
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<Color>> extractMainColorsFromImage(Uint8List imageData) async {
    // 画像データからui.Imageを作成
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageData, (ui.Image img) {
      completer.complete(img);
    });
    final ui.Image image = await completer.future;

    final ByteData? data = await image.toByteData();
    final int width = image.width;
    final int height = image.height;
    final Color topColor = extractDominantColor(data, width, height, 50);
    final Color bottomColor =
        extractDominantColor(data, width, height, 50, isBottomRegion: true);
    return [topColor, bottomColor];
  }

  Color extractDominantColor(
    ByteData? data,
    int width,
    int height,
    int regionHeight, {
    bool isBottomRegion = false,
  }) {
    if (data == null) return Colors.transparent;
    final int startY = isBottomRegion ? height - regionHeight : 0;
    final int endY = isBottomRegion ? height : regionHeight;
    final Map<int, int> colorCount = {};
    for (int y = startY; y < endY; y++) {
      for (int x = 0; x < width; x++) {
        final int offset = (y * width + x) * 4;
        final int red = data.getUint8(offset);
        final int green = data.getUint8(offset + 1);
        final int blue = data.getUint8(offset + 2);
        final int alpha = data.getUint8(offset + 3);
        final int colorValue =
            (alpha << 24) | (red << 16) | (green << 8) | blue;
        if (!colorCount.containsKey(colorValue)) {
          colorCount[colorValue] = 1;
        } else {
          colorCount[colorValue] = colorCount[colorValue]! + 1;
        }
      }
    }
    final int dominantColorValue =
        colorCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return Color(dominantColorValue);
  }
}
