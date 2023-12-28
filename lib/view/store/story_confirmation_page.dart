import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ImgConfirmation extends HookConsumerWidget {
  ImgConfirmation({super.key, required this.img, required this.storeData});
  final Uint8List img;
  final StoreData storeData;
  final GlobalKey repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final imgData = useState<Uint8List>(img);
    final isLoading = useState<bool>(false);
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
            return Stack(
              children: [
                if (colorData.value.isNotEmpty) ...{
                  Column(
                    children: [
                      RepaintBoundary(
                        key: repaintBoundaryKey,
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 9 / 16,
                              child: Container(
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
                                    final appBarHeight =
                                        Scaffold.of(innerContext)
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
                                    final double fpX = focalPoint[0] as double;
                                    final double fpY = focalPoint[1] as double;
                                    transform.value
                                      ..translate(fpX, fpY)
                                      ..rotateZ(rotationDelta)
                                      ..scale(scaleDelta)
                                      ..translate(-fpX, -fpY);
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
                                  child: AspectRatio(
                                    aspectRatio: 9 / 16,
                                    child: Container(
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
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          width: safeAreaWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (int i = 0; i < 3; i++) ...{
                                textButton(
                                    text: ["キャンセル", "元に戻す", "完了"][i],
                                    size: safeAreaWidth / 26,
                                    onTap: [
                                      () => Navigator.pop(context),
                                      () {
                                        transform.value = Matrix4.identity();
                                        lastRotation.value = 0.0;
                                        lastScale.value = 1.0;
                                        lastFocalPoint.value = Offset.zero;
                                      },
                                      () async {
                                        isLoading.value = true;
                                        final getData = await capturePng();
                                        final setData = StoryType(
                                            img: getData,
                                            id: generateRandomString(),
                                            date: DateTime.now());
                                        final isUpData = await upDataStory(
                                            data: setData,
                                            id: storeData.id,
                                            isDelete: false);
                                        if (context.mounted) {
                                          if (isUpData) {
                                            final notifier = ref.read(
                                                userDataNotifierProvider
                                                    .notifier);
                                            notifier.addStoreData(StoreData(
                                                storyList: [
                                                  ...storeData.storyList,
                                                  setData
                                                ],
                                                logo: storeData.logo,
                                                id: storeData.id,
                                                name: storeData.name,
                                                address: storeData.address,
                                                businessHours:
                                                    storeData.businessHours,
                                                searchWord:
                                                    storeData.searchWord,
                                                eventList: storeData.eventList,
                                                location: storeData.location));
                                            isLoading.value = false;
                                            Navigator.pop(context);
                                          } else {
                                            isLoading.value = false;
                                            errorSnackbar(context,
                                                message:
                                                    "アップロードに失敗しました。ネットワーク接続を確認して、もう一度お試しください。");
                                          }
                                        }
                                      }
                                    ][i]),
                              }
                            ],
                          ),
                        ),
                      )
                    ],
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
                loadinPage(
                    context: context,
                    isLoading: isLoading.value,
                    text: "アップロード中...")
              ],
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
