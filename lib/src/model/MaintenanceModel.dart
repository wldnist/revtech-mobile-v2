class MaintenanceModel extends Object {
  int? id;
  Map<String, dynamic>? attributes;
  String? name;
  String? type;
  double? start;
  double? period;
  bool? enabled;

  MaintenanceModel({this.id, this.attributes, this.name, this.type, this.start, this.period, this.enabled});

  MaintenanceModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    attributes = json["attributes"];
    name = json["name"];
    type = json["type"];
    start = json["start"];
    period = json["period"];
    enabled = json["enabled"];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'attributes': attributes,
    'name': name,
    'type': type,
    'start': start,
    'period': period,
    'enabled': enabled
  };
}
