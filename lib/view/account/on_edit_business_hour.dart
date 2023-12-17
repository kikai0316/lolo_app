import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';

class BusinessHourEditSheet extends HookConsumerWidget {
  const BusinessHourEditSheet({
    super.key,
    required this.initData,
    required this.onTap,
  });

  final String initData;
  final void Function(String)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final editBusinessHour = useState<String>(initData);
    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: safeAreaHeight * 0.07,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: Stack(
              children: [
                Align(
                  child: nText(
                    "営業時間",
                    color: Colors.black,
                    fontSize: safeAreaWidth / 25,
                    bold: 700,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.all(safeAreaHeight * 0.015),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: safeAreaHeight * 0.05, bottom: safeAreaHeight * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 2; i++) ...{
                  Material(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        String valueChange =
                            editBusinessHour.value.split("@")[i];
                        final int hour = int.parse(valueChange.substring(0, 2));
                        final minute = int.parse(valueChange.substring(3, 5));
                        DatePicker.showTimePicker(
                          context,
                          showSecondsColumn: false,
                          onConfirm: (value) {
                            final setValue = DateFormat('HH:mm').format(value);
                            if (i == 0) {
                              editBusinessHour.value =
                                  "$setValue@${editBusinessHour.value.split("@")[1]}";
                            } else {
                              editBusinessHour.value =
                                  "${editBusinessHour.value.split("@")[0]}@$setValue";
                            }
                          },
                          currentTime: DateTime(
                            1,
                            1,
                            1,
                            hour,
                            minute,
                          ),
                          locale: LocaleType.jp,
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: safeAreaHeight * 0.055,
                        width: safeAreaWidth * 0.43,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            nText(
                                i == 0
                                    ? "営業開始：${editBusinessHour.value.split("@")[0]}"
                                    : "営業終了：${editBusinessHour.value.split("@")[1]}",
                                color: Colors.black,
                                fontSize: safeAreaWidth / 28,
                                bold: 500),
                            const Icon(
                              Icons.expand_more,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (i == 0)
                    nText("〜",
                        color: Colors.black,
                        fontSize: safeAreaWidth / 30,
                        bold: 500),
                }
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: safeAreaHeight * 0.03),
            child: bottomButton(
              context: context,
              isWhiteMainColor: false,
              text: "保存",
              onTap: () {
                if (initData == editBusinessHour.value) {
                  Navigator.pop(context);
                } else {
                  onTap!(editBusinessHour.value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
