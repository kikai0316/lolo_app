import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';

Widget loadinPage({
  required BuildContext context,
  required bool isLoading,
  required String? text,
}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Visibility(
    visible: isLoading,
    child: Container(
      alignment: Alignment.center,
      color: Colors.black.withOpacity(0.7),
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
            color: Colors.white,
            radius: safeAreaHeight * 0.018,
          ),
          if (text != null) ...{
            Padding(
              padding: EdgeInsets.only(top: safeAreaHeight * 0.01),
              child: nText(
                text,
                color: Colors.white,
                fontSize: safeAreaWidth / 30,
                bold: 600,
              ),
            ),
          },
        ],
      ),
    ),
  );
}

class WithIconInLoadingPage extends HookConsumerWidget {
  const WithIconInLoadingPage({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);

    return Container(
      alignment: Alignment.center,
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Container(
          //   height: safeAreaHeight * 0.1,
          //   width: safeAreaHeight * 0.3,
          //   decoration: BoxDecoration(image: appLogoImg()),
          // ),
          Padding(
            padding: EdgeInsets.only(top: safeAreaHeight * 0.02),
            child: CupertinoActivityIndicator(
              color: Colors.white,
              radius: safeAreaHeight * 0.018,
            ),
          ),
        ],
      ),
    );
  }
}
