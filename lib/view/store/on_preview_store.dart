import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/view/swiper/on_swiper.dart';

class OnStorePreviewPage extends HookConsumerWidget {
  OnStorePreviewPage({
    super.key,
    required this.storeData,
  });
  final StoreData storeData;
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollBack = useState<double>(0);
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
    return OnSwiper(
        storeData: storeData,
        onNext: () {},
        onBack: () {},
        controller: scrollController);
  }
}
