import '../../traccar_gennissi.dart';

class UpdateDeviceAction {
  final List<Device> devices;

  UpdateDeviceAction(this.devices);
}

class UpdatePositionAction {
  final List<PositionModel> positions;

  UpdatePositionAction(this.positions);
}

// class UpdateCurrentPositionAction {
//   final PositionModel position;
//
//   UpdateCurrentPositionAction(this.position);
// }

class UpdateGeofenceAction {
  final List<GeofenceModel> geofences;

  UpdateGeofenceAction(this.geofences);
}

class AddEventsAction {
  final List<Event> events;

  AddEventsAction(this.events);
}
