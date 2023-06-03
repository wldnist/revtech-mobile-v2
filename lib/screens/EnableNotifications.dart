import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/src/model/NotificationModel.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/traccar_gennissi.dart';
import 'package:gpspro/util/string_extension.dart';


class EnableNotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _EnableNotificationPageState();
}

class _EnableNotificationPageState extends State<EnableNotificationPage> {
  List<NotificationTypeModel> notificationTypeList = [];
  List<String> selectedNotifications = [];
  List<String> notificationNotFound = [];
  List<NotificationModel> selectedNotificationss = [];
  bool isLoading = true;

  @override
  void initState() {
    getSelectedNotification();
    super.initState();
  }

  void getNotificationList() {
    Traccar.getNotificationTypes().then((value) => {
      value!.forEach((element) {
        if(selectedNotifications.contains(element.type)){
          element.enabled = true;
            notificationTypeList.add(element);
        }else{
          element.enabled = false;
          notificationNotFound.add(element.type!);
          notificationTypeList.add(element);
        }
        isLoading = false;
      }),
    });
    notificationTypeList.sort((a, b) {
      return a.type!.toLowerCase().compareTo(b.type!.toLowerCase());
    });
    setState(() {

    });
  }


  void getSelectedNotification(){
    Traccar.getNotifications().then((value) => {
      selectedNotificationss.addAll(value!),
      value.forEach((element) {
        List<String> notify = element.notificators!.split(",");
        if(notify.contains("firebase")) {
          selectedNotifications.add(element.type!);
        }
      }),
      getNotificationList(),
    });
    setState(() {

    });
  }

  void enableNotification(String type){
    NotificationModel nt = new NotificationModel();
    nt.id= -1;
    nt.type = type;
    nt.attributes = {};
    nt.calendarId = 0;
    nt.always = true;
    nt.notificators = "firebase";

    String request = json.encode(nt.toJson());

    setState(() {
      Traccar.addNotifications(request).then((value) => {

      });
    });
  }

  void updateNotification(int notificationId,String notificators, dynamic attributes, String type){

    List<String> notify = notificators.split(",");
    notify.add("firebase");

    NotificationModel nt = new NotificationModel();
    nt.id= notificationId;
    nt.attributes = attributes;
    nt.type = type;
    nt.calendarId = 0;
    nt.always = true;
    nt.notificators = notify.join(",");

    String request = json.encode(nt.toJson());

    setState(() {
      Traccar.updateNotification(request, notificationId.toString()).then((value) => {

      });
    });
  }

  void removeNotification(int notificationId,String notificators, dynamic attributes, String type){
    List<String> notify = notificators.split(",");
    notify.remove("firebase");
    NotificationModel nt = new NotificationModel();
    nt.id= notificationId;
    nt.attributes = attributes;
    nt.type = type;
    nt.calendarId = 0;
    nt.always = true;
    nt.notificators = notify.join(",");

    String request = json.encode(nt.toJson());

    setState(() {
      Traccar.updateNotification(request, notificationId.toString()).then((value) => {

      });
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
                      new Text(AppLocalizations.of(context)!.translate(notificationType.type!) != null ? AppLocalizations.of(context)!.translate(notificationType.type!) : amendSentence(notificationType.type!.capitalize())!,
                          style: TextStyle(
                              fontSize: 13.0, fontWeight: FontWeight.bold)),
                      Switch(value: notificationType.enabled!,
                        onChanged: (bool value) {
                          //isLoading = true;
                          if(value){
                            notificationType.enabled = true;
                            selectedNotificationss.forEach((element) {
                              if(element.type == notificationType.type!){
                                updateNotification(element.id!, element.notificators.toString(), element.attributes, element.type!);
                              }
                              if(notificationNotFound.contains(notificationType.type)){
                                notificationNotFound.remove(notificationType.type);
                                enableNotification(notificationType.type!);
                              }
                            });
                          }else{
                            notificationType.enabled = false;
                            selectedNotificationss.forEach((element) {
                              if(element.type == notificationType.type!){
                                removeNotification(element.id!, element.notificators.toString(), element.attributes, element.type!);
                              }
                            });
                          }
                        },)
                    ],
                  ),
                    trailing: notificationType.type! == "alarm" ? GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, "/enableAlarmNotifications");
                      },
                      child: Icon(Icons.arrow_forward_ios),
                    ) :  Text(""),
                )
              ],
            ),
          );
        });
  }
}
