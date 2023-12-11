import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:permission_handler/permission_handler.dart';

class NotLocationPermissionPage extends HookConsumerWidget {
  const NotLocationPermissionPage({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;

    final List<String> message = [
      "「設定画面へ」ボタンをタップ",
      "「位置情報」を選択",
      "「このAppの使用中」を選択",
      "　アプリを再起動"
    ];

    return Scaffold(
      backgroundColor: blackColor,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: safeAreaHeight * 0.06,
                      bottom: safeAreaHeight * 0.06,
                    ),
                    child: nText(
                      "位置情報への\nアクセスの許可が必要です",
                      color: Colors.white,
                      fontSize: safeAreaWidth / 15,
                      bold: 700,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: safeAreaHeight * 0.06,
                      bottom: safeAreaHeight * 0.06,
                    ),
                    child: nText(
                      "以下の手順に従って設定を変更してください",
                      color: Colors.grey,
                      fontSize: safeAreaWidth / 25,
                      bold: 700,
                    ),
                  ),
                  for (int i = 0; i < 4; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: safeAreaHeight * 0.02,
                        left: safeAreaWidth * 0.07,
                      ),
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: safeAreaWidth * 0.11,
                            width: safeAreaWidth * 0.11,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                                color: blackColor,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                    spreadRadius: 3.0,
                                  )
                                ]),
                            child: nText((i + 1).toString(),
                                color: Colors.white,
                                fontSize: safeAreaWidth / 15,
                                bold: 700),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: safeAreaWidth * 0.05),
                            child: nText(message[i],
                                color: i == 3 ? Colors.red : Colors.white,
                                fontSize: safeAreaWidth / 25,
                                bold: 700),
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: bottomButton(
                context: context,
                isWhiteMainColor: true,
                text: "設定画面へ",
                onTap: () => openAppSettings(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
