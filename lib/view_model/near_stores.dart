import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'near_stores.g.dart';

@Riverpod(keepAlive: true)
class NearStoresNotifier extends _$NearStoresNotifier {
  @override
  Future<List<String>> build() async {
    return [];
  }

  Future<void> upDataList(List<String> newData) async {
    state = await AsyncValue.guard(() async {
      return [...newData];
    });
  }
}
