import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestLocationsPage extends HookConsumerWidget {
  const RequestLocationsPage({super.key, required this.userData});
  final UserData userData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: blackColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: safeAreaHeight * 0.08),
                      child: nText(
                        "位置情報へのアクセス\nを許可しますか？",
                        color: Colors.white,
                        fontSize: safeAreaWidth / 15,
                        bold: 500,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: safeAreaHeight * 0.07,
                        bottom: safeAreaHeight * 0.04,
                      ),
                      child: nText(
                        "アプリからより適切な情報を提供するために、\n位置情報へのアクセスを許可してください。",
                        color: Colors.grey,
                        fontSize: safeAreaWidth / 25,
                        bold: 500,
                      ),
                    ),
                    SizedBox(
                      height: safeAreaHeight * 0.36,
                      width: safeAreaWidth * 0.8,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: safeAreaHeight * 0.36,
                            width: safeAreaWidth * 0.8,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: safeAreaHeight * 0.15,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: nText(
                                    "LoLoに位置情報の使用を\n許可しますか？",
                                    color: blackColor.withOpacity(0.9),
                                    fontSize: safeAreaWidth / 23,
                                    bold: 700,
                                  ),
                                ),
                                for (int i = 0; i < 3; i++) ...{
                                  Container(
                                    alignment: Alignment.center,
                                    height: safeAreaHeight * 0.07,
                                    width: double.infinity,
                                    decoration: i == 2
                                        ? null
                                        : const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                    child: nText(
                                      i == 0 ? "一度だけ許可" : "許可しない",
                                      color: blueColor.withOpacity(0.4),
                                      fontSize: safeAreaWidth / 25,
                                      bold: 700,
                                    ),
                                  ),
                                }
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: safeAreaWidth * 0.03,
                                  left: safeAreaWidth * 0.03,
                                  bottom: safeAreaHeight * 0.065),
                              child: Container(
                                alignment: Alignment.center,
                                height: safeAreaHeight * 0.08,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: whiteColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: blueColor2.withOpacity(0.9),
                                      blurRadius: 20,
                                      spreadRadius: 10.0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      width: safeAreaWidth * 1,
                                      height: 0.5,
                                      color: Colors.grey,
                                    ),
                                    nText(
                                      "Appの使用中は許可",
                                      color: blueColor,
                                      fontSize: safeAreaWidth / 23,
                                      bold: 700,
                                    ),
                                    Container(
                                      width: safeAreaWidth * 1,
                                      height: 0.5,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: safeAreaHeight * 0.02,
                ),
                child: shadowButton(
                  context,
                  text: "通知をONにする",
                  onTap: () async {
                    await Permission.locationWhenInUse.request();
                    final nextScreenWithLocation =
                        await nextScreenWithLocationCheck(userData);
                    if (context.mounted) {
                      screenTransitionNormal(context, nextScreenWithLocation);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
