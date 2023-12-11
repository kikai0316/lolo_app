import 'package:flutter/material.dart';

final areaImgList = [
  "assets/img/area_1.png",
  "assets/img/area_7.png",
  "assets/img/area_10.png",
  "assets/img/area_4.png",
  "assets/img/area_5.png",
  "assets/img/area_6.png",
  "assets/img/area_8.png",
  "assets/img/area_9.png",
  "assets/img/area_2.png",
  "assets/img/area_3.png",
];
DecorationImage notImg() {
  return const DecorationImage(
    image: AssetImage("assets/img/not.png"),
    fit: BoxFit.cover,
  );
}

Widget imgIcon({required String file, required double padding}) {
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(file), fit: BoxFit.cover),
      ),
    ),
  );
}
