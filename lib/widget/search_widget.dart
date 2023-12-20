import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/utility.dart';
import 'dart:ui' as ui;

Widget areaWidget(BuildContext context,
    {required int index, required String name, required int itemCount}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Padding(
    padding: EdgeInsets.all(safeAreaWidth * 0.02),
    child: Container(
      height: safeAreaHeight * 0.09,
      width: safeAreaWidth * 0.35,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(areaImgList[index]), fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRect(
          child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 2,
          sigmaY: 2,
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(safeAreaWidth * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: nText(name,
                      color: Colors.white,
                      fontSize: safeAreaWidth / 20,
                      bold: 700),
                ),
                nText("$itemCount件",
                    color: Colors.white,
                    fontSize: safeAreaWidth / 30,
                    bold: 500),
              ],
            ),
          ),
        ),
      )),
    ),
  );
}

Widget  searchEventWidget(BuildContext context, String name) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Padding(
    padding: EdgeInsets.all(safeAreaWidth * 0.02),
    child: SizedBox(
      width: safeAreaWidth * 0.45,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.6),
                ),
                image: const DecorationImage(
                    image: NetworkImage(
                        "https://i.pinimg.com/564x/cc/00/24/cc0024a79bc48352591109167ce41faa.jpg"),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      height: safeAreaHeight * 0.04,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: safeAreaWidth * 0.03),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: nText(name,
                              color: Colors.white,
                              fontSize: safeAreaWidth / 30,
                              bold: 700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: safeAreaWidth * 0.02,
              ),
              child: nText("100m",
                  color: Colors.grey, fontSize: safeAreaWidth / 30, bold: 700),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget artistWidget(BuildContext context, String name) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Padding(
    padding: EdgeInsets.all(safeAreaWidth * 0.02),
    child: SizedBox(
      width: safeAreaHeight * 0.17,
      height: safeAreaHeight * 0.16,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: safeAreaHeight * 0.15,
            width: safeAreaHeight * 0.15,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.6),
              ),
              image: const DecorationImage(
                  image: NetworkImage(
                      "https://i.pinimg.com/474x/b7/e7/0f/b7e70faf448926495a477693947b30b4.jpg"),
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  right: safeAreaWidth * 0.01, left: safeAreaWidth * 0.01),
              child: Container(
                alignment: Alignment.centerLeft,
                height: safeAreaHeight * 0.03,
                decoration: const BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    spreadRadius: 1.0,
                  )
                ]),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: nText("DJ MAGIC",
                  color: Colors.white, fontSize: safeAreaWidth / 20, bold: 700),
            ),
          )
        ],
      ),
    ),
  );
}

Widget onWordSearchWidget(BuildContext context,
    {required StoreData storeData,
    required String distance,
    required int index,
    required void Function() onTap}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;

  return Padding(
    padding: EdgeInsets.only(top: safeAreaHeight * 0.02),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: safeAreaHeight * 0.08,
        width: safeAreaWidth * 0.95,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(areaImgList[index]), fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ClipRect(
            child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 6,
            sigmaY: 6,
          ),
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  left: safeAreaWidth * 0.04, right: safeAreaWidth * 0.03),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: nText(storeData.name,
                              color: Colors.white,
                              fontSize: safeAreaWidth / 20,
                              bold: 700),
                        ),
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: nText(storeData.address,
                              color: Colors.grey.withOpacity(0.5),
                              fontSize: safeAreaWidth / 35,
                              bold: 500),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                      width: safeAreaWidth * 0.2,
                      child: Stack(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(top: safeAreaHeight * 0.01),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: nText(
                                    getStoreStatus(storeData.businessHours),
                                    color: greenColor,
                                    fontSize: safeAreaWidth / 35,
                                    bold: 500),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(bottom: safeAreaHeight * 0.004),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: nText(distance,
                                    color: Colors.grey,
                                    fontSize: safeAreaWidth / 35,
                                    bold: 500),
                              ),
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        )),
      ),
    ),
  );
}

Widget searchTextFiled(BuildContext context,
    {required TextEditingController textController,
    required void Function(String)? onFieldSubmitted,
    required Function(String)? onChanged,
    required void Function()? deleteOnTap}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Container(
    height: safeAreaHeight * 0.06,
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
              fontSize: safeAreaWidth / 25,
            ),
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: "検索：店舗名、地名",
              hintStyle: TextStyle(
                fontFamily: "Normal",
                fontVariations: const [
                  FontVariation("wght", 300),
                ],
                color: Colors.grey.withOpacity(0.5),
                fontSize: safeAreaWidth / 25,
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

Widget eventDatetimeWidget(
  BuildContext context,
) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Container(
    height: safeAreaHeight * 0.5,
    width: safeAreaWidth * 0.8,
    decoration: BoxDecoration(
      color: blackColor,
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
