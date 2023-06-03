class Command extends Object {
  String? deviceId;
  String? type;
  Map<String, dynamic>? attributes;

  Command({deviceId, type});

  Command.fromJson(Map<String, dynamic> json) {
    deviceId = json["deviceId"];
    type = json["type"];
    attributes = json["attributes"];
  }

  Map<String, dynamic> toJson() =>
      {'deviceId': deviceId, 'type': type, 'attributes': attributes};
}
