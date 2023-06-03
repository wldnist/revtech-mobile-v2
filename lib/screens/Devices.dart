import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gpspro/arguments/DeviceArguments.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/src/model/CommandModel.dart';
import 'package:gpspro/src/model/MaintenanceModel.dart';
import 'package:gpspro/model/bottomMenu.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/src/model/MaintenancePermModel.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';

class DevicePage extends StatefulWidget {
  final ViewModel model;

  DevicePage(this.model);

  @override
  State<StatefulWidget> createState() => new _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  TextEditingController controller = new TextEditingController();
  late List<Device> devicesList;
  List<Device> _searchResult = [];
  late Locale myLocale;
  String address = "Show Address";

  final TextEditingController _customCommand = new TextEditingController();
  List<String> _commands = <String>[];
  int _selectedCommand = 0;
  int _selectedperiod = 0;
  double _dialogHeight = 300.0;
  double _dialogCommandHeight = 150.0;

  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  TimeOfDay _selectedFromTime = TimeOfDay.now();
  TimeOfDay _selectedToTime = TimeOfDay.now();
  List<CommandModel> savedCommand = [];
  CommandModel _selectedSavedCommand = new CommandModel();

  SharedPreferences? prefs;
  List<BottomMenu> bottomMenu = [];
  User? user;
  String selectedIndex = "all";

  List<MaintenanceModel> selectedMaintenance = [];
  List<MaintenanceModel> maintenanceList = [];

  final Map<String, Widget> segmentMap = new LinkedHashMap();

  String getAddress(lat, lng) {
    if (lat != null) {
      Traccar.geocode(lat, lng).then((value) => {
            if (value != null)
              {
                address = utf8.decode(value.body.codeUnits),
                setState(() {}),
              }
            else
              {
                address = "Address not found",
                setState(() {}),
              }
          });
    } else {
      address = "Address not found";
      setState(() {});
    }
    return address;
  }

  @override
  void initState() {
    checkPreference();
    super.initState();
    fillBottomList();
  }

  void fillBottomList() {
    bottomMenu.add(new BottomMenu(
        title: "liveTracking",
        img: "icons/tracking.png",
        tapPath: "/trackDevice"));
    bottomMenu.add(new BottomMenu(
        title: "info", img: "icons/car.png", tapPath: "/deviceInfo"));
    bottomMenu.add(new BottomMenu(
        title: "playback", img: "icons/route.png", tapPath: "playback"));
    bottomMenu.add(new BottomMenu(
        title: "alarmGeofence",
        img: "icons/fence.png",
        tapPath: "/geofenceList"));
    bottomMenu.add(new BottomMenu(
        title: "report", img: "icons/report.png", tapPath: "report"));
    bottomMenu.add(new BottomMenu(
        title: "commandTitle", img: "icons/command.png", tapPath: "command"));
    bottomMenu.add(new BottomMenu(
        title: "alarmLock", img: "icons/lock.png", tapPath: "lock"));
    bottomMenu.add(new BottomMenu(
        title: "savedCommand", img: "icons/command.png", tapPath: "savedCommand"));
    //bottomMenu.add(new BottomMenu(title: "info", img: "icons/tracking.png", tapPath: ""));
    bottomMenu.add(new BottomMenu(title: "assignMaintenance", img: "icons/settings.png", tapPath: "assignMaintenance"));
  }

  void setLocale(locale) async {
    await Jiffy.locale(locale);
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs!.getString("user");
    final parsed = json.decode(userJson!);
    user = User.fromJson(parsed);
    setState(() {});
  }

