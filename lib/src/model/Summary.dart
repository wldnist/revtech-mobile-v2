class Summary extends Object {
  int? deviceId;
  String? deviceName;
  double? distance;
  double? averageSpeed;
  double? maxSpeed;
  double? spentFuel;
  double? startOdometer;
  double? endOdometer;
  int? engineHours;

  Summary(
      {deviceId,
      deviceName,
      distance,
      averageSpeed,
      maxSpeed,
      spentFuel,
      startOdometer,
      endOdometer,
      engineHours});

  Summary.fromJson(Map<String, dynamic> json) {
    deviceId = json["deviceId"];
    deviceName = json["deviceName"];
    distance = json["distance"];
    averageSpeed = json["averageSpeed"];
    maxSpeed = json["maxSpeed"];
    spentFuel = json["spentFuel"];
    startOdometer = json["startOdometer"];
    endOdometer = json["endOdometer"];
    engineHours = json["engineHours"];
  }
}
