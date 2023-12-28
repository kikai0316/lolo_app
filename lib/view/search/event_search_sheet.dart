import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';

class EventSearchSheetWidget extends HookConsumerWidget {
  const EventSearchSheetWidget(
      {super.key, required this.dateTime, required this.onSearch});
  final DateTime dateTime;
  final void Function(LatLng)? onSearch;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final formattedDate = DateFormat('yyyy年MM月dd日').format(dateTime);

    return Container(
        height: safeAreaHeight * 0.8,
        decoration: const BoxDecoration(
          color: blackColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(safeAreaWidth * 0.03),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: textButton(
                  text: "とじる",
                  size: safeAreaWidth / 25,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: safeAreaWidth * 0.01,
                ),
                child: Container(
                  width: safeAreaWidth * 1,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: nText("”$formattedDate”での検索結果",
                        color: Colors.white,
                        fontSize: safeAreaWidth / 18,
                        bold: 700),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: safeAreaHeight * 0.03),
                child: nText("指定された日付では、見つかりませんでした",
                    color: Colors.grey,
                    fontSize: safeAreaWidth / 25,
                    bold: 500),
              ),
            ],
          ),
        ));
  }
}