  void maintenanceData(Device device, StateSetter setState){
    try {
      Traccar.getMaintenanceByDeviceId(device.id.toString()).then((value) => {
        selectedMaintenance.addAll(value!),
        Traccar.getMaintenance().then((val) => {
          val!.forEach((element) {
            if(selectedMaintenance.isNotEmpty) {
              if (selectedMaintenance
                  .singleWhere((e) => element.id == e.id)
                  .id == element.id) {
                print("true");
                element.enabled = true;
              } else {
                element.enabled = false;
              }
            }else{
              element.enabled = false;
            }
            maintenanceList.add(element);
          }),
          setState(() {

          })
        })
      });
    } catch (e) {
      print(e);
    }
  }

  void updateMaintenance(MaintenanceModel m, Device d){
    MaintenancePermModel mPM = MaintenancePermModel();
    mPM.deviceId = d.id;
    mPM.maintenanceId = m.id;

    var maintenancePerm = json.encode(mPM);
    Traccar.addPermission(maintenancePerm).then((value) => {

    });
  }

  void removeMaintenance(MaintenanceModel m, Device d){
    Traccar.deleteMaintenancePermission(d.id, m.id).then((value) => {

    });
  }

  @override
  Widget build(BuildContext context) {
    devicesList = widget.model.devices!.values.toList();
    myLocale = Localizations.localeOf(context);

    setLocale(myLocale.languageCode);

    segmentMap.putIfAbsent(
        "all",
        () => Text(
              AppLocalizations.of(context)!.translate("all"),
              style: TextStyle(fontSize: 11),
            ));
    segmentMap.putIfAbsent(
        "online",
        () => Text(
              AppLocalizations.of(context)!.translate("online"),
              style: TextStyle(fontSize: 11),
            ));
    segmentMap.putIfAbsent(
        "unknown",
        () => Text(
              AppLocalizations.of(context)!.translate("unknown"),
              style: TextStyle(fontSize: 11),
            ));
    segmentMap.putIfAbsent(
        "offline",
        () => Text(
              AppLocalizations.of(context)!.translate("offline"),
              style: TextStyle(fontSize: 11),
            ));

    onSearchTextChanged(String text) async {
      _searchResult.clear();

      if (text.toLowerCase().isEmpty) {
        setState(() {});
        return;
      }

      devicesList.forEach((device) {
        if (device.name!.toLowerCase().contains(text.toLowerCase())) {
          _searchResult.add(device);
        }
      });
      setState(() {});
    }

    deviceListFilter(String filterVal) async {
      _searchResult.clear();

      if (filterVal == "all") {
        setState(() {});
        return;
      }

      devicesList.forEach((device) {
        if (device.status!.contains(filterVal)) {
          if (device.status == filterVal) {
            _searchResult.add(device);
          }
        }
      });

      setState(() {});
    }

    return Scaffold(
        // appBar: AppBar(
        //   title: Text(AppLocalizations.of(context).translate('deviceTitle'), style: TextStyle(color: CustomColor.secondaryColor)),
        // ),
        body: new Column(children: <Widget>[
      new Container(
        child: new Padding(
          padding: const EdgeInsets.all(1.0),
          child: new Card(
            child: new ListTile(
              leading: new Icon(Icons.search),
              title: new TextField(
                controller: controller,
                decoration: new InputDecoration(
                    hintText: AppLocalizations.of(context)!.translate('search'),
                    border: InputBorder.none),
                onChanged: onSearchTextChanged,
              ),
              trailing: user != null
                  ? user!.deviceReadonly!
                  ? new IconButton(
                icon: new Icon(Icons.cancel),
                onPressed: () {
                  controller.clear();
                  onSearchTextChanged('');
                },
              )
                  :FloatingActionButton(
                heroTag: "addButton",
                onPressed: () {
                  Navigator.pushNamed(context, "/addDevice");
                },
                mini: true,
                child: const Icon(Icons.add),
                backgroundColor: CustomColor.primaryColor,
              )
                  : new IconButton(
                icon: new Icon(Icons.cancel),
                onPressed: () {
                  controller.clear();
                  onSearchTextChanged('');
                },
              ),
            ),
          ),
        ),
      ),
      Padding(padding: EdgeInsets.all(3)),
      SizedBox(
        width: 500.0,
        child: CupertinoSegmentedControl<String>(
          children: segmentMap,
          selectedColor: CustomColor.primaryColor,
          unselectedColor: CustomColor.secondaryColor,
          groupValue: selectedIndex,
          onValueChanged: (String val) {
            setState(() {
              selectedIndex = val;
              deviceListFilter(val);
            });
          },
        ),
      ),
      // prefs != null ?
      //   prefs!.getBool("ads")
      //     ? FacebookBannerAd(
      //         placementId: Platform.isAndroid
      //             ? "3494927727220020_3855926827786773"
      //             : "906033339935537_990519234820280",
      //         bannerSize: BannerSize.STANDARD,
      //       )
      //     : new Container() : new Container(),
      Padding(padding: EdgeInsets.all(3)),
      new Expanded(
          child: _searchResult.length != 0 || controller.text.isNotEmpty
              ? new ListView.builder(
                  itemCount: _searchResult.length,
                  itemBuilder: (context, index) {
                    final device = _searchResult[index];
                    return deviceCard(device, context);
                  },
                )
              : selectedIndex == "all"
                  ? new ListView.builder(
                      itemCount: devicesList.length,
                      itemBuilder: (context, index) {
                        final device = devicesList[index];
                        return deviceCard(device, context);
                      })
                  : new ListView.builder(
                      itemCount: 0,
                      itemBuilder: (context, index) {
                        return Text(AppLocalizations.of(context)!
                            .translate("noDeviceFound"));
                      })),
    ]));
  }

