import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'page_index.g.dart';

@Riverpod(keepAlive: true)
class PageIndexNotifier extends _$PageIndexNotifier {
  @override
  Future<int> build() async {
    return 0;
  }

  Future<void> upData(int newIndex) async {
    state = await AsyncValue.guard(() async {
      return newIndex;
    });
  }
}
