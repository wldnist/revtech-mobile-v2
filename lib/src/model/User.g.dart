// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int?,
      attributes: json['attributes'] as Map<String, dynamic>?,
      name: json['name'] as String?,
      login: json['login'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      readonly: json['readonly'] as bool?,
      administrator: json['administrator'] as bool?,
      map: json['map'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      zoom: json['zoom'] as int?,
      twelveHourFormat: json['twelveHourFormat'] as bool?,
      coordinateFormat: json['coordinateFormat'] as String?,
      disabled: json['disabled'] as bool?,
      expirationTime: json['expirationTime'] as String?,
      deviceLimit: json['deviceLimit'] as int?,
      userLimit: json['userLimit'] as int?,
      deviceReadonly: json['deviceReadonly'] as bool?,
      token: json['token'] as String?,
     limitCommands: json['limitCommands'] as bool?,
     poiLayer: json['poiLayer'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'attributes': instance.attributes,
      'name': instance.name,
      'login': instance.login,
      'email': instance.email,
      'phone': instance.phone,
      'readonly': instance.readonly,
      'administrator': instance.administrator,
      'map': instance.map,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'zoom': instance.zoom,
      'twelveHourFormat': instance.twelveHourFormat,
      'coordinateFormat': instance.coordinateFormat,
      'disabled': instance.disabled,
      'expirationTime': instance.expirationTime,
      'deviceLimit': instance.deviceLimit,
      'userLimit': instance.userLimit,
      'deviceReadonly': instance.deviceReadonly,
      'token': instance.token,
     'limitCommands': instance.limitCommands,
      'poiLayer': instance.poiLayer,
      'password': instance.password,
    };
