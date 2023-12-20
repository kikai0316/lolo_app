import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/view/swiper/on_swiper.dart';

final CarouselSliderController controller = CarouselSliderController();
final ScrollController scrollController = ScrollController();

class SwiperPage extends HookConsumerWidget {
  const SwiperPage({
    super.key,
    required this.index,
    required this.storeList,
  });
  final int index;
  final List<StoreData> storeList;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = useState<int>(index + 1);
    final isMove = useState<bool>(false);
    final scrollBack = useState<double>(0);

    Future<void> moveAnimation() async {
      isMove.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      isMove.value = false;
    }

    bool isNotScreen(int index) {
      if (index == 0 || index == storeList.length + 1) {
        return true;
      } else {
        return false;
      }
    }

    useEffect(
      () {
        void listener() {
          try {
            if (scrollController.offset < -60) {
              if (scrollBack.value > scrollController.offset) {
                scrollBack.value = scrollController.offset;
              } else {
                scrollController.removeListener(listener);
                Navigator.pop(context);
              }
            }
          } catch (e) {
            return;
          }
        }

        scrollController.addListener(listener);
        return () {
          scrollController.removeListener(listener);
        };
      },
      [],
    );
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: CarouselSlider.builder(
            controller: controller,
            initialPage: index + 1,
            onSlideChanged: (value) async {
              if (isNotScreen(value)) {
                Navigator.pop(context);
              }
              pageIndex.value = value;
            },
            slideTransform: const CubeTransform(),
            itemCount: storeList.length + 2,
            slideBuilder: (index) {
              if (isNotScreen(index)) {
                return Container(
                  height: double.infinity,
                  color: Colors.black,
                );
              } else {
                return storeList.isEmpty
                    ? Container()
                    : OnSwiper(
                        storeData: storeList[index - 1],
                        controller: scrollController,
                        onNext: () {
                          moveAnimation();
                          controller.nextPage(
                            const Duration(milliseconds: 300),
                          );
                        },
                        onBack: () {
                          if (index != 1) {
                            moveAnimation();
                            controller.previousPage(
                              const Duration(milliseconds: 300),
                            );
                          }
                        },
                      );
              }
            },
          ),
        ),
        Visibility(
          visible: isMove.value,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black.withOpacity(0),
          ),
        ),
      ],
    );
  }
}
