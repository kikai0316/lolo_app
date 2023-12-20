import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view_model/device_list.dart';
import 'package:lolo_app/widget/app_widget.dart';

class NearUserPage extends HookConsumerWidget {
  const NearUserPage({super.key, required this.userData});
  final UserData userData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    // final deviceList = ref.watch(deviseListNotifierProvider);
    // final deviceListWhen = deviceList.when(
    //     data: (data) => data, error: (e, s) => [], loading: () => []);
    useEffect(() {
      final notifier = ref.read(deviseListNotifierProvider.notifier);
      notifier.initNearbyService(userData);
      return () {
        notifier.resetData();
      };
    }, []);

    return Scaffold(
      backgroundColor: blackColor,
      appBar: appBar(context, "近くのユーザー", false),
      body: Stack(
        children: [
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: safeAreaWidth * 0.2,
                width: safeAreaWidth * 1,
                decoration: const BoxDecoration(
                  color: blueColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
              )
              // child: Container(
              //   height: safeAreaWidth * 0.27,
              //   width: safeAreaWidth * 0.27,
              //   decoration: BoxDecoration(
              //     image: userData.img != null
              //         ? DecorationImage(
              //             image: MemoryImage(userData.img!), fit: BoxFit.cover)
              //         : notImg(),
              //     boxShadow: const [
              //       BoxShadow(
              //         color: Colors.black,
              //         blurRadius: 10,
              //         spreadRadius: 1.0,
              //       )
              //     ],
              //     shape: BoxShape.circle,
              //   ),
              // ),
              ),
          Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  nText(userData.name,
                      color: Colors.grey,
                      fontSize: safeAreaWidth / 20,
                      bold: 500),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < 5; i++) ...{
                          Padding(
                              padding: EdgeInsets.all(safeAreaWidth * 0.02),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    height: safeAreaWidth * 0.22,
                                    width: safeAreaWidth * 0.22,
                                    decoration: BoxDecoration(
                                      image: userData.img != null
                                          ? DecorationImage(
                                              image: MemoryImage(userData.img!),
                                              fit: BoxFit.cover)
                                          : notImg(),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black,
                                          blurRadius: 10,
                                          spreadRadius: 1.0,
                                        )
                                      ],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: safeAreaHeight * 0.03,
                                      width: safeAreaHeight * 0.03,
                                      decoration: BoxDecoration(
                                        color: greenColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: greenColor.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: safeAreaHeight * 0.02),
                                    child: nText(userData.name,
                                        color: Colors.white,
                                        fontSize: safeAreaWidth / 30,
                                        bold: 700),
                                  )
                                ],
                              )),
                        }
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class OnUser extends HookConsumerWidget {
  const OnUser({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final userData = useState<UserData?>(null);
    useEffect(() {
      Future(() async {
        final getData = await userDataGet(id);
        if (getData != null && context.mounted) {
          userData.value = getData;
        }
      });
      return null;
    }, []);

    return userData.value != null
        ? Column(
            children: [
              Container(
                alignment: Alignment.bottomRight,
                height: safeAreaWidth * 0.27,
                width: safeAreaWidth * 0.27,
                decoration: BoxDecoration(
                  image: userData.value!.img != null
                      ? DecorationImage(
                          image: MemoryImage(userData.value!.img!),
                          fit: BoxFit.cover)
                      : notImg(),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      spreadRadius: 1.0,
                    )
                  ],
                  shape: BoxShape.circle,
                ),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: greenColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: greenColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                ),
              ),
              nText(userData.value!.name,
                  color: Colors.white, fontSize: safeAreaWidth / 20, bold: 700)
            ],
          )
        : const SizedBox();
  }
}
