import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/src/model/NotificationModel.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/traccar_gennissi.dart';
import 'package:gpspro/util/string_extension.dart';


class EnableAlarmNotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _EnableAlarmNotificationPageState();
}

class _EnableAlarmNotificationPageState extends State<EnableAlarmNotificationPage> {
  List<NotificationTypeModel> notificationTypeList = [];
  List<String> selectedNotifications = [];
  List<NotificationModel> selectedNotificationss = [];
  bool isLoading = true;

  List<NotificationTypeModel> alarms = [];
  int? notificationId;
  List<String> notify =[];

  @override
  void initState() {
    addAlarms();
    getSelectedNotification();
    super.initState();
  }

  void addAlarms(){
    alarms.add(NotificationTypeModel(type:"general", enabled: false));
    alarms.add(NotificationTypeModel(type:"sos",enabled: false));
    alarms.add(NotificationTypeModel(type:"vibration",enabled: false));
    alarms.add(NotificationTypeModel(type:"movement",enabled: false));
    alarms.add(NotificationTypeModel(type:"overspeed",enabled: false));
    alarms.add(NotificationTypeModel(type:"fallDown",enabled: false));
    alarms.add(NotificationTypeModel(type:"lowPower",enabled: false));
    alarms.add(NotificationTypeModel(type:"lowBattery",enabled: false));
    alarms.add(new NotificationTypeModel(type:"fault",enabled: false));
    alarms.add(new NotificationTypeModel(type:"powerOff",enabled: false));
    alarms.add(new NotificationTypeModel(type:"powerOn",enabled: false));
    alarms.add(new NotificationTypeModel(type:"door",enabled: false));
    alarms.add(new NotificationTypeModel(type:"lock",enabled: false));
    alarms.add(new NotificationTypeModel(type:"unlock",enabled: false));
    alarms.add(new NotificationTypeModel(type:"geofence",enabled: false));
    alarms.add(new NotificationTypeModel(type:"geofenceEnter",enabled: false));
    alarms.add(new NotificationTypeModel(type:"geofenceExit",enabled: false));
    alarms.add(new NotificationTypeModel(type:"gpsAntennaCut",enabled: false));
    alarms.add(new NotificationTypeModel(type:"accident",enabled: false));
    alarms.add(new NotificationTypeModel(type:"tow",enabled: false));
    alarms.add(new NotificationTypeModel(type:"idle",enabled: false));
    alarms.add(new NotificationTypeModel(type:"highRpm",enabled: false));
    alarms.add(new NotificationTypeModel(type:"hardAcceleration",enabled: false));
    alarms.add(new NotificationTypeModel(type:"hardBraking",enabled: false));
    alarms.add(new NotificationTypeModel(type:"hardCornering",enabled: false));
    alarms.add(new NotificationTypeModel(type:"laneChange",enabled: false));
    alarms.add(new NotificationTypeModel(type:"fatigueDriving",enabled: false));
    alarms.add(new NotificationTypeModel(type:"powerCut",enabled: false));
    alarms.add(new NotificationTypeModel(type:"powerRestored",enabled: false));
    alarms.add(new NotificationTypeModel(type:"jamming",enabled: false));
    alarms.add(new NotificationTypeModel(type:"temperature",enabled: false));
    alarms.add(new NotificationTypeModel(type:"parking",enabled: false));
    alarms.add(new NotificationTypeModel(type:"shock",enabled: false));
    alarms.add(new NotificationTypeModel(type:"bonnet",enabled: false));
    alarms.add(new NotificationTypeModel(type:"footBrake",enabled: false));
    alarms.add(new NotificationTypeModel(type:"fuelLeak",enabled: false));
    alarms.add(new NotificationTypeModel(type:"tampering",enabled: false));
    alarms.add(new NotificationTypeModel(type:"removing",enabled: false));
    //getNotificationList();

  }

  void getNotificationList() {
    alarms.forEach((element) {
      if(selectedNotifications.contains(element.type)){
        print(element.type);
        element.enabled = true;
        notificationTypeList.add(element);
      }else{
        element.enabled = false;
        notificationTypeList.add(element);
      }

      setState(() {
        isLoading = false;
    });
     });
    notificationTypeList.sort((a, b) {
      return a.type!.toLowerCase().compareTo(b.type!.toLowerCase());
    });
    setState(() {

    });
  }


  void getSelectedNotification(){
    Traccar.getNotifications().then((value) => {
      //selectedNotificationss.addAll(value!),
      value!.forEach((element) {
        if(element.type == "alarm"){
          notificationId = element.id;
          if(element.attributes!["alarms"] != null) {
            selectedNotifications = element.attributes!["alarms"].split(",");
          }
          notify = element.notificators!.split(",");
        }
       // selectedNotifications.add(element.attributes[""]!);
      }),
      getNotificationList(),
    });
    setState(() {

    });
  }

  void enableNotification(){
    if(notificationId != null && notificationId! > 0){
      updateNotification();
    }else{
      addNotification();
    }

  }

  void addNotification(){
    NotificationModel nt = new NotificationModel();
    nt.id= notificationId;
    nt.type = "alarm";
    nt.attributes = {"alarms":selectedNotifications.join(',')};
    nt.calendarId = 0;
    nt.always = true;
    nt.notificators = notify.join(",");

    String request = json.encode(nt.toJson());

    setState(() {
      Traccar.addNotifications(request).then((value) => {

      });
    });
  }
  void updateNotification(){
    NotificationModel nt = new NotificationModel();
    nt.id= notificationId;
    nt.type = "alarm";
    nt.attributes = {"alarms":selectedNotifications.join(',')};
    nt.calendarId = 0;
    nt.always = true;
    nt.notificators = notify.join(",");

    String request = json.encode(nt.toJson());

    setState(() {
      Traccar.updateNotification(request, notificationId.toString()).then((value) => {

      });
    });
  }



  void deleteNotification(String notify){
    Traccar.deleteNotifications(notify).then((value) => {
      setState(() {

      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('notification'),
              style: TextStyle(color: CustomColor.secondaryColor)),
        ),
        body: !isLoading ? loadNotifyTypes() : Center(child:CircularProgressIndicator()));
  }

 String? amendSentence(String? sstr)
  {
    var str = sstr!.split('');

    String modString = "";

    for (int i = 0; i < str.length; i++)
    {
      if(i == 0) {
        modString += str[i];
      }else{
        if (str[i].toUpperCase() == str[i]) {
          modString += " " + str[i];
        } else {
          modString += str[i];
        }
      }
    }
    return modString;
  }

  Widget loadNotifyTypes() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: notificationTypeList.length,
        itemBuilder: (context, index) {
          final notificationType = notificationTypeList[index];
          return new Card(
            elevation: 3.0,
            child: Column(
              children: <Widget>[
                new ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(AppLocalizations.of(context)!.translate(notificationType.type!) != null ? AppLocalizations.of(context)!.translate(notificationType.type!) : notificationType.type!,
                          style: TextStyle(
                              fontSize: 13.0, fontWeight: FontWeight.bold)),
                      Switch(value: notificationType.enabled!,
                        onChanged: (bool value) {
                          //isLoading = true;
                          if(value){
                            notificationType.enabled = true;
                            selectedNotifications.add(notificationType.type!);
                            enableNotification();
                          }else{
                            notificationType.enabled = false;
                            selectedNotifications.remove(notificationType.type!);
                            enableNotification();
                          }
                        },)
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
