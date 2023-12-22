import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/path_provider_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';

class NotBirthdayPage extends HookConsumerWidget {
  const NotBirthdayPage({
    super.key,
    required this.userData,
  });
  final UserData userData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final birthday = useState<String?>(null);
    final errorText = useState<String?>(null);
    final isLoading = useState<bool>(false);
    final DateTime now = DateTime.now();
    final DateTime twentyYearsAgo = DateTime(now.year - 20);

    DateTime parseDate(String input) {
      if (input.length != 8) {
        return twentyYearsAgo;
      }
      final int year = int.parse(input.substring(0, 4));
      final int month = int.parse(input.substring(4, 6));
      final int day = int.parse(input.substring(6, 8));
      return DateTime(year, month, day);
    }

    String formatDateString(String input) {
      if (input.length != 8) {
        return "取得エラー";
      }
      return "${input.substring(0, 4)} / ${input.substring(4, 6)} / ${input.substring(6, 8)}";
    }

    Future<void> dataUpLoad() async {
      isLoading.value = true;
      final setData = UserData(
          img: userData.img,
          id: userData.id,
          name: userData.name,
          birthday: birthday.value ?? "",
          storeData: userData.storeData);
      final isWite = await writeUserData(setData);
      if (isWite) {
        final nextScreenWhisUserData = nextScreenWhisUserDataCheck(setData);
        if (nextScreenWhisUserData != null) {
          // ignore: use_build_context_synchronously
          screenTransitionNormal(context, nextScreenWhisUserData);
        } else {
          final nextScreenWithLocation = await nextScreenWithLocationCheck();
          if (context.mounted) {
            screenTransitionNormal(context, nextScreenWithLocation);
          }
        }
      } else {
        isLoading.value = false;
        // ignore: use_build_context_synchronously
        errorSnackbar(
          context,
          message: "何らかの問題が発生しました。再試行してください。",
        );
      }
    }

    return Scaffold(
      backgroundColor: blackColor,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: safeAreaHeight * 0.06,
                      bottom: safeAreaHeight * 0.06,
                    ),
                    child: nText(
                      "生年月日を選択してください",
                      color: Colors.white,
                      fontSize: safeAreaWidth / 17,
                      bold: 700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        minTime: DateTime(1950),
                        maxTime: DateTime(2022, 8, 17),
                        currentTime: birthday.value == null
                            ? twentyYearsAgo
                            : parseDate(birthday.value!),
                        locale: LocaleType.jp,
                        onConfirm: (date) {
                          final dataSet =
                              '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
                          errorText.value = null;
                          birthday.value = dataSet;
                        },
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: safeAreaHeight * 0.07,
                      width: safeAreaWidth * 0.8,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          nText(
                            "　${birthday.value != null ? formatDateString(birthday.value!) : "0000 / 00 / 00"}",
                            color: Colors.white,
                            fontSize: safeAreaWidth / 15,
                            bold: 700,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: safeAreaWidth * 0.02,
                            ),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: safeAreaWidth / 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Opacity(
                opacity:
                    birthday.value == null || birthday.value == "" ? 0.3 : 1,
                child: bottomButton(
                  context: context,
                  isWhiteMainColor: true,
                  text: "完了",
                  onTap: () async {
                    if (birthday.value != null && birthday.value != "") {
                      dataUpLoad();
                    }
                  },
                ),
              ),
            ),
          ),
          loadinPage(
            context: context,
            isLoading: isLoading.value,
            text: null,
          ),
        ],
      ),
    );
  }
}
