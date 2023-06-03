import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gpspro/Config.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  late SharedPreferences prefs;

  String _notificationToken = "";
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    Permission _permission = Permission.location;
    _permission.request();
    checkPreference();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool("ads", true);
    if (prefs.get('email') != null) {
      if (prefs.get("popup_notify") == null) {
        prefs.setBool("popup_notify", true);
      }
      initFirebase();
      checkLogin();
    } else {
      prefs.setBool("popup_notify", true);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: (int? id, String? title,
                String? body, String? payload) async {});
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    });

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.getToken().then((value) => {_notificationToken = value!});
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // NotificationSettings settings = await messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );

    await messaging.getToken().then((value) => {_notificationToken = value!});
    print(_notificationToken);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(message.notification!.title);
      print(message.notification!.body);
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              "0", message.notification!.title.toString(),
              channelDescription: message.notification!.body.toString(),
              channelShowBadge: false,
              importance: Importance.max,
              priority: Priority.high,
              onlyAlertOnce: true);
      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, platformChannelSpecifics,
          payload: 'item x');
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void checkLogin() {
    Future.delayed(const Duration(milliseconds: 5000), () {
      Traccar.login(PURCHASE_CODE, prefs.get('email'), prefs.get('password'))
          .then((response) {
        if (response != null) {
          if (response.statusCode == 200) {
            prefs.setString("user", response.body);
            final user = User.fromJson(jsonDecode(response.body));
            updateUserInfo(user, user.id.toString());
            prefs.setString("userId", user.id.toString());
            prefs.setString("userJson", response.body);
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    });
  }

  void updateUserInfo(User user, String id) {
    if (user.attributes != null) {
      var oldToken =
          user.attributes!["notificationTokens"].toString().split(",");
      var tokens = user.attributes!["notificationTokens"];

      if (user.attributes!.containsKey("notificationTokens")) {
        if (!oldToken.contains(_notificationToken)) {
          user.attributes!["notificationTokens"] =
              _notificationToken + "," + tokens;
        }
      } else {
        user.attributes!["notificationTokens"] = _notificationToken;
      }
    } else {
      user.attributes = new HashMap();
      user.attributes?["notificationTokens"] = _notificationToken;
    }

    String userReq = json.encode(user.toJson());

    print(userReq);

    Traccar.updateUser(userReq, id).then((value) => {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            child: new Column(children: <Widget>[
              new Image.asset(
                  'images/logo.png',
                  height: 250.0,
                  fit: BoxFit.contain,
                ),
              Padding(
                padding: EdgeInsets.all(20),
              ),
              Text(SPLASH_SCREEN_TEXT1,
                  style:
                      TextStyle(color: CustomColor.primaryColor, fontSize: 20)),
              Text(SPLASH_SCREEN_TEXT2,
                  style:
                      TextStyle(color: CustomColor.primaryColor, fontSize: 15)),
              Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            ]),
          ),
        ],
      ),
    );
  }
}
