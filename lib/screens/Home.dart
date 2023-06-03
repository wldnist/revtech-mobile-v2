import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/screens/About.dart';
import 'package:gpspro/screens/Dashboard.dart';
import 'package:gpspro/screens/Devices.dart';
import 'package:gpspro/screens/MapHome.dart';
import 'package:gpspro/screens/Settings.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

import '../../traccar_gennissi.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

// ignore: unused_element
String _notificationToken = "";
IOWebSocketChannel? socketChannel;
AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // ti
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;
  //bool first = true;
  late SharedPreferences prefs;
  late Store<AppState> store;
  late String email;
  late String password;
  late Timer _timer;
  AppLifecycleState? _notification;
  bool loaded = false;
  List<String>? devicesId = [];

  //IOWebSocketChannel channel;

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  initState() {
    checkPreference();
    super.initState();
  }

  @override
  void dispose() {
    socketChannel!.sink.close();
    _timer.cancel();
    super.dispose();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email')!;
    password = prefs.getString('password')!;
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
            onDidReceiveLocalNotification: (id, title, body, payload) async {});
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
        onSelectNotification: (payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    });

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.getToken().then((value) => {_notificationToken = value!});
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await messaging.getToken().then((value) => {_notificationToken = value!});

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

  void updateData() {
    _timer = new Timer.periodic(Duration(seconds: 5), (timer) {
      Traccar.getDevices().then((value) => {
            store.dispatch(UpdateDeviceAction(value!)),
            Traccar.getLatestPositions().then((value) => {
                  {store.dispatch(UpdatePositionAction(value!))}
                }),
        getTrip(),
          });
    });
  }


  void getTrip(){
    String from;
    String to;

    DateTime current = DateTime.now();

    String month;
    String day;
    if (current.month < 10) {
      month = "0" + current.month.toString();
    } else {
      month = current.month.toString();
    }


    int dayCon = current.day;
    if (current.day < 10) {
      day = "0" + dayCon.toString();
    } else {
      day = dayCon.toString();
    }
    var start = DateTime.parse("${current.year}-"
        "$month-"
        "$day "
        "00:00:00");

    var end = DateTime.parse("${current.year}-"
        "$month-"
        "$day "
        "24:00:00");
    from = start.toUtc().toIso8601String();
    to = end.toUtc().toIso8601String();

    print(from);
    print(to);

    store.state.devices!.forEach((key, value) {
      devicesId!.add("deviceId="+value.id.toString());
    });

    Traccar.getAllDeviceEvents(devicesId!.join("&"), from, to).then((value) => {
      if(value != null){
        store.state.events!.clear(),
        store.state.events!.addAll(value),
      }
    });


    setState(() {

    });
  }

  void reConnectSocket() async {
    _timer = new Timer.periodic(Duration(seconds: 3), (timer) {
      connectSocket();
      _timer.cancel();
    });
  }

  void connectSocket() {
    var uri = Uri.parse(Traccar.serverURL!);
    String socketScheme, socketURL;
    if (uri.scheme == "http") {
      socketScheme = "ws://";
    } else {
      socketScheme = "wss://";
    }

    if (uri.hasPort) {
      socketURL =
          socketScheme + uri.host + ":" + uri.port.toString() + "/api/socket";
    } else {
      socketURL = socketScheme + uri.host + "/api/socket";
    }
    Map<int, Device> devices = new HashMap();
    socketChannel =
        new IOWebSocketChannel.connect(socketURL, headers: Traccar.headers);
    try {
      socketChannel!.stream.listen(
        (event) {
          var data = json.decode(event);
          if (data["events"] != null) {
            Iterable events = data["events"];
            List<Event> eventList =
                events.map((model) => Event.fromJson(model)).toList();
            int? deviceId = eventList[0].deviceId;
            String? name, result;

            if (deviceId! > 0) {
              if (devices[deviceId] != null) {
                name = devices[deviceId]!.name!;
              }
            } else {
              name = "Test";
              if (_notification != AppLifecycleState.paused) {
                localPushNotification("Test", "Test Message");
              }
            }

            if (eventList[0].attributes!.containsKey("result")) {
              result = eventList[0].attributes!["result"];
              localPushNotification(
                  name,
                  AppLocalizations.of(context)!.translate(eventList[0].type!) +
                      ":" +
                      result);
            } else {
              // result = "";
              // if (_notification != AppLifecycleState.paused) {
              //   localPushNotification(
              //       name,
              //       AppLocalizations.of(context)!
              //           .translate(eventList[0].type!));
              // }
            }
            //store.dispatch(AddEventsAction(eventList));
          }
        },
        onDone: () {
          socketChannel!.sink.close();
          if (prefs.get('email') != null) {
            reConnectSocket();
          }
        },
        onError: (error) {
          socketChannel!.sink.close();
          if (prefs.get('email') != null) {
            reConnectSocket();
          }
          print('ws error $error');
        },
      );
    } catch (e) {
      socketChannel!.sink.close();
      // reConnectSocket();
      // print("Socket Error" + e.toString());
    }
  }

  Future<void> localPushNotification(title, body) async {
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

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails("0", title,
            channelDescription: body,
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            styleInformation: BigTextStyleInformation(''));
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      onInit: (str) => str.dispatch({
        connectSocket(),
        Traccar.getDevices().then((value) => {
              if (value!.length > 0)
                {
                  str.state.devices!.clear(),
                  str.state.positions!.clear(),
                  str.state.events!.clear(),
                  str.dispatch(UpdateDeviceAction(value)),
                  store = str,
                  Traccar.getLatestPositions().then((value) => {
                        {store.dispatch(UpdatePositionAction(value!))}
                      }),
                  updateData(),
                },
              loaded = true,
            }),
      }),
      converter: (Store<AppState> store) => ViewModel.create(store),
      builder: (BuildContext context, ViewModel viewModel) => SafeArea(
          child: Scaffold(
        extendBody: true,
        body: loaded
            ? IndexedStack(
                index: _selectedIndex,
                children: <Widget>[
                  DevicePage(viewModel),
                  MapPage(viewModel),
                  DashboardPage(viewModel),
                  SettingsPage(viewModel),
                  AboutPage()
                ],
              )
            : Center(child: new CircularProgressIndicator()),
        bottomNavigationBar: CurvedNavigationBar(
          color: CustomColor.primaryColor,
          index: _selectedIndex,
          height: 50,
          backgroundColor: Colors.transparent,
          items: [
            Icon(Icons.directions_car_rounded,
                size: 25, color: CustomColor.secondaryColor),
            Icon(
              Icons.map,
              size: 25,
              color: CustomColor.secondaryColor,
            ),
            Icon(Icons.notifications,
                size: 25, color: CustomColor.secondaryColor),
            Icon(Icons.settings, size: 25, color: CustomColor.secondaryColor),
            Icon(Icons.info, size: 25, color: CustomColor.secondaryColor),
          ],
          animationDuration: Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            //Handle button tap
          },
        ),
      )),
    );
  }
}
