import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/view/account.dart';
import 'package:lolo_app/view/home.dart';
import 'package:lolo_app/view/search.dart';
import 'package:lolo_app/view_model/user_data.dart';

GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

class InitialPage extends HookConsumerWidget {
  const InitialPage({super.key, required this.locationData});
  final Position locationData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = useState<int>(0);
    final userDataNotifier = ref.watch(userDataNotifierProvider);

    return userDataNotifier.when(
        data: (value) => value != null
            ? Scaffold(
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
                  )
                ][pageIndex.value],
                bottomNavigationBar: CurvedNavigationBar(
                  animationDuration: const Duration(milliseconds: 200),
                  backgroundColor: Colors.transparent,
                  buttonBackgroundColor: blueColor2,
                  color: blackColor,
                  key: _bottomNavigationKey,
                  items: <Widget>[
                    for (int i = 0; i < 3; i++) ...{
                      bottomNavigationIcon(
                        context,
                        pageIndex: i,
                      ),
                    }
                  ],
                  onTap: (index) {
                    pageIndex.value = index;
                  },
                ),
              )
            : const SizedBox(),
        error: (e, s) => const SizedBox(),
        loading: () => const WithIconInLoadingPage());
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