  Widget deviceCard(Device device, BuildContext context) {
    Color color;

    if (device.status == "online") {
      color = Colors.green;
    } else if (device.status == "unknown") {
      color = Colors.yellow;
    } else {
      color = Colors.red;
    }

    String fLastUpdate = AppLocalizations.of(context)!.translate('noData');
    if (device.lastUpdate != null) {
      fLastUpdate = formatTime(device.lastUpdate!);
    }

    double subtext = 13;
    double title = 14;

    return new Card(
      elevation: 1.0,
      shadowColor: color.withOpacity(0.5),
      color: color.withOpacity(0.1),
      child: Padding(
          padding: new EdgeInsets.all(10.0),
          child: Column(children: <Widget>[
            InkWell(
              onTap: () {
                address = "Show Address";
                FocusScope.of(context).unfocus();
                onSheetShowContents(context, device);
              },
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Row(children: <Widget>[
                            Icon(Icons.radio_button_checked,
                                color: color, size: 18.0),
                            Padding(
                                padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.60,
                                child: Text(
                                    utf8.decode(device.name!.codeUnits),
                                  style: TextStyle(
                                      fontSize: title,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ]),
                          new Row(children: <Widget>[
                            widget.model.positions!.containsKey(device.id)
                                ? widget.model.positions![device.id]!
                                        .attributes!
                                        .containsKey("ignition")
                                    ? widget.model.positions![device.id]!
                                            .attributes!["ignition"]
                                        ? Icon(Icons.vpn_key,
                                            color: CustomColor.onColor,
                                            size: 18.0)
                                        : Icon(Icons.vpn_key,
                                            color: CustomColor.offColor,
                                            size: 18.0)
                                    : Icon(Icons.vpn_key,
                                        color: CustomColor.offColor, size: 18.0)
                                : new Container(),
                            widget.model.positions!.containsKey(device.id)
                                ? widget.model.positions![device.id]!
                                        .attributes!
                                        .containsKey("charge")
                                    ? widget.model.positions![device.id]!
                                            .attributes!["charge"]
                                        ? Icon(Icons.battery_charging_full,
                                            color: CustomColor.onColor,
                                            size: 18.0)
                                        : Icon(Icons.battery_std,
                                            color: CustomColor.offColor,
                                            size: 18.0)
                                    : Icon(Icons.battery_std,
                                        color: CustomColor.offColor, size: 18.0)
                                : new Container(),
                            widget.model.positions!.containsKey(device.id)
                                ? widget.model.positions![device.id]!
                                        .attributes!
                                        .containsKey("batteryLevel")
                                    ? Text(
                                        widget.model.positions![device.id]!
                                                .attributes!["batteryLevel"]
                                                .toString() +
                                            "%",
                                        style: TextStyle(
                                            color: CustomColor.primaryColor,
                                            fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text("")
                                : new Container()
                          ]),
                        ]),
                    new Row(children: <Widget>[
                      Icon(Icons.speed, color: color, size: 18.0),
                      Padding(padding: new EdgeInsets.fromLTRB(5, 5, 0, 0)),
                      widget.model.positions!.containsKey(device.id)
                          ? Text(
                              device.status![0].toUpperCase() +
                                  device.status!.substring(1) +
                                  " " +
                                  convertSpeed(widget
                                      .model.positions![device.id]!.speed!),
                              style: TextStyle(fontSize: subtext),
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              device.status![0].toUpperCase() +
                                  device.status!.substring(1),
                              style: TextStyle(fontSize: subtext),
                              overflow: TextOverflow.ellipsis),
                    ]),
                    widget.model.positions!.containsKey(device.id)
                        ? widget.model.positions![device.id]!.address != null
                            ? new Row(children: <Widget>[
                                Icon(Icons.location_on_outlined,
                                    color: color, size: 18.0),
                                Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Container(
                                        child: Text(
                                          utf8.decode(widget.model.positions![device.id]!
                                              .address!.codeUnits),
                                          style: TextStyle(fontSize: subtext),
                                          textAlign: TextAlign.left,
                                          maxLines: 2,
                                        ),
                                      )
                                    ]))
                              ])
                            : new Container()
                        : new Container(),
                    new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              Icon(Icons.timer_rounded,
                                  color: color, size: 18.0),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(5, 5, 0, 0)),
                              Text(
                                fLastUpdate,
                                style: TextStyle(fontSize: subtext),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Text(
                            Jiffy(device.lastUpdate).fromNow(),
                            style: TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          )
                        ])
                  ],
                ),
              ),
            ),
          ])),
    );
  }

  void onSheetShowContents(BuildContext context, Device device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.40,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          ),
        ),
        child: bottomSheetContent(device),
      ),
    );
  }

  Widget bottomSheetContent(Device device) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(5)),
          Center(
            child: Container(
              width: 100,
              padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                device.name!,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              )),
          Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: CustomColor.primaryColor,
                  ),
                  GestureDetector(
                      onTap: () {
                        address = "Loading....";
                        setState(() {});
                        getAddress(
                            widget.model.positions![device.id]!.latitude
                                .toString(),
                            widget.model.positions![device.id]!.longitude
                                .toString());
                      },
                      child: Text(
                        address,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ))
                ],
              )),
          Divider(),
          Padding(padding: EdgeInsets.all(3)),
          // ConstrainedBox(
          //   constraints: BoxConstraints.tightFor(width: 250, height: 40),
          //   child: ElevatedButton.icon(
          //     icon: Icon(
          //       Icons.my_location_sharp,
          //       size: 15,
          //     ),
          //     onPressed: () {
          //       FocusScope.of(context).unfocus();
          //       Navigator.pushNamed(context, "/trackDevice",
          //           arguments:
          //               DeviceArguments(device.id!, device.name!, device));
          //     },
          //     label:
          //         Text(AppLocalizations.of(context)!.translate('trackDevice')),
          //   ),
          // ),
          Flexible(child: bottomButton(device))
        ],
      ),
    );
  }

  Widget bottomButton(Device device) {
    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(1.0),
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      children: List.generate(9, (index) {
        final menu = bottomMenu[index];
        return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              if (menu.tapPath == "/trackDevice") {
                Navigator.pushNamed(context, menu.tapPath,
                    arguments:
                        DeviceArguments(device.id!, device.name!, device));
              } else if (menu.tapPath == "/deviceInfo") {
                Navigator.pushNamed(context, menu.tapPath,
                    arguments:
                        DeviceArguments(device.id!, device.name!, device));
              } else if (menu.tapPath == "playback") {
                showReportDialog(
                    context,
                    AppLocalizations.of(context)!.translate('playback'),
                    device);
              } else if (menu.tapPath == "/geofenceList") {
                Navigator.pushNamed(context, menu.tapPath,
                    arguments: ReportArguments(
                        device.id!, "", "", device.name!, device));
              } else if (menu.tapPath == "report") {
                showReportDialog(context, "report", device);
              } else if (menu.tapPath == "command") {
                showCommandDialog(context, device);
              } else if (menu.tapPath == "lock") {
                _showEngineOnOFF(device);
              }else if (menu.tapPath == "savedCommand") {
                showSavedCommandDialog(context, device);
              }
              else if (menu.tapPath == "assignMaintenance") {
                if(maintenanceList.isNotEmpty) {
                  showMaintenanceDialog(context, device);
                }else{
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.translate("noData"),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              }
            },
            child: Column(
              children: [
                Image.asset(
                  menu.img,
                  width: 30,
                ),
                Padding(padding: EdgeInsets.all(7)),
                Text(
                  AppLocalizations.of(context)!.translate(menu.title),
                  style: TextStyle(fontSize: 10),
                )
              ],
            ));
      }),
    );
  }


  void showMaintenanceDialog(BuildContext context, Device device){
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              if(maintenanceList.isEmpty) {
                setState(() {
                  maintenanceData(device, setState);
                });
              }
              return new ListView.builder(
                itemCount: maintenanceList.length,
                itemBuilder: (context, index) {
                  final m = maintenanceList[index];
                  return maintenanceCard(m, context, setState, device);
                },
              );
            }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  Widget maintenanceCard(MaintenanceModel m, BuildContext context, StateSetter setState, Device device){
    return ListTile(
      leading: Checkbox(
        value: m.enabled,
        onChanged: (val){
          setState(() {
            m.enabled = val;
          });
          if(val!) {
            updateMaintenance(m, device);
          }else{
            removeMaintenance(m, device);
          }
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(m.name!,
              style: TextStyle(
                  fontSize: 13.0, fontWeight: FontWeight.bold)),
          Divider()
        ],
      ),
    );
  }

  void showSavedCommandDialog(BuildContext context, device) {
    savedCommand.clear();
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              try {
                Traccar.getSavedCommands(device.id).then((value) => {

                  if (value != null)
                    {
                      if (savedCommand.length == 0)
                        {
                          if(value.length > 0){
                            _selectedSavedCommand = value[0],
                          },
                          value.forEach((element) {
                            savedCommand.add(element);
                          }),
                        },
                      setState(() {})
                    }
                  else
                    {},
                  setState(() {})
                });
              } catch (e) {
                print(e);
              }
              return Container(
                height: _dialogCommandHeight,
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    savedCommand.length > 0 ?
                    Column(
                      children: <Widget>[
                        Padding(
                          padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(AppLocalizations.of(context)!
                                      .translate('commandTitle')),
                                ],
                              ),
                              new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new DropdownButton<CommandModel>(
                                      hint: new Text(_selectedSavedCommand.description!),
                                      items: savedCommand.map((CommandModel value) {
                                        return new DropdownMenuItem<CommandModel>(
                                          value: value,
                                          child: new Text(
                                           value.description!,
                                            style: TextStyle(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedSavedCommand = value!;
                                        });
                                      },
                                    )
                                  ]),
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red, // background
                                      onPrimary: Colors.white, // foreground
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .translate('cancel'),
                                      style: TextStyle(
                                          fontSize: 18.0, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      sendSavedCommand(device);
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.translate('ok'),
                                      style: TextStyle(
                                          fontSize: 18.0, color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ) :CircularProgressIndicator()
                  ],
                ),
              );
            }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  void sendSavedCommand(Device device) {
    Command command = Command();
    command.deviceId = device.id.toString();
    command.type = "custom";
    command.attributes = _selectedSavedCommand.attributes;

    String request = json.encode(command.toJson());

    Traccar.sendCommands(request).then((res) => {
      if (res.statusCode == 200)
        {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.translate('command_sent'),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0),
          Navigator.of(context).pop()
        }
      else
        {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.translate('errorMsg'),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0),
          Navigator.of(context).pop()
        }
    });
  }

  void showReportDialog(BuildContext context, String heading, Device device) {
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return new Container(
            height: _dialogHeight,
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Radio(
                                value: 0,
                                groupValue: _selectedperiod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedperiod =
                                        int.parse(value.toString());
                                    _dialogHeight = 300.0;
                                  });
                                },
                              ),
                              new Text(
                                AppLocalizations.of(context)!
                                    .translate('reportToday'),
                                style: new TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Radio(
                                value: 1,
                                groupValue: _selectedperiod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedperiod =
                                        int.parse(value.toString());
                                    _dialogHeight = 300.0;
                                  });
                                },
                              ),
                              new Text(
                                AppLocalizations.of(context)!
                                    .translate('reportYesterday'),
                                style: new TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Radio(
                                value: 2,
                                groupValue: _selectedperiod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedperiod =
                                        int.parse(value.toString());
                                    _dialogHeight = 300.0;
                                  });
                                },
                              ),
                              new Text(
                                AppLocalizations.of(context)!
                                    .translate('reportThisWeek'),
                                style: new TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Radio(
                                value: 3,
                                groupValue: _selectedperiod,
                                onChanged: (value) {
                                  setState(() {
                                    _dialogHeight = 400.0;
                                    _selectedperiod =
                                        int.parse(value.toString());
                                  });
                                },
                              ),
                              new Text(
                                AppLocalizations.of(context)!
                                    .translate('reportCustom'),
                                style: new TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          _selectedperiod == 3
                              ? new Container(
                                  child: new Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        ElevatedButton(
                                          onPressed: () => _selectFromDate(
                                              context, setState),
                                          child: Text(
                                              formatReportDate(
                                                  _selectedFromDate),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _selectFromTime(
                                              context, setState),
                                          child: Text(
                                              formatReportTime(
                                                  _selectedFromTime),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        ElevatedButton(
                                          onPressed: () =>
                                              _selectToDate(context, setState),
                                          child: Text(
                                              formatReportDate(_selectedToDate),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _selectToTime(context, setState),
                                          child: Text(
                                              formatReportTime(_selectedToTime),
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    )
                                  ],
                                ))
                              : new Container(),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red, // background
                                  onPrimary: Colors.white, // foreground
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('cancel'),
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  showReport(heading, device);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.translate('ok'),
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  Future<void> _selectFromDate(
      BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedFromDate)
      setState(() {
        _selectedFromDate = picked;
      });
  }

  Future<void> _selectToDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedToDate)
      setState(() {
        _selectedToDate = picked;
      });
  }

  Future<void> _selectFromTime(
      BuildContext context, StateSetter setState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child != null ? child : new Container(),
        );
      },
    );
    if (picked != null && picked != _selectedFromTime)
      setState(() {
        _selectedFromTime = picked;
      });
  }

  Future<void> _selectToTime(BuildContext context, setState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child != null ? child : new Container(),
        );
      },
    );
    if (picked != null && picked != _selectedToTime)
      setState(() {
        _selectedToTime = picked;
      });
  }

  void showCommandDialog(BuildContext context, Device device) {
    _commands.clear();

    // if (_commands[_selectedCommand] == "custom") {
    //   _dialogCommandHeight = 220.0;
    // }

    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          Iterable list;
          try {
            Traccar.getSendCommands(device.id.toString()).then((value) => {
                  // ignore: unnecessary_null_comparison
                  if (value.body != null)
                    {
                      list = json.decode(value.body),
                      if (_commands.length == 0)
                        {
                          list.forEach((element) {
                            if (list.length == 1) {
                              _dialogCommandHeight = 200;
                            }
                            _commands.add(element["type"]);
                          })
                        }
                    }
                  else
                    {},
                  setState(() {})
                });
          } catch (e) {
            print(e);
          }
          return Container(
            height: _dialogCommandHeight,
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _commands.length > 0
                    ? Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(AppLocalizations.of(context)!
                                        .translate('commandTitle')),
                                  ],
                                ),
                                new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new DropdownButton<String>(
                                        hint: new Text(
                                            AppLocalizations.of(context)!
                                                .translate('select_command')),
                                        // ignore: unnecessary_null_comparison
                                        value: _selectedCommand == null
                                            ? null
                                            : _commands[_selectedCommand],
                                        items: _commands.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(
                                              AppLocalizations.of(context)!
                                                          .translate(value) !=
                                                      null
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .translate(value)
                                                  : value,
                                              style: TextStyle(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == "custom") {
                                              _dialogCommandHeight = 250.0;
                                            } else {
                                              _dialogCommandHeight = 150.0;
                                            }
                                            _selectedCommand =
                                                _commands.indexOf(value!);
                                          });
                                        },
                                      )
                                    ]),
                                _commands[_selectedCommand] == "custom"
                                    ? new Container(
                                        child: new TextField(
                                          controller: _customCommand,
                                          decoration: new InputDecoration(
                                              labelText: AppLocalizations.of(
                                                      context)!
                                                  .translate('commandCustom')),
                                        ),
                                      )
                                    : new Container(),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red, // background
                                        onPrimary: Colors.white, // foreground
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('cancel'),
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        sendCommand(device);
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('ok'),
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    : new CircularProgressIndicator(),
              ],
            ),
          );
        }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  void sendCommand(Device device) {
    Map<String, dynamic> attributes = new HashMap();
    if (_commands[_selectedCommand] == "custom") {
      attributes.putIfAbsent("data", () => _customCommand.text);
    } else {
      attributes.putIfAbsent("data", () => _commands[_selectedCommand]);
    }

    Command command = Command();
    command.deviceId = device.id.toString();
    command.type = _commands[_selectedCommand];
    command.attributes = attributes;

    String request = json.encode(command.toJson());

    Traccar.sendCommands(request).then((res) => {
          if (res.statusCode == 200)
            {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.translate('command_sent'),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
          else
            {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.translate('errorMsg'),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
        });
  }

  void showReport(String heading, Device device) {
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

    if (current.day < 10) {
      day = "0" + current.day.toString();
    } else {
      day = current.day.toString();
    }

    if (_selectedperiod == 0) {
      var date = DateTime.parse("${current.year}-"
          "$month-"
          "$day "
          "00:00:00");
      from = date.toUtc().toIso8601String();
      to = DateTime.now().toUtc().toIso8601String();
    } else if (_selectedperiod == 1) {
      String yesterday;

      int dayCon = current.day - 1;
      if (current.day <= 10) {
        yesterday = "0" + dayCon.toString();
      } else {
        yesterday = dayCon.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$yesterday "
          "00:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$yesterday "
          "24:00:00");

      from = start.toUtc().toIso8601String();
      to = end.toUtc().toIso8601String();
    } else if (_selectedperiod == 2) {
      String sevenDay, currentDayString;
      int dayCon = current.day - current.weekday;
      int currentDay = current.day;
      if (dayCon < 10) {
        sevenDay = "0" + dayCon.toString();
      } else {
        sevenDay = dayCon.toString();
      }
      if (currentDay < 10) {
        currentDayString = "0" + currentDay.toString();
      } else {
        currentDayString = currentDay.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$sevenDay "
          "24:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$currentDayString "
          "24:00:00");

      from = start.toUtc().toIso8601String();
      to = end.toUtc().toIso8601String();
    } else {
      String startMonth, endMoth;
      if (_selectedFromDate.month < 10) {
        startMonth = "0" + _selectedFromDate.month.toString();
      } else {
        startMonth = _selectedFromDate.month.toString();
      }

      if (_selectedToDate.month < 10) {
        endMoth = "0" + _selectedToDate.month.toString();
      } else {
        endMoth = _selectedToDate.month.toString();
      }

      String startHour, endHour;
      if (_selectedFromTime.hour < 10) {
        startHour = "0" + _selectedFromTime.hour.toString();
      } else {
        startHour = _selectedFromTime.hour.toString();
      }

      String startMin, endMin;
      if (_selectedFromTime.minute < 10) {
        startMin = "0" + _selectedFromTime.minute.toString();
      } else {
        startMin = _selectedFromTime.minute.toString();
      }

      if (_selectedFromTime.minute < 10) {
        endMin = "0" + _selectedToTime.minute.toString();
      } else {
        endMin = _selectedToTime.minute.toString();
      }

      if (_selectedToTime.hour < 10) {
        endHour = "0" + _selectedToTime.hour.toString();
      } else {
        endHour = _selectedToTime.hour.toString();
      }

      String startDay, endDay;
      if (_selectedFromDate.day < 10) {
        if (_selectedFromDate.day == 10) {
          startDay = _selectedFromDate.day.toString();
        } else {
          startDay = "0" + _selectedFromDate.day.toString();
        }
      } else {
        startDay = _selectedFromDate.day.toString();
      }

      if (_selectedToDate.day < 10) {
        if (_selectedToDate.day == 10) {
          endDay = _selectedToDate.day.toString();
        } else {
          endDay = "0" + _selectedToDate.day.toString();
        }
      } else {
        endDay = _selectedToDate.day.toString();
      }

      var start = DateTime.parse("${_selectedFromDate.year}-"
          "$startMonth-"
          "$startDay "
          "$startHour:"
          "$startMin:"
          "00");

      var end = DateTime.parse("${_selectedToDate.year}-"
          "$endMoth-"
          "$endDay "
          "$endHour:"
          "$endMin:"
          "00");

      from = start.toUtc().toIso8601String();
      to = end.toUtc().toIso8601String();
    }

    Navigator.pop(context);
    if (heading == "report") {
      Navigator.pushNamed(context, "/reportList",
          arguments:
              ReportArguments(device.id!, from, to, device.name!, device));
    } else {
      Navigator.pushNamed(context, "/playback",
          arguments:
              ReportArguments(device.id!, from, to, device.name!, device));
    }
  }

  Future<void> _showEngineOnOFF(Device device) async {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.translate('cancel')),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget onButton = TextButton(
      child: Text(AppLocalizations.of(context)!.translate('on')),
      onPressed: () {
        sendLockCommand('engineResume', device);
      },
    );
    Widget offButton = TextButton(
      child: Text(AppLocalizations.of(context)!.translate('off')),
      onPressed: () {
        sendLockCommand('engineStop', device);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.translate('fuelCutOff')),
      content: Text(AppLocalizations.of(context)!.translate('areYouSure')),
      actions: [
        cancelButton,
        onButton,
        offButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void sendLockCommand(String commandTxt, Device device) {
    Command command = Command();
    command.deviceId = device.id.toString();
    command.type = commandTxt;

    String request = json.encode(command.toJson());

    Traccar.sendCommands(request).then((res) => {
          if (res.statusCode == 200)
            {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.translate('command_sent'),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
          else
            {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.translate('errorMsg'),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0),
              Navigator.of(context).pop()
            }
        });
  }
}
