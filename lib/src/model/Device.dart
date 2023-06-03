class Device extends Object {
  int? id;
  Map<String, dynamic>? attributes;
  int? groupId;
  String? name;
  String? uniqueId;
  String? status;
  String? lastUpdate;
  int? positionId;
  String? phone;
  String? model;
  String? contact;
  String? category;
  bool? disabled;
  String? photo;

  Device(
      {id,
      attributes,
      name,
      uniqueId,
      status,
      lastUpdate,
      positionId,
      phone,
      model,
      contact,
      category,
      disabled,
      photo});

  Device.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    attributes = json["attributes"];
    name = json["name"];
    uniqueId = json["uniqueId"];
    status = json["status"];
    lastUpdate = json["lastUpdate"];
    positionId = json["positionId"];
    phone = json["phone"];
    model = json["model"];
    contact = json["contact"];
    category = json["category"];
    disabled = json["disabled"];
    photo = json["photo"];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'attributes': attributes,
        'name': name,
        'uniqueId': uniqueId,
        'status': status,
        'lastUpdate': lastUpdate,
        'positionId': positionId,
        'phone': phone,
        'model': model,
        'contact': contact,
        'category': category,
        'disabled': disabled,
        'photo': photo
      };
}
