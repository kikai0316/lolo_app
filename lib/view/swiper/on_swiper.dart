import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/utility.dart';

import 'package:lolo_app/widget/swiper_widget.dart';

class OnSwiper extends HookConsumerWidget {
  const OnSwiper({
    super.key,
    required this.storeData,
    required this.onNext,
    required this.onBack,
    required this.controller,
  });
  final StoreData storeData;
  final void Function() onNext;
  final void Function() onBack;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final imgIndex = useState<int>(0);

    return SafeArea(
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: [
            Container(
              height: safeAreaHeight * 1,
              width: double.infinity,
              decoration: BoxDecoration(
                image: storeData.postImgList.isNotEmpty
                    ? DecorationImage(
                        image: MemoryImage(
                            storeData.postImgList[imgIndex.value].img),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  if (storeData.postImgList.isEmpty) ...{
                    notPostWidget(context, storeData: storeData)
                  },
                  tapEventWidget(
                    context,
                    nextOnTap: () {
                      if (imgIndex.value < storeData.postImgList.length - 1) {
                        imgIndex.value++;
                      } else {
                        onNext();
                      }
                    },
                    backOnTap: () {
                      if (imgIndex.value > 0) {
                        imgIndex.value--;
                      } else {
                        onBack();
                      }
                    },
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: appBarWidget(context,
                        storeData: storeData, imgIndex: imgIndex.value),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: InformationContainerWidget(storeData: storeData)),
                ],
              ),
            ),
            SizedBox(
              height: safeAreaHeight * 0.01,
            ),
          ],
        ),
      ),
    );
  }
}
