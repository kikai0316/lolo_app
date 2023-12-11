import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/search/event_search_sheet.dart';
import 'package:lolo_app/view/search/station_search_sheet.dart';
import 'package:lolo_app/view/search/word_search_sheet.dart';
import 'package:lolo_app/view/swiper.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/home_widget.dart';
import 'package:lolo_app/widget/search_widget.dart';

class SearchPage extends HookConsumerWidget {
  SearchPage(
      {super.key,
      required this.nearStores,
      required this.locationData,
      required this.onSearch});
  final List<StoreData> nearStores;
  final LatLng locationData;
  final void Function(LatLng)? onSearch;
  final TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final text = useState<String>("");
    final isLoading = useState<bool>(false);
    Future<void> toSearch(LatLng location) async {
      isLoading.value = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      isLoading.value = true;
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      onSearch!(location);
    }

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          floatingActionButton: FloatingActionButton(onPressed: () async {}),
          appBar: appBar(context, "探す"),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: safeAreaWidth * 0.02,
                  right: safeAreaWidth * 0.02,
                  bottom: safeAreaHeight * 0.03,
                ),
                child: searchTextFiled(context,
                    textController: textController,
                    deleteOnTap: text.value.isNotEmpty ? () {} : null,
                    onChanged: (value) {
                  text.value = value;
                }, onFieldSubmitted: (String value) async {
                  primaryFocus?.unfocus();
                  if (value.isNotEmpty) {
                    bottomSheet(context,
                        page: WordSearchSheetWidget(
                          onSearch: (value) => toSearch(value),
                          searchWord: value,
                        ),
                        isBackgroundColor: false);
                  }
                }),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: safeAreaWidth * 0.02,
                    right: safeAreaWidth * 0.02,
                    bottom: safeAreaHeight * 0.015),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < 2; i++) ...{
                      Material(
                        color: blackColor,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () async {
                            if (i == 0) {
                              bottomSheet(context,
                                  page: StationSearchSheetWidget(
                                      onSearch: (value) => toSearch(value)),
                                  isBackgroundColor: false);
                            } else {
                              final DateTime? selectedDate =
                                  await showCalendar(context);
                              if (selectedDate != null) {
                                // ignore: use_build_context_synchronously
                                bottomSheet(context,
                                    page: EventSearchSheetWidget(
                                        dateTime: selectedDate,
                                        onSearch: (value) => toSearch(value)),
                                    isBackgroundColor: false);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            alignment: Alignment.center,
                            height: safeAreaHeight * 0.045,
                            width: safeAreaWidth * 0.46,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Padding(
                                padding: EdgeInsets.all(safeAreaWidth * 0.02),
                                child: nText(i == 0 ? "駅から検索" : "イベント検索",
                                    color: Colors.white,
                                    fontSize: safeAreaWidth / 30,
                                    bold: 400),
                              ),
                            ),
                          ),
                        ),
                      )
                    }
                  ],
                ),
              ),
              Container(
                height: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              Expanded(
                  child: Stack(
                children: [
                  SizedBox(
                    width: safeAreaWidth * 1,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SingleChildScrollView(
                          //     scrollDirection: Axis.horizontal,
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       children: [
                          //         for (int i = 0; i < 10; i++) ...{
                          //           areaWidget(context,
                          //               index: i,
                          //               itemCount: 12,
                          //               name: i == 0 ? "渋谷" : "新宿")
                          //         }
                          //       ],
                          //     )),
                          if (nearStores.isNotEmpty) ...{
                            titleWithCircle(context, "付近のお店"),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: safeAreaWidth * 0.02,
                                  ),
                                  for (int i = 0;
                                      i < nearStores.length;
                                      i++) ...{
                                    OnStore(
                                      isFocus: false,
                                      storeData: nearStores[i],
                                      locationonTap: null,
                                      distance: calculateDistanceToString(
                                          nearStores[i].location, locationData),
                                      onTap: () => screenTransitionHero(
                                        context,
                                        SwiperPage(
                                          storeList: nearStores,
                                          index: i,
                                        ),
                                      ),
                                    ),
                                  },
                                ],
                              ),
                            ),
                          },
                          titleWithCircle(context, "付近のイベント"),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // for (int i = 0; i < 10; i++) ...{
                                  eventWidget(context, "Club Camelot")
                                  // }
                                ],
                              )),
                          titleWithCircle(context, "アーティスト"),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // for (int i = 0; i < 10; i++) ...{
                                  artistWidget(context, "Club Camelot")
                                  // }
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).viewInsets.bottom > 0) ...{
                    GestureDetector(
                      onTap: () => primaryFocus?.unfocus(),
                      child: Container(
                        width: safeAreaWidth * 1,
                        height: safeAreaHeight * 1,
                        color: Colors.black.withOpacity(0),
                      ),
                    )
                  }
                ],
              )),
            ],
          ),
        ),
        loadinPage(context: context, isLoading: isLoading.value, text: null)
      ],
    );
  }

  Widget titleWithCircle(BuildContext context, String text) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    return Padding(
      padding: EdgeInsets.only(
          left: safeAreaWidth * 0.03,
          right: safeAreaWidth * 0.03,
          top: safeAreaHeight * 0.03,
          bottom: safeAreaHeight * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: safeAreaWidth * 0.02),
            child: Container(
              height: safeAreaWidth * 0.05,
              width: safeAreaWidth * 0.05,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          nText(text,
              color: Colors.white, fontSize: safeAreaWidth / 25, bold: 700)
        ],
      ),
    );
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
}
