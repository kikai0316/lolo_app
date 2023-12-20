import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/utility.dart';
import 'dart:ui' as ui;

class MessageBottomSheet extends HookConsumerWidget {
  const MessageBottomSheet({
    super.key,
    required this.userData,
  });
  final UserData userData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final textValue = useState<String>("");

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0),
        body: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
          ),
          child: SizedBox(
            height: safeAreaHeight * 1,
            width: safeAreaWidth * 1,
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: safeAreaHeight * 0.1),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.bottomRight,
                            height: safeAreaWidth * 0.2,
                            width: safeAreaWidth * 0.2,
                            decoration: BoxDecoration(
                              image: userData.img != null
                                  ? DecorationImage(
                                      image: MemoryImage(userData.img!),
                                      fit: BoxFit.cover)
                                  : notImg(),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1.0,
                                )
                              ],
                              shape: BoxShape.circle,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: safeAreaHeight * 0.01),
                            child: nText(userData.name,
                                color: Colors.white,
                                fontSize: safeAreaWidth / 25,
                                bold: 700),
                          )
                        ],
                      ),
                    )),
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: safeAreaHeight * 0.08,
                          left: safeAreaWidth * 0.03),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          alignment: Alignment.center,
                          height: safeAreaWidth * 0.13,
                          width: safeAreaWidth * 0.13,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: safeAreaWidth / 10,
                          ),
                        ),
                      ),
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: safeAreaWidth * 0.08,
                            bottom: safeAreaHeight * 0.01),
                        child: nText("${textValue.value.length}/7",
                            color: textValue.value.length > 7
                                ? Colors.red
                                : greenColor,
                            fontSize: safeAreaWidth / 25,
                            bold: 700),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: safeAreaHeight * 0.02,
                      ),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: safeAreaHeight * 0.17,
                        ),
                        width: safeAreaWidth * 0.95,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 0.5),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: safeAreaWidth * 0.05,
                            right: safeAreaWidth * 0.05,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  // autofocus: true,
                                  onChanged: (text) {
                                    textValue.value = text;
                                  },
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: "Normal",
                                    fontVariations: const [
                                      FontVariation("wght", 400),
                                    ],
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: safeAreaWidth / 25,
                                  ),
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: "メッセージを送信...",
                                    hintStyle: TextStyle(
                                      fontFamily: "Normal",
                                      fontVariations: const [
                                        FontVariation("wght", 700),
                                      ],
                                      color: Colors.white,
                                      fontSize: safeAreaWidth / 28,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: safeAreaHeight * 0.013,
                                    left: safeAreaWidth * 0.02,
                                  ),
                                  child: nText(
                                    "送信",
                                    color: blueColor,
                                    fontSize: safeAreaWidth / 22,
                                    bold: 700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
