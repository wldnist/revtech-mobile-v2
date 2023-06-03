class NotificationTypeModel extends Object {
  String? type;
  bool? enabled;

  NotificationTypeModel({
    this.type,
    this.enabled
  });

  NotificationTypeModel.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    enabled =json["enabled"];
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'enabled': enabled
  };
}
