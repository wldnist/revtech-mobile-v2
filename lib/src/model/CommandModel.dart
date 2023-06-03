class CommandModel extends Object {
  dynamic? deviceId;
  String? type;
  String? description;
  Map<String, dynamic>? attributes;

  CommandModel({this.deviceId, this.type, this.description, this.attributes});

  CommandModel.fromJson(Map<String, dynamic> json) {
    deviceId = json["deviceId"];
    type = json["type"];
    description = json["description"];
    attributes = json["attributes"];
  }

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'type': type,
        'attributes': attributes,
        'description': description
      };
}
