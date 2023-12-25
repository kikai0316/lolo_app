import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/utility.dart';

class OnStore extends HookConsumerWidget {
  const OnStore({
    super.key,
    required this.storeData,
    required this.distance,
    required this.onTap,
  });
  final StoreData storeData;
  final String distance;
  final void Function() onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTapEvent = useState<bool>(false);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    return GestureDetector(
      onTap: () {
        isTapEvent.value = false;
        onTap();
      },
      onTapDown: (TapDownDetails downDetails) {
        isTapEvent.value = true;
      },
      onTapCancel: () {
        isTapEvent.value = false;
      },
      child: Hero(
        tag: storeData.id,
        child: SizedBox(
          width: safeAreaWidth * 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  isTapEvent.value ? safeAreaWidth * 0.008 : 0,
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: safeAreaWidth * 0.2,
                  width: safeAreaWidth * 0.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: storeData.postImgList.isEmpty
                        ? null
                        : const LinearGradient(
                            begin: FractionalOffset.topRight,
                            end: FractionalOffset.bottomLeft,
                            colors: [
                              Color.fromARGB(255, 4, 15, 238),
                              Color.fromARGB(255, 6, 120, 255),
                              Color.fromARGB(255, 4, 200, 255),
                            ],
                          ),
                    color: storeData.postImgList.isEmpty
                        ? Colors.grey.withOpacity(0.5)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(safeAreaHeight * 0.004),
                        child: Container(
                          alignment: Alignment.center,
                          height: double.infinity,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: blackColor,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(safeAreaHeight * 0.002),
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                image: storeData.logo == null
                                    ? notImg()
                                    : DecorationImage(
                                        image: MemoryImage(storeData.logo!),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            height: safeAreaWidth * 0.055,
                            width: safeAreaWidth * 0.055,
                            decoration: BoxDecoration(
                              color: greenColor,
                              boxShadow: [
                                BoxShadow(
                                  color: greenColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1.0,
                                )
                              ],
                              shape: BoxShape.circle,
                            ),
                          )),
                      Align(
                          alignment: Alignment.topRight,
                          child: nTextWithShadow(distance,
                              color: Colors.white,
                              opacity: 1,
                              fontSize: safeAreaWidth / 35,
                              bold: 700))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: safeAreaHeight * 0.01),
                child: nText(
                  storeData.name,
                  color: Colors.white.withOpacity(1),
                  fontSize: safeAreaWidth / 40,
                  bold: 700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool is12HoursPassed(DateTime data) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(data);
    return difference.inHours >= 12;
  }
}
