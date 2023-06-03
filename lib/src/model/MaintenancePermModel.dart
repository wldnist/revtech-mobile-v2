class MaintenancePermModel extends Object {
  int? deviceId;
  int? maintenanceId;

  MaintenancePermModel({deviceId, geofenceId});

  MaintenancePermModel.fromJson(Map<String, dynamic> json) {
    deviceId = json["deviceId"];
    maintenanceId = json["maintenanceId"];
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'maintenanceId': maintenanceId,
  };
}
