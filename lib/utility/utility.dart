import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/view/home.dart';
import 'package:lolo_app/view/location_request.dart';
import 'package:lolo_app/view/not_data/not_birthday_page.dart';
import 'package:lolo_app/view/not_data/not_img_page.dart';
import 'package:lolo_app/view/not_data/not_name_page.dart';
import 'package:lolo_app/view/not_data/not_permission_page.dart';
import 'package:url_launcher/url_launcher.dart';

double safeHeight(BuildContext context) {
  if (context.mounted) {
    return MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
  } else {
    return 0;
  }
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
}) {
  showModalBottomSheet<Widget>(
    isScrollControlled: true,
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

Future<Widget> nextScreenWithLocationCheck(
  UserData userData,
) async {
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
  return HomePage(myId: userData.id, locationData: currentPosition);
}

void showAlertDialog(
  BuildContext context, {
  required void Function()? ontap,
  required String title,
  required String? subTitle,
  required String? buttonText,
}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  showDialog<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: nText(
        title,
        color: Colors.black,
        fontSize: safeAreaWidth / 25,
        bold: 700,
      ),
      content: subTitle != null
          ? Padding(
              padding: EdgeInsets.only(top: safeAreaHeight * 0.01),
              child: Text(
                subTitle,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontFamily: "Normal",
                  fontVariations: const [FontVariation("wght", 400)],
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w100,
                  fontSize: safeAreaWidth / 32,
                ),
              ),
            )
          : null,
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "キャンセル",
            style: TextStyle(fontSize: safeAreaWidth / 25),
          ),
        ),
        if (buttonText != null) ...{
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: ontap,
            child: Text(
              buttonText,
              style: TextStyle(fontSize: safeAreaWidth / 25),
            ),
          ),
        },
      ],
    ),
  );
}

String getStoreStatus(String businessHours) {
  DateTime now = DateTime.now();
  List<String> times = businessHours.split('@');
  List<String> openTimeParts = times[0].split(':');
  List<String> closeTimeParts = times[1].split(':');

  DateTime openTime = DateTime(now.year, now.month, now.day,
      int.parse(openTimeParts[0]), int.parse(openTimeParts[1]));
  DateTime closeTime = DateTime(now.year, now.month, now.day,
      int.parse(closeTimeParts[0]), int.parse(closeTimeParts[1]));

  if (closeTime.isBefore(openTime)) {
    closeTime = closeTime.add(const Duration(days: 1));
  }
  DateTime oneHourBeforeOpen = openTime.subtract(const Duration(hours: 1));
  if (now.isAfter(oneHourBeforeOpen) && now.isBefore(openTime)) {
    Duration remaining = openTime.difference(now);
    return '${remaining.inMinutes}分後に営業開始';
  } else if (now.isAfter(openTime) &&
      now.isBefore(closeTime.subtract(const Duration(minutes: 30)))) {
    return '営業中';
  } else if (now.isAfter(closeTime.subtract(const Duration(minutes: 30))) &&
      now.isBefore(closeTime)) {
    return 'まもなく営業終了（閉店時間まで残り30分）';
  } else {
    return '営業時間外';
  }
}

String calculateDistanceToString(LatLng location1, LatLng location2) {
  double toRadians(double degree) {
    return degree * pi / 180;
  }

  const double earthRadius = 6371.0; // 地球の半径（キロメートル）
  double lat1 = location1.latitude;
  double lon1 = location1.longitude;
  double lat2 = location2.latitude;
  double lon2 = location2.longitude;

  double dLat = toRadians(lat2 - lat1);
  double dLon = toRadians(lon2 - lon1);

  lat1 = toRadians(lat1);
  lat2 = toRadians(lat2);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distance = earthRadius * c;

  if (distance < 1) {
    int distanceInMeters = (distance * 1000).round();
    return "${(distanceInMeters / 10).round() * 10}m";
  } else {
    return "${(distance * 10).round() / 10.0}km";
  }
}

List<int> imgRandomIndex(int length) {
  final List<int> setList = [];
  final meinList = List.generate(10, (index) => index);
  for (int i = 0; i < (length ~/ 10); i++) {
    meinList.shuffle();
    setList.addAll(meinList);
  }
  while (meinList.length > (length - setList.length)) {
    meinList.removeLast();
  }
  setList.addAll(meinList);
  return setList;
}

Future<DateTime?> showCalendar(BuildContext context) async {
  final dataTime = await showDatePicker(
      context: context,
      locale: const Locale('ja', 'JP'),
      helpText: "日付を選択してください",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
                onPrimary: blackColor,
                onSurface: blueColor,
                primary: blueColor),
            dialogBackgroundColor: blackColor,
          ),
          child: child!,
        );
      });
  return dataTime;
}

String generateRandomString() {
  const String chars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  Random random = Random();

  return List.generate(15, (_) => chars[random.nextInt(chars.length)]).join();
}

List<EventType> filteredAndSortedEvents(List<EventType> data) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(days: 1));

  List<EventType> filteredEvents;
  if (now.hour < 10) {
    // 午前10時より前：昨日から今日以降までのデータを含める
    filteredEvents =
        data.where((event) => event.date.isAfter(yesterday)).toList();
  } else {
    // 午前10時以降：昨日のデータを含めず、今日以降のデータのみをフィルタリング
    filteredEvents = data
        .where((event) =>
            event.date.isAtSameMomentAs(today) || event.date.isAfter(today))
        .toList();
  }

  // 日付が近い順に並び替え
  filteredEvents.sort((a, b) => a.date.compareTo(b.date));
  return filteredEvents;
}

String toEvelntDateString(
  DateTime date,
) {
  final DateFormat formatter = DateFormat('y年M月d日（ E ）', 'ja_JP');
  return formatter.format(date);
}

String timeAgo(DateTime dateTime) {
  Duration difference = DateTime.now().difference(dateTime);
  int minutes = difference.inMinutes;
  int hours = difference.inHours;
  int days = difference.inDays;
  if (minutes < 1) {
    return 'たった今';
  } else if (minutes < 10) {
    return '$minutes分前';
  } else if (minutes < 60) {
    int roundedMinutes = (minutes / 10).round() * 10;
    return '$roundedMinutes分前';
  } else if (hours < 24) {
    return '$hours時間前';
  } else {
    return '$days日前';
  }
}

double calculateDistance(LatLng loc1, LatLng loc2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((loc2.latitude - loc1.latitude) * p) / 2 +
      cos(loc1.latitude * p) *
          cos(loc2.latitude * p) *
          (1 - cos((loc2.longitude - loc1.longitude) * p)) /
          2;
  return 12742 * asin(sqrt(a));
}
