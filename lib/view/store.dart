import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/pages/img_confirmation_page.dart';
import 'package:lolo_app/view/store/add_event_page.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/store/store_home_widget.dart';

class StorePage extends HookConsumerWidget {
  const StorePage({
    super.key,
    required this.storeData,
  });
  final StoreData storeData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final crowdingSelectNumber = useState<int>(0);
    final story = useState<List<StoryImgType>>([...storeData.postImgList]);
    final event = useState<List<EventType>>([...storeData.eventList]);
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: storeAppBar(context, storeData),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: xPadding(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: safeAreaHeight * 0.03),
                    child: titleWithCircle(context, "混雑状況"),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: safeAreaHeight * 0.02),
                      child: crowdingWidget(context,
                          onTap: (value) => crowdingSelectNumber.value = value,
                          selectNumber: crowdingSelectNumber.value)),
                  Padding(
                    padding: EdgeInsets.only(
                        top: safeAreaHeight * 0.03,
                        bottom: safeAreaHeight * 0.03),
                    child: line(context),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: safeAreaHeight * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            titleWithCircle(context, "ストーリー"),
                            nText("　( 1/7 )",
                                color: Colors.white.withOpacity(0.5),
                                fontSize: safeAreaWidth / 30,
                                bold: 700),
                          ],
                        ),
                        addButton(context, onTap: () async {
                          isLoading.value = true;
                          await getMobileImage(onSuccess: (value) {
                            screenTransitionToTop(
                                context,
                                ImgConfirmation(
                                  img: value,
                                  onTap: (value) {
                                    if (context.mounted) {
                                      final dateNow = DateTime.now();
                                      story.value = [
                                        ...story.value,
                                        StoryImgType(
                                          img: value,
                                          date: dateNow,
                                          id: generateRandomString(),
                                        )
                                      ];
                                    }
                                  },
                                ));
                          }, onError: () {
                            errorSnackbar(context, message: "画像の取得に失敗しました");
                          });
                          isLoading.value = false;
                        })
                      ],
                    ),
                  ),
                  if (story.value.isEmpty) ...{
                    Container(
                      alignment: Alignment.center,
                      height: safeAreaHeight * 0.25,
                      child:
                          storeNotPost(context, Icons.photo_camera, "投稿がありません"),
                    )
                  } else ...{
                    Container(
                      alignment: Alignment.centerLeft,
                      height: safeAreaHeight * 0.25,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < story.value.length; i++) ...{
                              Padding(
                                key: ValueKey(i),
                                padding: EdgeInsets.all(safeAreaWidth * 0.02),
                                child: storeStoryWidget(context,
                                    data: story.value[i], onDelete: () {
                                  story.value.removeAt(i);
                                  story.value = [...story.value];
                                }),
                              )
                            }
                          ],
                        ),
                      ),
                    )
                  },
                  Padding(
                    padding: EdgeInsets.only(
                        top: safeAreaHeight * 0.03,
                        bottom: safeAreaHeight * 0.03),
                    child: line(context),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: safeAreaHeight * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            titleWithCircle(context, "イベント"),
                            nText("",
                                color: Colors.white.withOpacity(0.5),
                                fontSize: safeAreaWidth / 30,
                                bold: 700),
                          ],
                        ),
                        addButton(context, onTap: () async {
                          screenTransitionToTop(context, OnAddEventPage(
                            onAdd: (value) {
                              final filtere = filteredAndSortedEvents(
                                  [...event.value, value]);
                              event.value = [...filtere];
                            },
                          ));
                        })
                      ],
                    ),
                  ),
                  if (event.value.isEmpty) ...{
                    Container(
                      alignment: Alignment.center,
                      height: safeAreaHeight * 0.2,
                      child: storeNotPost(context, null, "イベントがありません"),
                    )
                  } else ...{
                    SizedBox(
                        height: safeAreaHeight * 0.2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0; i < event.value.length; i++) ...{
                                Padding(
                                  key: ValueKey(i),
                                  padding: EdgeInsets.all(safeAreaWidth * 0.02),
                                  child: storeEventWidget(context,
                                      data: event.value[i], onDelete: () {
                                    event.value.removeAt(i);
                                    event.value = [...event.value];
                                  }),
                                )
                              }
                            ],
                          ),
                        ))
                  },
                  SizedBox(
                    height: safeAreaHeight * 0.03,
                  )
                ],
              ),
            ),
          ),
          loadinPage(context: context, isLoading: isLoading.value, text: null)
        ],
      ),
    );
  }
}
