import 'package:redux/redux.dart';

import '../../traccar_gennissi.dart';
import 'actions.dart';
import 'appstate.dart';

class ViewModel {
  Map<int, PositionModel>? positions;
  Map<int, Device>? devices;
  Map<int, GeofenceModel>? geoFences;
  PositionModel? position;
  List<Event>? events;
  Function(List<PositionModel>)? updatePositions;
  Function(List<Device>)? updateDevices;
  Function(List<GeofenceModel>)? updateGeoFences;
  Function(PositionModel)? updatePosition;
  Function(List<Event>)? addEvents;

  ViewModel(
      { required this.positions,
        required this.devices,
        required this.position,
        geoFences,
        required this.events,
        updatePositions,
        updateDevices,
        updatePosition,
        updateGeoFences,
        addEvents});

  factory ViewModel.create(Store<AppState> store) {
    _onUpdatePosition(List<PositionModel> positions) {
      store.dispatch(UpdatePositionAction(positions));
    }

    _onUpdateDevice(List<Device> devices) {
      store.dispatch(UpdateDeviceAction(devices));
    }

    // _onUpdateCurrentPosition(PositionModel pos) {
    //   store.dispatch(UpdateCurrentPositionAction(pos));
    // }

    _onUpdateGeoFences(List<GeofenceModel> geoFences) {
      store.dispatch(UpdateGeofenceAction(geoFences));
    }

    _onAddEvents(List<Event> events) {
      store.dispatch(AddEventsAction(events));
    }

    return ViewModel(
        positions: store.state.positions,
        devices: store.state.devices,
        geoFences: store.state.geofences,
        position: store.state.position,
        events: store.state.events,
        updatePositions: _onUpdatePosition,
        updateDevices: _onUpdateDevice,
        updateGeoFences: _onUpdateGeoFences,
        addEvents: _onAddEvents);
  }
}
