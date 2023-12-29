import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/search/on_search_page.dart';
import 'package:lolo_app/view/search/station_search_sheet.dart';
import 'package:lolo_app/view_model/all_stores.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/search/search_widget.dart';

TextEditingController? searctextController;

class SearchPage extends HookConsumerWidget {
  const SearchPage({
    super.key,
    required this.locationData,
  });
  final Position locationData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final text = useState<String>("");
    final allStores = ref.watch(allStoresNotifierProvider);
    final List<StoreData> allStoresWhen = allStores.when(
      data: (value) => value != null
          ? sortByDistance(
                  value, LatLng(locationData.latitude, locationData.longitude))
              .sublist(0, 5)
          : [],
      error: (e, s) => [],
      loading: () => [],
    );
    useEffect(() {
      searctextController = TextEditingController();
      return null;
    }, []);

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: appBar(context, "店舗を探す", false),
      body: Padding(
        padding: EdgeInsets.only(
          left: safeAreaWidth * 0.02,
          right: safeAreaWidth * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: safeAreaHeight * 0.015,
              ),
              child: searchTextFiled(context,
                  textController: searctextController,
                  isFocus: true,
                  deleteOnTap: text.value.isNotEmpty
                      ? () {
                          searctextController?.clear();
                          text.value = "";
                        }
                      : null, onChanged: (value) {
                text.value = value;
              }, onFieldSubmitted: (String value) async {
                primaryFocus?.unfocus();
                screenTransitionNormal(
                    context,
                    OnSearchPage(
                        searchWord: searctextController?.value.text ?? "",
                        locationData: LatLng(
                            locationData.latitude, locationData.longitude),
                        isWordSearch: true));
              }),
            ),
            stationSearchButton(
              context,
              onTap: () async {
                bottomSheet(context,
                    page: StationSearchSheetWidget(onSearch: (value) {
                  primaryFocus?.unfocus();
                  screenTransitionNormal(
                      context,
                      OnSearchPage(
                          searchWord: value.name,
                          locationData: value.location,
                          isWordSearch: false));
                }), isBackgroundColor: false);
              },
            ),
            Padding(
                padding: EdgeInsets.only(
                  top: safeAreaHeight * 0.015,
                  bottom: safeAreaHeight * 0.015,
                ),
                child: line(context)),
            Expanded(
                child: Stack(
              children: [
                if (MediaQuery.of(context).viewInsets.bottom > 0) ...{
                  GestureDetector(
                    onTap: () => primaryFocus?.unfocus(),
                    child: Container(
                      width: safeAreaWidth * 1,
                      height: safeAreaHeight * 1,
                      color: Colors.black.withOpacity(0),
                    ),
                  )
                },
                Wrap(
                  spacing: safeAreaWidth * 0.03,
                  children: [
                    for (final item in allStoresWhen) ...{
                      GestureDetector(
                        onTap: () {
                          searctextController =
                              TextEditingController(text: item.name);
                          text.value = item.name;
                        },
                        child: Chip(
                            backgroundColor: Colors.black,
                            side:
                                BorderSide(color: Colors.grey.withOpacity(0.3)),
                            label: nText(item.name,
                                color: Colors.white,
                                fontSize: safeAreaWidth / 30,
                                bold: 700)),
                      ),
                    }
                  ],
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget stationSearchButton(BuildContext context,
      {required void Function() onTap}) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return Material(
      color: blackColor,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          alignment: Alignment.center,
          height: safeAreaHeight * 0.04,
          width: safeAreaWidth / 3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Padding(
              padding: EdgeInsets.all(safeAreaWidth * 0.02),
              child: nText("駅から検索",
                  color: Colors.white, fontSize: safeAreaWidth / 30, bold: 400),
            ),
          ),
        ),
      ),
    );
  }
}
