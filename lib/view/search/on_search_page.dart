import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/home/swiper.dart';
import 'package:lolo_app/view_model/all_stores.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/home/home_page_widget.dart';
import 'package:lolo_app/widget/search/search_widget.dart';

TextEditingController? onSearctextController;

class OnSearchPage extends HookConsumerWidget {
  const OnSearchPage(
      {super.key,
      required this.searchWord,
      required this.locationData,
      required this.isWordSearch});
  final String searchWord;
  final LatLng locationData;
  final bool isWordSearch;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final text = useState<String>(searchWord);
    final allStoresNotifier = ref.watch(allStoresNotifierProvider);
    final List<StoreData>? searchStoreList = allStoresNotifier.when(
        data: (value) {
          if (value != null) {
            if (isWordSearch) {
              String formattedQuery =
                  searchWord.toLowerCase().replaceAll(' ', '');
              return sortByDistance(
                  value.where((store) {
                    bool nameMatches = store.name
                        .toLowerCase()
                        .replaceAll(' ', '')
                        .contains(formattedQuery);
                    bool searchWordMatches = store.searchWord.any((word) => word
                        .toLowerCase()
                        .replaceAll(' ', '')
                        .contains(formattedQuery));
                    return nameMatches || searchWordMatches;
                  }).toList(),
                  locationData);
            } else {
              return sortByDistance(
                  value, LatLng(locationData.latitude, locationData.longitude));
            }
          } else {
            return [];
          }
        },
        error: (e, s) => [],
        loading: () => null);

    useEffect(() {
      onSearctextController = TextEditingController(text: searchWord);
      return null;
    }, []);

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: safeAreaHeight * 0.02),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: safeAreaWidth / 10,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: isWordSearch
                          ? searchTextFiled(context,
                              textController: onSearctextController,
                              isFocus: false,
                              deleteOnTap: text.value.isNotEmpty ? () {} : null,
                              onChanged: (value) {
                              text.value = value;
                            }, onFieldSubmitted: (String value) async {
                              primaryFocus?.unfocus();
                              screenTransitionNormal(
                                  context,
                                  OnSearchPage(
                                      searchWord:
                                          onSearctextController?.value.text ??
                                              "",
                                      locationData: LatLng(
                                          locationData.latitude,
                                          locationData.longitude),
                                      isWordSearch: true));
                            })
                          : nText(searchWord,
                              color: Colors.white,
                              fontSize: safeAreaWidth / 20,
                              bold: 700),
                    ),
                  ),
                  SizedBox(
                    width: safeAreaWidth / 12,
                  )
                ],
              ),
            ),
            line(context),
            Expanded(
                child: Stack(
              children: [
                if (searchStoreList != null) ...{
                  SizedBox(
                    width: safeAreaWidth * 1,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (searchStoreList.isNotEmpty) ...{
                            Align(
                              child: Padding(
                                padding: EdgeInsets.all(safeAreaHeight * 0.04),
                                child: nText(
                                    isWordSearch
                                        ? "${searchStoreList.length}件の店舗が見つかりました"
                                        : "$searchWordから近い順",
                                    color: Colors.white,
                                    fontSize: safeAreaWidth / 25,
                                    bold: 700),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: safeAreaHeight * 0.01),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: safeAreaWidth * 0.03,
                                    ),
                                    for (int i = 0;
                                        i < searchStoreList.length;
                                        i++) ...{
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: safeAreaWidth * 0.05),
                                        child: OnStore(
                                          storeData: searchStoreList[i],
                                          distance: calculateDistanceToString(
                                              searchStoreList[i].location,
                                              LatLng(locationData.latitude,
                                                  locationData.longitude)),
                                          onTap: () => screenTransitionHero(
                                            context,
                                            SwiperPage(
                                              storeList: searchStoreList,
                                              index: i,
                                            ),
                                          ),
                                        ),
                                      ),
                                    },
                                  ],
                                ),
                              ),
                            ),
                          } else ...{
                            Align(
                              child: Padding(
                                padding: EdgeInsets.all(safeAreaHeight * 0.04),
                                child: nText("検索結果なし",
                                    color: Colors.white,
                                    fontSize: safeAreaWidth / 25,
                                    bold: 700),
                              ),
                            ),
                          }
                        ],
                      ),
                    ),
                  ),
                } else ...{
                  loadinPage(context: context, isLoading: true, text: "")
                },
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
    );
  }
}
