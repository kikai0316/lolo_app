import 'package:flutter/material.dart';

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
