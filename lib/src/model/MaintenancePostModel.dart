class MaintenancePostModel extends Object {
  int? id;
  Map<String, dynamic>? attributes;
  String? name;
  String? type;
  double? start;
  double? period;

  MaintenancePostModel({this.id, this.attributes, this.name, this.type, this.start, this.period});

  MaintenancePostModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    attributes = json["attributes"];
    name = json["name"];
    type = json["type"];
    start = json["start"];
    period = json["period"];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'attributes': attributes,
    'name': name,
    'type': type,
    'start': start,
    'period': period,
  };
}
