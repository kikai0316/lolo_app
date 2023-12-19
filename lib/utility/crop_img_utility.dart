import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

Future<Uint8List?> cropLogoImg(Uint8List img) async {
  final directory = await getApplicationDocumentsDirectory();
  final imagePath = '${directory.path}/temp_image.png';
  File file = File(imagePath);
  await file.writeAsBytes(img);
  ImageCropper cropper = ImageCropper();
  CroppedFile? croppedFile = await cropper.cropImage(
    sourcePath: file.path,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
    ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'ロゴ画像画像',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
          title: 'ロゴ画像画像',
          rectX: 50,
          rectY: 50,
          rectWidth: 5000,
          rectHeight: 5000,
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          doneButtonTitle: "完了",
          cancelButtonTitle: "キャンセル")
    ],
  );

  if (croppedFile != null) {
    file = File(croppedFile.path); // CroppedFile を File に変換
    Uint8List croppedImage = await file.readAsBytes();
    return croppedImage;
  } else {
    return null;
  }
}

Future<Uint8List?> cropEventImg(Uint8List img) async {
  final directory = await getApplicationDocumentsDirectory();
  final imagePath = '${directory.path}/temp_image.png';
  File file = File(imagePath);
  await file.writeAsBytes(img);
  ImageCropper cropper = ImageCropper();
  CroppedFile? croppedFile = await cropper.cropImage(
    sourcePath: file.path,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
    ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'イベント画像',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
          title: 'イベント画像',
          rectX: 50,
          rectY: 50,
          rectWidth: 5000,
          rectHeight: 2813,
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          doneButtonTitle: "完了",
          cancelButtonTitle: "キャンセル")
    ],
  );

  if (croppedFile != null) {
    file = File(croppedFile.path); // CroppedFile を File に変換
    Uint8List croppedImage = await file.readAsBytes();
    return croppedImage;
  } else {
    return null;
  }
}
