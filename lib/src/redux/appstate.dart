import 'dart:collection';

import '../../traccar_gennissi.dart';

class AppState {
  Map<int, Device>? devices;
  Map<int, PositionModel>? positions;
  PositionModel? position;
  List<Event>? events;
  Map<int, GeofenceModel>? geofences;

  AppState(
      {this.devices,
      this.positions,
      this.events,
      this.geofences});

  AppState.initialState() {
    devices = new HashMap();
    positions = new HashMap();
    geofences = new HashMap();
    position = new PositionModel();
    events = [];
  }
}
