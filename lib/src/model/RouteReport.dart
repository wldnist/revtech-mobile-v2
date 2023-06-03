class RouteReport extends Object {
  int? id;
  int? deviceId;
  String? type;
  String? protocol;
  String? serverTime;
  String? deviceTime;
  String? fixTime;
  bool? outdated;
  bool? valid;
  double? latitude;
  double? longitude;
  double? altitude;
  double? speed;
  double? course;
  String? address;
  double? accuracy;

  RouteReport(
      {id,
      deviceId,
      type,
      protocol,
      serverTime,
      deviceTime,
      fixTime,
      outdated,
      valid,
      latitude,
      longitude,
      altitude,
      speed,
      course,
      address,
      accuracy});

  RouteReport.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    deviceId = json["deviceId"];
    type = json["type"];
    protocol = json["protocol"];
    serverTime = json["serverTime"];
    deviceTime = json["deviceTime"];
    fixTime = json["fixTime"];
    outdated = json["outdated"];
    valid = json["valid"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    altitude = json["altitude"];
    speed = json["speed"];
    course = json["course"];
    address = json["address"];
    accuracy = json["accuracy"];
  }
}
