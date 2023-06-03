
import 'package:json_annotation/json_annotation.dart';
part 'User.g.dart';

@JsonSerializable()
class User{

  int? id;
  Map<String, dynamic>? attributes;
  String? name;
 String? login;
  String? email;
  String? phone;
  bool? readonly;
 bool? administrator;
  String? map;
  double? latitude;
  double? longitude;
  int? zoom;
  bool? twelveHourFormat;
  String? coordinateFormat;
  bool? disabled;
  String? expirationTime;
  int? deviceLimit;
  int? userLimit;
  bool? deviceReadonly;
  String? token;
  bool? limitCommands;
  String? poiLayer;
   String? password;

  User(
      {this.id,
        this.attributes,
        this.name,
        this.login,
        this.email,
        this.phone,
        this.readonly,
        this.administrator,
        this.map,
        this.latitude,
        this.longitude,
        this.zoom,
        this.twelveHourFormat,
        this.coordinateFormat,
        this.disabled,
        this.expirationTime,
        this.deviceLimit,
        this.userLimit,
        this.deviceReadonly,
        this.token,
       this.limitCommands,
       this.poiLayer,
         this.password
      });

  factory User.fromJson(Map<String,dynamic> data) => _$UserFromJson(data);

  Map<String,dynamic> toJson() => _$UserToJson(this);

  // User();
  //
  //
  // User _$UserFromJson(Map<String, dynamic> json) => User()
  //   json['id'],
  //   json["attributes"],
  //   json["name"],
  //   json["email"];
  //   json["phone"];
  //   json["readonly"];
  //   json["administrator"];
  //   json["map"];
  //   json["latitude"];
  //   longitude = json["longitude"];
  //   zoom = json["zoom"];
  //   twelveHourFormat = json["twelveHourFormat"];
  //   coordinateFormat = json["coordinateFormat"];
  //   disabled = json["disabled"];
  //   expirationTime = json["expirationTime"];
  //   deviceLimit = json["deviceLimit"];
  //   userLimit = json["userLimit"];
  //   deviceReadonly = json["deviceReadonly"];
  //   token = json["token"];
  //   limitCommands = json["limitCommands"];
  //   poiLayer = json["poiLayer"];
  //   password = json["password"];
  // }

  // Map<String, dynamic> toJson() => {
  //   'id': id,
  //   'attributes': attributes,
  //   'name': name,
  //   'email': email,
  //   'phone': phone,
  //   'readonly': readonly,
  //   'administrator': administrator,
  //   'map': map,
  //   'latitude': latitude,
  //   'longitude': longitude,
  //   'zoom': zoom,
  //   'twelveHourFormat': twelveHourFormat,
  //   'coordinateFormat': coordinateFormat,
  //   'disabled': disabled,
  //   'expirationTime': expirationTime,
  //   'deviceLimit': deviceLimit,
  //   'userLimit': userLimit,
  //   'deviceReadonly': deviceReadonly,
  //   'token': token,
  //   'limitCommands': limitCommands,
  //   'poiLayer': poiLayer,
  //   'password': password
  // };
}
