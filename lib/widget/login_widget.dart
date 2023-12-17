import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';

Widget privacyText({
  required BuildContext context,
  required void Function()? onTap1,
  required void Function()? onTap2,
}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  InlineSpan textWidget(
    String text, {
    required bool isBlue,
    required GestureRecognizer? onTap,
  }) {
    return TextSpan(
      text: text,
      recognizer: onTap,
      style: TextStyle(
        fontFamily: "Normal",
        fontVariations: const [FontVariation("wght", 400)],
        color: isBlue ? blueColor : Colors.white,
        fontSize: safeAreaWidth / 35,
        decoration: isBlue ? TextDecoration.underline : null,
      ),
    );
  }

  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      children: [
        textWidget('ログインすると、あなたは当アプリの', isBlue: false, onTap: null),
        textWidget(
          '利用規約',
          isBlue: true,
          onTap: TapGestureRecognizer()..onTap = onTap1,
        ),
        textWidget(
          'に同意することになります。当社における個人情報の取り扱いについては、',
          isBlue: false,
          onTap: null,
        ),
        textWidget(
          'プライバシーポリシー',
          isBlue: true,
          onTap: TapGestureRecognizer()..onTap = onTap2,
        ),
        textWidget('をご覧ください。', isBlue: false, onTap: null),
      ],
    ),
  );
}

PreferredSizeWidget? loginSheetAppBar(BuildContext context, String title) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    backgroundColor: Colors.white,
    title: Stack(
      alignment: Alignment.center,
      children: [
        nText(
          title,
          color: Colors.black,
          fontSize: safeAreaWidth / 16,
          bold: 700,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.close,
              color: Colors.black,
              size: safeAreaWidth / 13,
            ),
          ),
        ),
      ],
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
  );
}

class LoginTextField extends HookConsumerWidget {
  const LoginTextField({
    super.key,
    required this.subText,
    required this.isPassword,
    required this.controller,
    required this.icon,
    required this.isError,
    required this.onChanged,
  });
  final String subText;
  final bool isPassword;
  final bool isError;
  final TextEditingController? controller;
  final IconData icon;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isChange = useState<bool>(true);
    return Container(
      width: safeAreaWidth * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: isError ? Colors.red : Colors.grey),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: xPadding(context),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: safeAreaWidth * 0.03,
                left: safeAreaWidth * 0.02,
              ),
              child: Icon(
                icon,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                onChanged: onChanged,
                // ignore: avoid_bool_literals_in_conditional_expressions
                obscureText: isPassword ? isChange.value : false,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: "Normal",
                  fontVariations: const [FontVariation("wght", 400)],
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: safeAreaWidth / 28,
                ),
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: subText,
                  hintStyle: TextStyle(
                    fontFamily: "Normal",
                    fontVariations: const [FontVariation("wght", 400)],
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: safeAreaWidth / 34,
                  ),
                ),
              ),
            ),
            if (isPassword)
              Padding(
                padding: EdgeInsets.only(
                  right: safeAreaWidth * 0.01,
                  left: safeAreaWidth * 0.01,
                ),
                child: GestureDetector(
                  onTap: () => isChange.value = !isChange.value,
                  child: Icon(
                    isChange.value ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                    size: safeAreaWidth / 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StoreSettelingTextField extends HookConsumerWidget {
  const StoreSettelingTextField({
    super.key,
    required this.subText,
    required this.controller,
    required this.title,
    required this.isError,
    required this.onChanged,
  });
  final String subText;
  final bool isError;
  final TextEditingController? controller;
  final String title;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return Container(
      width: safeAreaWidth * 0.95,
      decoration: BoxDecoration(
        border: isError ? Border.all(color: Colors.red) : null,
        color: blackColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: xPadding(context),
        child: Row(
          children: [
            Padding(
                padding: EdgeInsets.only(
                  right: safeAreaWidth * 0.01,
                  left: safeAreaWidth * 0.02,
                ),
                child: nText(title,
                    color: Colors.white,
                    fontSize: safeAreaWidth / 27,
                    bold: 700)),
            Expanded(
              child: TextFormField(
                controller: controller,
                onChanged: onChanged,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: "Normal",
                  fontVariations: const [FontVariation("wght", 400)],
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: safeAreaWidth / 28,
                ),
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: subText,
                  hintStyle: TextStyle(
                    fontFamily: "Normal",
                    fontVariations: const [FontVariation("wght", 400)],
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: safeAreaWidth / 34,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GeoPositionWidget extends HookConsumerWidget {
  const GeoPositionWidget({
    super.key,
    required this.onTap,
    required this.removeOnTap,
    required this.locationData,
  });
  final void Function(List<double>)? onTap;
  final void Function()? removeOnTap;
  final List<double>? locationData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final initLocationData = locationData ?? [35.6764, 139.6500];
    final geo = useState<List<double>>([...initLocationData]);
    return GestureDetector(
      onTap: removeOnTap,
      child: Container(
        alignment: Alignment.center,
        height: double.infinity,
        width: double.infinity,
        color: Colors.black.withOpacity(0.8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: safeAreaHeight * 0.03),
                    child: nText(
                      "正確な座標を指定してください",
                      color: Colors.white,
                      fontSize: safeAreaWidth / 20,
                      bold: 700,
                    ),
                  ),
                  SizedBox(
                    height: safeAreaHeight * 0.7,
                    width: safeAreaWidth * 0.9,
                    child: GoogleMap(
                      myLocationButtonEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target:
                            LatLng(initLocationData[0], initLocationData[1]),
                        zoom: 19,
                      ),
                      onCameraMove: (CameraPosition position) {
                        geo.value = [
                          position.target.latitude,
                          position.target.longitude
                        ];
                      },
                      onTap: (LatLng i) {}, //マップを押したら検知する。
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: safeAreaHeight * 0.02),
                    child: bottomButton(
                      context: context,
                      isWhiteMainColor: true,
                      text: "確定",
                      onTap: () {
                        onTap!(geo.value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(safeAreaWidth * 0.03),
                  child: GestureDetector(
                    onTap: removeOnTap,
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: safeAreaWidth / 12,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              child: SizedBox(
                height: safeAreaHeight * 0.2,
                width: safeAreaHeight * 0.2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: safeAreaHeight * 0.2,
                      width: safeAreaHeight * 0.002,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    Container(
                      height: safeAreaHeight * 0.002,
                      width: safeAreaHeight * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
