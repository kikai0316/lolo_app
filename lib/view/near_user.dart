import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/near_user/message_sheet.dart';
import 'package:lolo_app/view_model/device_list.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/near_user_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class NearUserPage extends HookConsumerWidget {
  const NearUserPage({super.key, required this.userData});
  final UserData userData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    final deviceList = ref.watch(deviseListNotifierProvider);
    final List<String>? deviceListWhen = deviceList.when(
        data: (data) => data, error: (e, s) => [], loading: () => []);

    useEffect(() {
      final notifier = ref.read(deviseListNotifierProvider.notifier);
      return () {
        notifier.resetData();
      };
    }, []);

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: [
            blueColor2,
            blackColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.all(safeAreaWidth * 0.15),
              child: Opacity(
                  opacity: 0.3,
                  child: deviceListWhen != null
                      ? Container(
                          alignment: Alignment.center,
                          height: safeAreaWidth * 0.15,
                          width: safeAreaWidth * 0.15,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/img/radar.gif"),
                                fit: BoxFit.cover),
                          ),
                        )
                      : null),
            ),
          ),
          Scaffold(
            extendBody: true,
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: appBar(context, "", false),
            body: Column(
              children: [
                Container(
                  height: safeAreaHeight * 0.3,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      nText("半径20m以内の",
                          color: Colors.white,
                          fontSize: safeAreaWidth / 15,
                          bold: 700),
                      Padding(
                        padding: EdgeInsets.all(safeAreaHeight * 0.02),
                        child: nText("この画面を開いている",
                            color: Colors.white.withOpacity(0.5),
                            fontSize: safeAreaWidth / 15,
                            bold: 700),
                      ),
                      nText("ユーザーが表示されます",
                          color: Colors.white,
                          fontSize: safeAreaWidth / 15,
                          bold: 700)
                    ],
                  ),
                ),
                if (deviceListWhen != null) ...{
                  Padding(
                      padding: EdgeInsets.only(
                          top: safeAreaHeight * 0.1,
                          bottom: safeAreaHeight * 0.03),
                      child: nText(
                          deviceListWhen.isEmpty
                              ? "付近にユーザーがいません。"
                              : "付近に${deviceListWhen.length}人のユーザーがいます",
                          color: Colors.grey,
                          fontSize: safeAreaWidth / 25,
                          bold: 700)),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: safeAreaWidth,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: safeAreaWidth * 0.01,
                          ),
                          OnUser(
                            id: userData.id,
                            onTap: (value) => bottomSheet(context,
                                page: MessageBottomSheet(userData: value),
                                isBackgroundColor: false),
                          ),
                          for (int i = 0; i < deviceListWhen.length; i++) ...{
                            OnUser(
                              onTap: (value) => bottomSheet(context,
                                  page: MessageBottomSheet(userData: value),
                                  isBackgroundColor: false),
                              id: deviceListWhen[i],
                            )
                          }
                        ],
                      ),
                    ),
                  )
                }
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (deviceListWhen == null) ...{
                    nearbyStartWidget(
                      context,
                    ),
                    Padding(
                      padding: EdgeInsets.all(safeAreaWidth * 0.03),
                      child: GestureDetector(
                        onTap: () => openAppSettings(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            nText("設定を開く",
                                color: blueColor,
                                fontSize: safeAreaWidth / 30,
                                bold: 700),
                            Icon(
                              Icons.launch,
                              color: blueColor,
                              size: safeAreaWidth / 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                    shadowButton(context, text: "周囲との接続を開始", onTap: () {
                      final notifier =
                          ref.read(deviseListNotifierProvider.notifier);
                      notifier.initNearbyService(userData);
                    })
                  } else ...{
                    Material(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: () {
                          final notifier =
                              ref.read(deviseListNotifierProvider.notifier);
                          notifier.resetData();
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          alignment: Alignment.center,
                          height: safeAreaHeight * 0.065,
                          width: safeAreaWidth * 0.95,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: nText(
                            "接続を停止",
                            color: Colors.white,
                            fontSize: safeAreaWidth / 27,
                            bold: 700,
                          ),
                        ),
                      ),
                    ),
                  }
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
