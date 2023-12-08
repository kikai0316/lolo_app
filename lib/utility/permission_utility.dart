// import 'package:flutter/widgets.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:lolo_app/model/user_data.dart';
// import 'package:lolo_app/view/home.dart';
// import 'package:lolo_app/view/location_request.dart';
// import 'package:lolo_app/view/not_data/not_permission_page.dart';
// import 'package:permission_handler/permission_handler.dart';

// Future<bool> hasLocationPermission() async {
//   final status = await Permission.locationWhenInUse.status;
//   if (status.isGranted) {
//     return true;
//   } else if (status.isDenied) {
//     return false;
//   } else if (status.isPermanentlyDenied) {
//     return true;
//   }
//   return false;
// }

// Future<Widget> nextScreenWhisLocationCheck(UserData userData) async {
//   final isPermission = await hasLocationPermission();
//   if (isPermission) {
//     final isCheck = await checkLocation();
//     if (isCheck) {
//       final currentPosition = await Geolocator.getCurrentPosition();
//       return HomePage(userData: userData, myLocation: currentPosition);
//     } else {
//       return const NotLocationPermissionPage();
//     }
//   } else {
//     return RequestLocationsPage(userData: userData);
//   }
// }

// Future<bool> checkLocation() async {
//   bool serviceEnabled;
//   LocationPermission permission;
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return false;
//   }
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       return false;
//     }
//   }
//   if (permission == LocationPermission.deniedForever) {
//     return false;
//   }
//   return true;
// }
