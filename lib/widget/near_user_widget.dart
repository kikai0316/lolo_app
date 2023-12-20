import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';
import 'package:lolo_app/utility/utility.dart';

Widget nearbyStartWidget(
  BuildContext context,
) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  InlineSpan textWidget(
    String text,
  ) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: "Normal",
        fontVariations: const [FontVariation("wght", 700)],
        color: text == "ON" ? greenColor : Colors.white.withOpacity(0.7),
        fontSize: safeAreaWidth / 27,
      ),
    );
  }

  return Padding(
    padding: EdgeInsets.only(
      left: safeAreaWidth * 0.03,
      right: safeAreaWidth * 0.03,
    ),
    child: Container(
      width: safeAreaWidth,
      decoration: BoxDecoration(
        color: whiteColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: safeAreaWidth * 0.04),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  textWidget("端末の設定からローカルネットワークを\n「 "),
                  textWidget("ON"),
                  textWidget(" 」にしてください。"),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(safeAreaWidth * 0.04),
            child: Opacity(
              opacity: 0.9,
              child: Container(
                alignment: Alignment.center,
                height: safeAreaHeight * 0.06,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: safeAreaWidth * 0.03,
                    right: safeAreaWidth * 0.03,
                  ),
                  child: Container(
                    height: safeAreaHeight * 0.05,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/img/setting.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget myDataWidget(BuildContext context, UserData? userData) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Container(
    height: safeAreaWidth * 0.2,
    width: safeAreaWidth * 0.2,
    decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1.0,
          )
        ],
        shape: BoxShape.circle,
        image: userData?.img != null
            ? DecorationImage(
                image: MemoryImage(userData!.img!), fit: BoxFit.cover)
            : notImg()),
  );
}

class OnUser extends HookConsumerWidget {
  const OnUser({super.key, required this.id, required this.onTap});
  final String id;
  final void Function(UserData) onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    final userData = useState<UserData?>(null);
    useEffect(() {
      Future(() async {
        final getData = await userDataGet(id);
        if (getData != null && context.mounted) {
          userData.value = getData;
        }
      });
      return null;
    }, []);
    return SizedBox(
      width: safeAreaWidth * 0.25,
      child: userData.value != null
          ? Column(
              children: [
                GestureDetector(
                  onTap: () => onTap(userData.value!),
                  child: Container(
                    alignment: Alignment.bottomRight,
                    height: safeAreaWidth * 0.2,
                    width: safeAreaWidth * 0.2,
                    decoration: BoxDecoration(
                      image: userData.value!.img != null
                          ? DecorationImage(
                              image: MemoryImage(userData.value!.img!),
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
                    child: Container(
                      alignment: Alignment.center,
                      height: safeAreaWidth * 0.06,
                      width: safeAreaWidth * 0.06,
                      decoration: BoxDecoration(
                        color: greenColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: greenColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: safeAreaHeight * 0.01),
                  child: nText(userData.value!.name,
                      color: Colors.white,
                      fontSize: safeAreaWidth / 35,
                      bold: 700),
                )
              ],
            )
          : const SizedBox(),
    );
  }
}
