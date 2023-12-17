import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';

class OnUpLoadPage extends HookConsumerWidget {
  const OnUpLoadPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final pageIndex = useState<int>(0);
    final PageController controller = PageController();
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          appBar: appBar(context,
              pageIndex: pageIndex.value,
              onTap: (value) => pageIndex.value = value),
          body: PageView(
            onPageChanged: (index) {
              pageIndex.value = index;
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            controller: controller,
            children: <Widget>[
              Container(
                height: safeAreaHeight * 1,
                width: safeAreaWidth * 1,
                color: Colors.red,
              ),
              Container(
                height: safeAreaHeight * 1,
                width: safeAreaWidth * 1,
                color: Colors.blue,
              )
            ],
          ),
        ),
        loadinPage(context: context, isLoading: isLoading.value, text: null)
      ],
    );
  }

  PreferredSizeWidget? appBar(BuildContext context,
      {required int pageIndex, required void Function(int) onTap}) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: safeAreaWidth * 0.04),
            child: IconButton(
              alignment: Alignment.center,
              splashRadius: safeAreaHeight * 0.03,
              onPressed: () => Navigator.pop(context),
              icon: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.close,
                  size: safeAreaWidth / 13,
                ),
              ),
            ),
          )
        ],
        title: Container(
          height: safeAreaHeight * 0.055,
          width: safeAreaWidth * 0.6,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              for (int i = 0; i < 2; i++) ...{
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    child: Container(
                      alignment: Alignment.center,
                      height: safeAreaHeight * 0.055,
                      decoration: BoxDecoration(
                        color: pageIndex == i ? Colors.white : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Opacity(
                        opacity: pageIndex == i ? 1 : 0.8,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: nText(i == 0 ? "編集" : "プレビュー",
                              color: blueColor2,
                              fontSize: safeAreaWidth / 27,
                              bold: 700),
                        ),
                      ),
                    ),
                  ),
                )
              }
            ],
          ),
        ));
  }
}
