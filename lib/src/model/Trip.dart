class Trip extends Object {
  int? deviceId;
  String? deviceName;
  double? distance;
  double? averageSpeed;
  double? maxSpeed;
  double? spentFuel;
  double? startOdometer;
  double? endOdometer;
  int? startPositionId;
  int? endPositionId;
  double? startLat;
  double? startLon;
  double? endLat;
  double? endLon;
  String? startTime;
  String? startAddress;
  String? endTime;
  String? endAddress;
  int? duration;
  String? driverUniqueId;
  String? driverName;

  Trip(
      {deviceId,
      deviceName,
      distance,
      averageSpeed,
      maxSpeed,
      spentFuel,
      startOdometer,
      endOdometer,
      startPositionId,
      endPositionId,
      startLat,
      startLon,
      endLat,
      endLon,
      startTime,
      startAddress,
      endTime,
      endAddress,
      duration,
      driverUniqueId,
      driverName});

  Trip.fromJson(Map<String, dynamic> json) {
    deviceId = json["deviceId"];
    deviceName = json["deviceName"];
    distance = json["distance"];
    averageSpeed = json["averageSpeed"];
    maxSpeed = json["maxSpeed"];
    spentFuel = json["spentFuel"];
    startOdometer = json["startOdometer"];
    endOdometer = json["endOdometer"];
    startPositionId = json["startPositionId"];
    endPositionId = json["endPositionId"];
    startLat = json["startLat"];
    startLon = json["startLon"];
    endLat = json["endLat"];
    endLon = json["endLon"];
    startTime = json["startTime"];
    startAddress = json["startAddress"];
    endTime = json["endTime"];
    endAddress = json["endAddress"];
    duration = json["duration"];
    driverUniqueId = json["driverUniqueId"];
    driverName = json["driverName"];
  }
}
