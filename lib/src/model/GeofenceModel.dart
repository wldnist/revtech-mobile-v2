class GeofenceModel extends Object {
  int? id;
  Map<String, dynamic>? attributes;
  int? calendarId;
  String? name;
  String? description;
  String? area;

  GeofenceModel({id, attributes, calendarId, name, description, area});

  GeofenceModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    attributes = json["attributes"];
    calendarId = json["calendarId"];
    name = json["name"];
    description = json["description"];
    area = json["area"];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'attributes': attributes,
        'calendarId': calendarId,
        'name': name,
        'description': description,
        'area': area
      };
}
