import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:http/http.dart' as http;

class StationSearchSheetWidget extends HookConsumerWidget {
  const StationSearchSheetWidget({super.key, required this.onSearch});
  final void Function(StationData)? onSearch;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final company = useState<List<StationData>?>(null);
    final line = useState<List<StationData>?>(null);
    final station = useState<List<StationData>?>(null);
    final pageIndex = useState<int>(-1);
    final isError = useState<bool>(false);
    final dataList = [company.value, line.value, station.value];
    final titleList = ["Q 鉄道会社を選択してください", "Q 路線を選択してください", "Q 駅を選択してください"];
    Future<void> getData(int id) async {
      pageIndex.value++;
      final nameList = [
        "company_name",
        "line_name",
        "station_name",
      ];
      final idList = [
        "company_cd",
        "line_cd",
        "station_cd",
      ];
      final urlList = [
        'https://train.teraren.com/companies.json',
        'https://train.teraren.com/companies/$id/lines.json',
        'https://train.teraren.com/lines/$id/stations.json'
      ];
      final List<StationData> setList = [];
      try {
        var url = Uri.parse(urlList[pageIndex.value]);
        var response = await http.get(url);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          for (final item in data) {
            final String? name = item[nameList[pageIndex.value]];
            final int? id = item[idList[pageIndex.value]];
            final String? lat = pageIndex.value == 2 ? item["lat"] : "0";
            final String? lon = pageIndex.value == 2 ? item["lon"] : "0";
            if (name != null && id != null && lat != null && lon != null) {
              setList.add(StationData(
                  name: name,
                  id: id,
                  location: LatLng(double.parse(lat), (double.parse(lon)))));
            }
          }
          if (context.mounted) {
            if (pageIndex.value == 0) {
              company.value = setList;
            } else if (pageIndex.value == 1) {
              line.value = setList;
            } else {
              station.value = setList;
            }
          }
        }
      } catch (e) {
        isError.value = true;
      }
    }

    useEffect(() {
      getData(0);
      return null;
    }, []);
    return Container(
      height: safeAreaHeight * 0.98,
      decoration: const BoxDecoration(
        color: blackColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
          padding: EdgeInsets.all(safeAreaWidth * 0.03),
          child: Column(children: [
            SizedBox(
              height: safeAreaHeight * 0.05,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: nText("駅から検索",
                        color: Colors.white,
                        fontSize: safeAreaWidth / 19,
                        bold: 600),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: textButton(
                      text: "とじる",
                      size: safeAreaWidth / 25,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    width: safeAreaWidth * 0.1,
                    height: safeAreaHeight * 0.05,
                    child: pageIndex.value != 0
                        ? GestureDetector(
                            onTap: () => pageIndex.value--,
                            child: Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: safeAreaWidth / 12,
                            ),
                          )
                        : null),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: nText(
                          pageIndex.value == -1
                              ? ""
                              : titleList[pageIndex.value],
                          color: Colors.grey,
                          fontSize: safeAreaWidth / 23,
                          bold: 500),
                    ),
                  ),
                ),
                SizedBox(
                  width: safeAreaWidth * 0.1,
                ),
              ],
            ),
            if (!isError.value) ...{
              Expanded(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(safeAreaWidth * 0.03),
                  child: Column(
                    children: [
                      if (pageIndex.value != -1) ...{
                        if (dataList[pageIndex.value] != null) ...{
                          for (final item in dataList[pageIndex.value]!) ...{
                            onList(context,
                                onTap: pageIndex.value == 2
                                    ? () {
                                        if (item.location.latitude != 0) {
                                          Navigator.pop(context);
                                          onSearch!(StationData(
                                              name: "${item.name}駅周辺",
                                              id: 0,
                                              location: item.location));
                                        } else {
                                          isError.value = true;
                                        }
                                      }
                                    : () {
                                        if (pageIndex.value == 0) {
                                          line.value = null;
                                        } else if (pageIndex.value == 1) {
                                          station.value = null;
                                        }
                                        getData(item.id);
                                      },
                                value: item.name)
                          },
                          if (dataList[pageIndex.value]!.isEmpty) ...{
                            Padding(
                              padding:
                                  EdgeInsets.only(top: safeAreaHeight * 0.03),
                              child: nText("データがありません。",
                                  color: Colors.grey,
                                  fontSize: safeAreaWidth / 25,
                                  bold: 500),
                            )
                          }
                        } else ...{
                          dataLoading(context)
                        },
                      } else ...{
                        dataLoading(context)
                      },
                      SizedBox(
                        height: safeAreaHeight * 0.03,
                      )
                    ],
                  ),
                ),
              )),
            } else ...{
              Padding(
                padding: EdgeInsets.only(top: safeAreaHeight * 0.03),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: nText("サーバーとの通信で問題が発生しました。\nしばらく時間をおいてから、もう一度お試しください",
                      color: Colors.red,
                      fontSize: safeAreaWidth / 30,
                      bold: 500),
                ),
              )
            }
          ])),
    );
  }

  Widget onList(BuildContext context,
      {required void Function()? onTap, required String value}) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: safeAreaHeight * 0.065,
        width: safeAreaWidth * 1,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0),
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: nText(value,
                    color: Colors.white,
                    fontSize: safeAreaWidth / 24,
                    bold: 400),
              ),
            )),
            Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: safeAreaWidth / 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget dataLoading(
    BuildContext context,
  ) {
    final safeAreaHeight = safeHeight(context);

    return Padding(
      padding: EdgeInsets.only(top: safeAreaHeight * 0.02),
      child: CupertinoActivityIndicator(
        color: Colors.white,
        radius: safeAreaHeight * 0.015,
      ),
    );
  }
}

class StationData {
  String name;
  int id;
  LatLng location;
  StationData({required this.name, required this.id, required this.location});
}
