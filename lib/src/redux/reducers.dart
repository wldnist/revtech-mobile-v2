import '../../traccar_gennissi.dart';
import 'actions.dart';
import 'appstate.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
      positions: positionsReducer(state, action),
      devices: devicesReducer(state, action),
      geofences: geofencesReducer(state, action),
      events: eventReducer(state, action));
}

Map<int, PositionModel>? positionsReducer(AppState prevState, action) {
  if (action is UpdatePositionAction) {
    action.positions.forEach((element) {
      prevState.positions?.putIfAbsent(element.deviceId!, () => element);
      prevState.positions?.update(element.deviceId!, (value) => element);
    });
  }
  return prevState.positions;
}

Map<int, Device>? devicesReducer(AppState prevState, action) {
  if (action is UpdateDeviceAction) {
    action.devices.forEach((element) {
      prevState.devices?.putIfAbsent(element.id!, () => element);
      prevState.devices?.update(element.id!, (value) => element);
    });
  }
  return prevState.devices;
}

// PositionModel positionReducer(AppState prevState, action) {
//   if (action is UpdateCurrentPositionAction) {
//     prevState.positions
//         .update(action.position.deviceId, (value) => action.position);
//     prevState.position = action.position;
//   }
//   return prevState.position;
// }

Map<int, GeofenceModel>? geofencesReducer(AppState prevState, action) {
  if (action is UpdateGeofenceAction) {
    action.geofences.forEach((element) {
      prevState.geofences?.putIfAbsent(element.id!, () => element);
      prevState.geofences?.update(element.id!, (value) => element);
    });
  }
  return prevState.geofences;
}

List<Event>? eventReducer(AppState prevState, action) {
  if (action is AddEventsAction) {
    prevState.events?.addAll(action.events);
  }
  return prevState.events;
}
