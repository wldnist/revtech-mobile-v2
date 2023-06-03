class Event extends Object {
  int? id;
  int? deviceId;
  String? type;
  String? serverTime;
  String? eventTime;
  int? positionId;
  int? geofenceId;
  int? maintenanceId;
  Map<String, dynamic>? attributes;

  Event(
      {id,
      deviceId,
      type,
      serverTime,
      eventTime,
      positionId,
      geofenceId,
      maintenanceId,
      attributes});

  Event.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    deviceId = json["deviceId"];
    type = json["type"];
    serverTime = json["serverTime"];
    eventTime = json["eventTime"];
    positionId = json["positionId"];
    geofenceId = json["geofenceId"];
    maintenanceId = json["maintenanceId"];
    attributes = json["attributes"];
  }
}
