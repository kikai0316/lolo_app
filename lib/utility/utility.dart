import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/view/home.dart';
import 'package:lolo_app/view/location_request.dart';
import 'package:lolo_app/view/not_data/not_birthday_page.dart';
import 'package:lolo_app/view/not_data/not_img_page.dart';
import 'package:lolo_app/view/not_data/not_name_page.dart';
import 'package:lolo_app/view/not_data/not_permission_page.dart';
import 'package:url_launcher/url_launcher.dart';

double safeHeight(BuildContext context) {
  return MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top -
      MediaQuery.of(context).padding.bottom;
}

Future openURL({required String url, required void Function()? onError}) async {
  final Uri setURL = Uri.parse(url);
  if (await canLaunchUrl(setURL)) {
    await launchUrl(setURL, mode: LaunchMode.inAppWebView);
  } else {
    if (onError != null) {
      onError();
    }
  }
}

void bottomSheet(
  BuildContext context, {
  required Widget page,
  required bool isBackgroundColor,
  required bool isPOP,
}) {
  showModalBottomSheet<Widget>(
    isScrollControlled: true,
    isDismissible: isPOP,
    enableDrag: isPOP,
    context: context,
    elevation: 0,
    backgroundColor: isBackgroundColor ? Colors.white : Colors.transparent,
    shape: isBackgroundColor
        ? const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(15),
              topStart: Radius.circular(15),
            ),
          )
        : null,
    builder: (context) => page,
  );
}

EdgeInsetsGeometry xPadding(
  BuildContext context,
) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return EdgeInsets.only(
    left: safeAreaWidth * 0.03,
    right: safeAreaWidth * 0.03,
  );
}

Widget? nextScreenWhisUserDataCheck(UserData userData) {
  return userData.name.isEmpty
      ? NotNamePage(
          userData: userData,
        )
      : userData.birthday.isEmpty
          ? NotBirthdayPage(
              userData: userData,
            )
          : userData.img == null
              ? NotImgPage(
                  userData: userData,
                )
              : null;
}

Future getMobileImage({
  required void Function(Uint8List) onSuccess,
  required void Function() onError,
}) async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final List<int> imageBytes = await File(pickedFile.path).readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      final Uint8List unit8 = base64Decode(base64Image);
      onSuccess(unit8);
    }
  } catch (e) {
    onError();
  }
}

Future<Widget> nextScreenWithLocationCheck(UserData userData) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return const NotLocationPermissionPage();
  }

  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return const NotLocationPermissionPage();
  }

  if (permission == LocationPermission.denied) {
    return RequestLocationsPage(userData: userData);
  }

  final currentPosition = await Geolocator.getCurrentPosition();
  return HomePage(userData: userData, locationData: currentPosition);
}
