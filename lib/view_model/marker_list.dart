import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'marker_list.g.dart';

@Riverpod(keepAlive: true)
class MarkerListNotifier extends _$MarkerListNotifier {
  @override
  Future<Set<Marker>> build() async {
    return {};
  }

  Future<void> addData(Marker marker) async {
    final List<String> markerIds =
        state.value!.map((marker) => marker.markerId.value).toList();
    if (!markerIds.contains(marker.markerId.value)) {
      final newMarkers = Set<Marker>.from(state.value!)..add(marker);
      state = await AsyncValue.guard(() async {
        return newMarkers;
      });
    }
  }
}
