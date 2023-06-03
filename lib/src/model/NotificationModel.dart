class NotificationModel extends Object {
  int? id;
  Map<String, dynamic>? attributes;
  int? calendarId;
  bool? always;
  String? type;
  String? notificators;

  NotificationModel({
    id,
    attributes,
    calendarId,
    always,
    type,
    notificators
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    attributes = json["attributes"];
    calendarId = json["calendarId"];
    always = json["always"];
    type = json["type"];
    notificators = json["notificators"];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'attributes':attributes,
    'calendarId':calendarId,
    'always':always,
    'type': type,
    'notificators': notificators
  };
}
