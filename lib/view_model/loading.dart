import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'loading.g.dart';

@Riverpod(keepAlive: true)
class LoadingNotifier extends _$LoadingNotifier {
  @override
  Future<bool> build() async {
    return false;
  }

  Future<void> upData(bool newData) async {
    state = await AsyncValue.guard(() async {
      return newData;
    });
  }
}
