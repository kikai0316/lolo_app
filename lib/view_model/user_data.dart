import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/path_provider_utility.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_data.g.dart';

@Riverpod(keepAlive: true)
class UserDataNotifier extends _$UserDataNotifier {
  @override
  Future<UserData?> build() async {
    final UserData? userData = await readUserData();
    if (userData != null) {
      return userData;
    } else {
      return null;
    }
  }

  Future<void> reLoad() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final getData = await readUserData();
      if (getData != null) {
        return getData;
      } else {
        return null;
      }
    });
  }
}
