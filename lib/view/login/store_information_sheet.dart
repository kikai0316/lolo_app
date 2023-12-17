import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/img_page/logo_confirmation_page.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/login_widget.dart';
import 'package:http/http.dart' as http;

class StoreSettelingSheetWidget extends HookConsumerWidget {
  StoreSettelingSheetWidget(
      {super.key, required this.onTap, required this.initData});
  final controllerList = List.generate(4, (index) => TextEditingController());
  final void Function(StoreDataInformation) onTap;
  final StoreDataInformation? initData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final logo = useState<Uint8List?>(null);
    final isLoading = useState<bool>(false);
    final isSearchLoading = useState<bool>(false);
    final isErrorList =
        useState<List<bool>>(List.generate(6, (index) => false));
    final open = useState<String?>(null);
    final close = useState<String?>(null);
    Future<void> searchAddress() async {
      isSearchLoading.value = true;
      final url = Uri.parse(
        'http://zipcloud.ibsnet.co.jp/api/search?zipcode=${controllerList[1].text}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic>? results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final dynamic result = results[0] as dynamic;
          final address =
              // ignore: avoid_dynamic_calls
              '${result['address1']}${result['address2']}${result['address3']}';
          controllerList[2].text = address;
        } else {
          // ignore: use_build_context_synchronously
          errorSnackbar(context, message: "住所が見つかりませんでした");
        }
      } else {
        // ignore: use_build_context_synchronously
        errorSnackbar(context, message: "サーバーとの通信に失敗しました。");
      }
      isSearchLoading.value = false;
    }

    void hourBottomSheet(bool isOpen) {
      String valueChange =
          isOpen ? open.value ?? "17:00" : close.value ?? "22:00";
      final int hour = int.parse(valueChange.substring(0, 2));
      final minute = int.parse(valueChange.substring(3, 5));
      DatePicker.showTimePicker(
        context,
        showSecondsColumn: false,
        onChanged: (value) {
          valueChange = DateFormat('HH:mm').format(value);
        },
        onConfirm: (value) {
          if (isOpen) {
            open.value = valueChange;
            isErrorList.value[3] = false;
            isErrorList.value = [...isErrorList.value];
          } else {
            isErrorList.value[4] = false;
            isErrorList.value = [...isErrorList.value];
            close.value = valueChange;
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
    }

    void isCheckEmptyData() {
      if (logo.value == null) {
        isErrorList.value[0] = true;
      }
      if (controllerList[0].value.text == "") {
        isErrorList.value[1] = true;
      }
      if (controllerList[2].value.text == "") {
        isErrorList.value[2] = true;
      }
      if (open.value == null) {
        isErrorList.value[3] = true;
      }
      if (close.value == null) {
        isErrorList.value[4] = true;
      }
      if (controllerList[3].value.text == "") {
        isErrorList.value[5] = true;
      }
      isErrorList.value = [...isErrorList.value];
    }

    useEffect(() {
      if (initData != null && context.mounted) {
        controllerList[0].text = initData!.name;
        controllerList[2].text = initData!.address;
        controllerList[3].text = initData!.searchWord.join(",");
        open.value = initData!.opnen;
        close.value = initData!.close;
        logo.value = initData!.img;
      }
      return null;
    }, []);

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          appBar: appBar(context, "基本情報"),
          body: SafeArea(
            child: Padding(
              padding: xPadding(context),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                              padding:
                                  EdgeInsets.only(top: safeAreaHeight * 0.02),
                              child: logoWidget(context,
                                  data: logo.value,
                                  onTap: () async {
                                    isLoading.value = true;
                                    await getMobileImage(
                                        onSuccess: (value) {
                                          if (context.mounted) {
                                            // logo.value = value;
                                            screenTransitionNormal(
                                                context,
                                                LogoConfirmation(
                                                    img: value,
                                                    onTap: (value) {
                                                      isErrorList.value[0] =
                                                          false;
                                                      isErrorList.value = [
                                                        ...isErrorList.value
                                                      ];
                                                      logo.value = value;
                                                    }));
                                          }
                                        },
                                        onError: () => errorSnackbar(context,
                                            message: "画像の取得に失敗しました"));
                                    isLoading.value = false;
                                  },
                                  deleteOnTap: () => logo.value = null,
                                  isError: isErrorList.value[0])),
                          Padding(
                            padding:
                                EdgeInsets.only(top: safeAreaHeight * 0.03),
                            child: StoreSettelingTextField(
                              title: "店舗名：",
                              isError: isErrorList.value[1],
                              onChanged: (value) {
                                isErrorList.value[1] = false;
                                isErrorList.value = [...isErrorList.value];
                              },
                              controller: controllerList[0],
                              subText: "店舗名を入力...",
                            ),
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.only(top: safeAreaHeight * 0.03),
                              child: postCodeFiled(context,
                                  controller: controllerList[1],
                                  onChanged: (value) {},
                                  onSearch: () => searchAddress(),
                                  isLoading: isSearchLoading.value)),
                          Padding(
                            padding:
                                EdgeInsets.only(top: safeAreaHeight * 0.03),
                            child: StoreSettelingTextField(
                              title: "住所：",
                              controller: controllerList[2],
                              subText: "住所を入力...",
                              isError: isErrorList.value[1],
                              onChanged: (value) {
                                isErrorList.value[2] = false;
                                isErrorList.value = [...isErrorList.value];
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: safeAreaHeight * 0.03),
                            child: businessHourButton(context,
                                text: "営業開始：",
                                data: open.value,
                                isError: isErrorList.value[2],
                                onTap: () => hourBottomSheet(true)),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: safeAreaHeight * 0.03),
                            child: businessHourButton(context,
                                text: "営業終了：",
                                data: close.value,
                                isError: isErrorList.value[3],
                                onTap: () => hourBottomSheet(false)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: safeAreaHeight * 0.03,
                              bottom: safeAreaHeight * 0.005,
                              left: safeAreaWidth * 0.03,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: nText("検索キーワード",
                                  color: Colors.white,
                                  fontSize: safeAreaWidth / 30,
                                  bold: 700),
                            ),
                          ),
                          StoreSettelingTextField(
                            title: "",
                            controller: controllerList[3],
                            subText: "検索キーワードを入力...",
                            isError: isErrorList.value[4],
                            onChanged: (value) {
                              isErrorList.value[5] = false;
                              isErrorList.value = [...isErrorList.value];
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: safeAreaHeight * 0.005,
                              right: safeAreaWidth * 0.03,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (
                                      BuildContext context,
                                    ) =>
                                        Dialog(
                                            elevation: 0,
                                            backgroundColor: Colors.transparent,
                                            child: Container(
                                              width: safeAreaWidth * 0.95,
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    safeAreaWidth * 0.05),
                                                child: Text(
                                                  "検索キーワードとは、一般ユーザーが店舗検索を行う際に、これらのキーワードを参考にした検索結果が表示されます。\n\n検索キーワードには、店舗名やそのひらがな、カタカナ表記などを入力してください。\n各キーワードは半角カンマ、全角カンマ、またはその両方を使用して区切ってください。",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontFamily: "Normal",
                                                      fontVariations: const [
                                                        FontVariation(
                                                            "wght", 500)
                                                      ],
                                                      color: Colors.grey,
                                                      fontSize:
                                                          safeAreaWidth / 30),
                                                ),
                                              ),
                                            )),
                                  );
                                },
                                child: nText("検索キーワードとは？",
                                    color: blueColor,
                                    fontSize: safeAreaWidth / 35,
                                    bold: 700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: safeAreaHeight * 0.01),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isErrorList.value.any((element) => element)) ...{
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: safeAreaHeight * 0.01),
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: nText(
                                    "${isErrorList.value[0] ? "ロゴ画像、" : ""}${isErrorList.value[1] ? "店舗名、" : ""}${isErrorList.value[2] ? "住所、" : ""}${isErrorList.value[3] ? "営業開始、" : ""}${isErrorList.value[4] ? "営業終了、" : ""}${isErrorList.value[5] ? "検索キーワード、" : ""}を入力してください。",
                                    color: Colors.red,
                                    fontSize: safeAreaWidth / 35,
                                    bold: 700),
                              ),
                            ),
                          },
                          bottomButton(
                            context: context,
                            isWhiteMainColor: true,
                            text: "決定",
                            onTap: () async {
                              primaryFocus?.unfocus();
                              isCheckEmptyData();
                              final bool containsTrue =
                                  isErrorList.value.any((element) => element);
                              if (!containsTrue) {
                                onTap(StoreDataInformation(
                                  img: logo.value!,
                                  name: controllerList[0].value.text,
                                  address: controllerList[2].value.text,
                                  opnen: open.value!,
                                  close: open.value!,
                                  searchWord: controllerList[3]
                                      .value
                                      .text
                                      .split(RegExp(',|、')),
                                ));
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        loadinPage(context: context, isLoading: isLoading.value, text: null)
      ],
    );
  }

  Widget logoWidget(BuildContext context,
      {required bool isError,
      required Uint8List? data,
      required void Function()? onTap,
      required void Function()? deleteOnTap}) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return Container(
      alignment: Alignment.center,
      height: safeAreaHeight * 0.14,
      width: safeAreaWidth * 1,
      decoration: BoxDecoration(
        color: blackColor,
        border: isError ? Border.all(color: Colors.red) : null,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              onTap: data == null ? onTap : null,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                  alignment: Alignment.center,
                  height: safeAreaHeight * 0.11,
                  width: safeAreaHeight * 0.11,
                  decoration: BoxDecoration(
                      image: data != null
                          ? DecorationImage(
                              image: MemoryImage(data), fit: BoxFit.cover)
                          : null,
                      border:
                          data != null ? null : Border.all(color: Colors.grey),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: data != null
                              ? Colors.black.withOpacity(0.3)
                              : Colors.transparent,
                          blurRadius: 10,
                          spreadRadius: 1.0,
                        )
                      ]),
                  child: data == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              color: Colors.grey,
                            ),
                            nText("ロゴを追加",
                                color: Colors.grey,
                                fontSize: safeAreaWidth / 38,
                                bold: 700),
                          ],
                        )
                      : null),
            ),
          ),
          if (data != null)
            GestureDetector(
              onTap: deleteOnTap,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(safeAreaWidth * 0.03),
                  child: Container(
                    height: safeAreaHeight * 0.04,
                    width: safeAreaWidth * 0.15,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red,
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: safeAreaWidth / 20,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget postCodeFiled(BuildContext context,
      {required TextEditingController? controller,
      required void Function(String)? onChanged,
      required void Function() onSearch,
      required bool isLoading}) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    return Container(
      width: safeAreaWidth * 1,
      decoration: BoxDecoration(
        color: blackColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: xPadding(context),
        child: Row(
          children: [
            Padding(
                padding: EdgeInsets.only(
                  right: safeAreaWidth * 0.01,
                  left: safeAreaWidth * 0.02,
                ),
                child: nText("郵便番号：",
                    color: Colors.white,
                    fontSize: safeAreaWidth / 30,
                    bold: 700)),
            Expanded(
              child: TextFormField(
                controller: controller,
                onChanged: onChanged,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: "Normal",
                  fontVariations: const [FontVariation("wght", 400)],
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: safeAreaWidth / 28,
                ),
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "郵便番号を入力...",
                  hintStyle: TextStyle(
                    fontFamily: "Normal",
                    fontVariations: const [FontVariation("wght", 400)],
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: safeAreaWidth / 34,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: onSearch,
              child: Container(
                alignment: Alignment.center,
                width: safeAreaWidth * 0.18,
                child: isLoading
                    ? CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: safeAreaHeight * 0.014,
                      )
                    : nText("住所検索",
                        color: blueColor,
                        fontSize: safeAreaWidth / 30,
                        bold: 700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget businessHourButton(BuildContext context,
      {required String text,
      required String? data,
      required bool isError,
      required void Function() onTap}) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    return Material(
      color: blackColor,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: safeAreaHeight * 0.06,
          width: safeAreaWidth * 1,
          decoration: BoxDecoration(
            border: isError ? Border.all(color: Colors.red) : null,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: xPadding(context),
            child: Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(
                      right: safeAreaWidth * 0.01,
                      left: safeAreaWidth * 0.02,
                    ),
                    child: nText(text,
                        color: Colors.white,
                        fontSize: safeAreaWidth / 30,
                        bold: 700)),
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: nText(data ?? "選択してください...",
                      color: data == null ? Colors.grey : Colors.white,
                      fontSize: data == null
                          ? safeAreaWidth / 34
                          : safeAreaWidth / 27,
                      bold: 700),
                )),
                Icon(
                  Icons.arrow_drop_down,
                  size: safeAreaWidth / 13,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoreDataInformation {
  Uint8List img;
  String name;
  String address;
  String opnen;
  String close;
  List<String> searchWord;
  StoreDataInformation({
    required this.img,
    required this.name,
    required this.address,
    required this.opnen,
    required this.close,
    required this.searchWord,
  });
}
