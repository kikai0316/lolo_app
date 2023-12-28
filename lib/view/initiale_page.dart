import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/view/account.dart';
import 'package:lolo_app/view/home.dart';
import 'package:lolo_app/view/search.dart';
import 'package:lolo_app/view/store.dart';
import 'package:lolo_app/view_model/loading.dart';
import 'package:lolo_app/view_model/page_index.dart';
import 'package:lolo_app/view_model/user_data.dart';

GlobalKey<CurvedNavigationBarState> bottomNavigationKey = GlobalKey();

class InitialPage extends HookConsumerWidget {
  const InitialPage({super.key, required this.locationData});
  final Position locationData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final userDataNotifier = ref.watch(userDataNotifierProvider);
    final pageIndexNotifier = ref.watch(pageIndexNotifierProvider);
    final loadingNotifier = ref.watch(loadingNotifierProvider);
    final int? pageIndexNotifierWhen = pageIndexNotifier.when(
        data: (value) => value, error: (e, s) => 0, loading: () => null);
    if (pageIndexNotifierWhen != null) {
      return userDataNotifier.when(
          data: (value) => value != null
              ? Stack(
                  children: [
                    Scaffold(
                      backgroundColor: Colors.black,
                      body: [
                        HomePage2(
                          locationData: locationData,
                          userData: value,
                        ),
                        SearchPage(
                          locationData: locationData,
                        ),
                        AccountPage(
                          userData: value,
                        ),
                        value.storeData != null
                            ? StorePage(storeData: value.storeData!)
                            : const SizedBox()
                      ][pageIndexNotifierWhen],
                      bottomNavigationBar: CurvedNavigationBar(
                        animationDuration: const Duration(milliseconds: 200),
                        backgroundColor: Colors.transparent,
                        buttonBackgroundColor: blueColor2,
                        color: blackColor,
                        index: pageIndexNotifierWhen,
                        key: bottomNavigationKey,
                        items: <Widget>[
                          for (int i = 0; i < 3; i++) ...{
                            bottomNavigationIcon(
                              context,
                              pageIndex: i,
                            ),
                          },
                          if (value.storeData != null)
                            SizedBox(
                              height: safeAreaWidth * 0.08,
                              width: safeAreaWidth * 0.08,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.5)),
                                  image: DecorationImage(
                                      image:
                                          MemoryImage(value.storeData!.logo!),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                        ],
                        onTap: (index) {
                          final notifier =
                              ref.read(pageIndexNotifierProvider.notifier);
                          notifier.upData(index);
                        },
                      ),
                    ),
                    loadinPage(
                        context: context,
                        isLoading: loadingNotifier.when(
                            data: (value) => value,
                            error: (e, s) => false,
                            loading: () => false),
                        text: null)
                  ],
                )
              : const SizedBox(),
          error: (e, s) => const SizedBox(),
          loading: () => const WithIconInLoadingPage());
    } else {
      return loadinPage(context: context, isLoading: true, text: null);
    }
  }

  Widget bottomNavigationIcon(
    BuildContext context, {
    required int pageIndex,
  }) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final fileList = [
      "assets/img/home_icon.png",
      "assets/img/search_icon.png",
      "assets/img/user_icon.png",
    ];
    return SizedBox(
      height: safeAreaWidth * 0.08,
      width: safeAreaWidth * 0.08,
      child: Padding(
        padding: EdgeInsets.all(pageIndex == 0 ? safeAreaWidth * 0.01 : 0),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(fileList[pageIndex]), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
