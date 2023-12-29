import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/app_widget.dart';

// Widget artistWidget(BuildContext context, String name) {
//   final safeAreaHeight = safeHeight(context);
//   final safeAreaWidth = MediaQuery.of(context).size.width;
//   return Padding(
//     padding: EdgeInsets.all(safeAreaWidth * 0.02),
//     child: SizedBox(
//       width: safeAreaHeight * 0.17,
//       height: safeAreaHeight * 0.16,
//       child: Stack(
//         alignment: Alignment.topCenter,
//         children: [
//           Container(
//             height: safeAreaHeight * 0.15,
//             width: safeAreaHeight * 0.15,
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: Colors.grey.withOpacity(0.6),
//               ),
//               image: const DecorationImage(
//                   image: NetworkImage(
//                       "https://i.pinimg.com/474x/b7/e7/0f/b7e70faf448926495a477693947b30b4.jpg"),
//                   fit: BoxFit.cover),
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: EdgeInsets.only(
//                   right: safeAreaWidth * 0.01, left: safeAreaWidth * 0.01),
//               child: Container(
//                 alignment: Alignment.centerLeft,
//                 height: safeAreaHeight * 0.03,
//                 decoration: const BoxDecoration(boxShadow: [
//                   BoxShadow(
//                     color: Colors.black,
//                     blurRadius: 10,
//                     spreadRadius: 1.0,
//                   )
//                 ]),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: FittedBox(
//               fit: BoxFit.fitWidth,
//               child: nText("DJ MAGIC",
//                   color: Colors.white, fontSize: safeAreaWidth / 20, bold: 700),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }

Widget searchTextFiled(BuildContext context,
    {required TextEditingController? textController,
    required void Function(String)? onFieldSubmitted,
    required Function(String)? onChanged,
    required void Function()? deleteOnTap,
    required bool isFocus}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Container(
    height: safeAreaHeight * 0.055,
    decoration: BoxDecoration(
      color: blackColor,
      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        SizedBox(
          height: safeAreaHeight * 0.06,
          width: safeAreaHeight * 0.06,
          child: imgIcon(
              file: "assets/img/search_icon.png",
              padding: safeAreaWidth * 0.028),
        ),
        Expanded(
          child: TextFormField(
            controller: textController,
            autofocus: isFocus,
            textAlign: TextAlign.left,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: onFieldSubmitted,
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: "Normal",
              fontVariations: const [
                FontVariation("wght", 400),
              ],
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: safeAreaWidth / 27,
            ),
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: "店舗名を入力...",
              hintStyle: TextStyle(
                fontFamily: "Normal",
                fontVariations: const [
                  FontVariation("wght", 300),
                ],
                color: Colors.grey.withOpacity(0.5),
                fontSize: safeAreaWidth / 27,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: deleteOnTap,
          child: Container(
              alignment: Alignment.center,
              height: safeAreaHeight * 0.06,
              width: safeAreaHeight * 0.06,
              color: Colors.transparent,
              child: deleteOnTap == null
                  ? null
                  : Icon(
                      Icons.close,
                      size: safeAreaWidth / 15,
                      color: Colors.grey,
                    )),
        ),
      ],
    ),
  );
}

Widget searchTitleWithCircle(BuildContext context, String title) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Padding(
    padding: EdgeInsets.only(
        left: safeAreaWidth * 0.03,
        top: safeAreaHeight * 0.03,
        bottom: safeAreaHeight * 0.005),
    child: titleWithCircle(context, title),
  );
}
