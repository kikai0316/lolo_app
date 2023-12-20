import 'dart:async';

import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_list.g.dart';

NearbyService? nearbyService;
StreamSubscription<dynamic>? stateChangedSubscription;
StreamSubscription<dynamic>? dataReceivedSubscription;

@Riverpod(keepAlive: true)
class DeviseListNotifier extends _$DeviseListNotifier {
  @override
  Future<List<String>?> build() async {
    return null;
  }

  Future<void> initNearbyService(UserData userData) async {
    nearbyService = NearbyService();
    await nearbyService?.init(
      serviceType: 'bobo',
      deviceName: userData.id,
      strategy: Strategy.P2P_CLUSTER,
      callback: (bool isRunning) async {
        if (isRunning) {
          try {
            await nearbyService?.stopAdvertisingPeer();
            await nearbyService?.stopBrowsingForPeers();
            await stateChangedSubscription?.cancel();
            await dataReceivedSubscription?.cancel();
            await Future<void>.delayed(const Duration(microseconds: 200));
            await nearbyService?.startAdvertisingPeer();
            await nearbyService?.startBrowsingForPeers();
            await Future<void>.delayed(const Duration(microseconds: 200));
            callbackNearbyService();
          } catch (e) {
            await nearbyService?.stopAdvertisingPeer();
            await nearbyService?.stopBrowsingForPeers();
            state = await AsyncValue.guard(() async {
              return null;
            });
            return;
          }
        }
      },
    );
  }

  Future<void> callbackNearbyService() async {
    stateChangedSubscription = nearbyService?.stateChangedSubscription(
      callback: (devicesList) async {
        state = await AsyncValue.guard(() async {
          return devicesList.map((device) => device.deviceId).toList();
        });
      },
    );
  }

  Future<void> resetData() async {
    await stateChangedSubscription?.cancel();
    await dataReceivedSubscription?.cancel();
    await nearbyService?.stopAdvertisingPeer();
    await nearbyService?.stopBrowsingForPeers();
    state = await AsyncValue.guard(() async {
      return null;
    });
  }
}
