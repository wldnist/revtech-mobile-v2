import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpspro/arguments/FenceArguments.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';

class GeofenceListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GeofenceListPageState();
}

class _GeofenceListPageState extends State<GeofenceListPage> {
  ReportArguments? args;
  late GoogleMapController mapController;
  late Timer _timer;
  bool addFenceVisible = false;
  bool deleteFenceVisible = false;
  bool addClicked = false;
  late SharedPreferences prefs;
  late User user;
  late int deleteFenceId;
  bool isLoading = false;
  List<GeofenceModel> fenceList = [];
  List<int> selectedFenceList = [];

  late Marker newFenceMarker;

  @override
  initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString("user");

    final parsed = json.decode(userJson!);
    user = User.fromJson(parsed);
    getFences();
    setState(() {});
  }

  void removeFence(id) {
    _showProgress(true);
    Traccar.deletePermission(args!.device.id, id).then((value) => {
          if (value.statusCode == 204)
            {
              fenceList.clear(),
              selectedFenceList.clear(),
              getFences(),
              setState(() {
                Fluttertoast.showToast(
                    msg:
                        AppLocalizations.of(context)!.translate("fenceDeleted"),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }),
              _showProgress(false),
            }
          else
            {
              _showProgress(false),
            }
        });
  }

  void deleteFence(id) {
    _showProgress(true);
    Traccar.deleteGeofence(id).then((value) => {
          if (value.statusCode == 204)
            {
              _showProgress(false),
              Navigator.of(context).pop(false),
              fenceList.clear(),
              selectedFenceList.clear(),
              getFences(),
              setState(() {
                Fluttertoast.showToast(
                    msg:
                        AppLocalizations.of(context)!.translate("fenceDeleted"),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }),
            }
          else
            {
              _showProgress(false),
            }
        });
  }

  void updateFence(id) {
    _showProgress(true);
    fenceList.clear();
    selectedFenceList.clear();
    GeofencePermModel permissionModel = new GeofencePermModel();
    permissionModel.deviceId = args!.device.id;
    permissionModel.geofenceId = id;

    var perm = json.encode(permissionModel);
    Traccar.addPermission(perm.toString()).then((value) => {
          if (value.statusCode == 204)
            {
              fenceList.clear(),
              selectedFenceList.clear(),
              getFences(),
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!
                      .translate("fenceAddedSuccessfully"),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0),
              _showProgress(false),
            }
          else
            {
              _showProgress(false),
            }
        });
  }

  void getFences() async {
    _showProgress(true);
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (args != null) {
        Traccar.getGeoFencesByUserID(user.id.toString()).then((value) => {
              _timer.cancel(),
              if (value!.length > 0)
                {
                  fenceList.addAll(value),
                  getSelectedFenceList(),
                  setState(() {}),
                }
              else
                {
                  isLoading = false,
                  setState(() {}),
                  _showProgress(false),
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.translate("noFence"),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0)
                },
            });
      }
    });
  }

  void getSelectedFenceList() {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (args != null) {
        Traccar.getGeoFencesByDeviceID(args!.id.toString()).then((value) => {
              _timer.cancel(),
              if (value!.length > 0)
                {
                  value.forEach((element) {
                    selectedFenceList.add(element.id!);
                  }),
                  _showProgress(false),
                  setState(() {}),
                }
              else
                {
                  isLoading = false,
                  setState(() {}),
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.translate("noFence"),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0)
                },
            });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // ignore: unnecessary_null_comparison
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as ReportArguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(args!.name,
            style: TextStyle(color: CustomColor.secondaryColor)),
        iconTheme: IconThemeData(
          color: CustomColor.secondaryColor, //change your color here
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/geofenceAdd",
                  arguments: FenceArguments(
                      new GeofenceModel(), args!.id, args!.name));
            },
            child: Icon(Icons.add),
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
        ],
      ),
      body: new Column(children: <Widget>[
        new Expanded(
            child: new ListView.builder(
                itemCount: fenceList.length,
                itemBuilder: (context, index) {
                  final fence = fenceList[index];
                  return fenceCard(fence, context);
                }))
      ]),
    );
  }

  Widget fenceCard(GeofenceModel fence, BuildContext context) {
    return new Card(
        elevation: 2.0,
        child: Padding(
            padding: new EdgeInsets.all(10.0),
            child: Column(children: <Widget>[
              InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "/geofence",
                        arguments: FenceArguments(fence, args!.id, args!.name));
                  },
                  child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text(
                                fence.name!,
                                style: TextStyle(fontSize: 16),
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Checkbox(
                                        // ignore: unnecessary_null_comparison
                                        value: selectedFenceList != null
                                            ? selectedFenceList
                                                    .contains(fence.id)
                                                ? true
                                                : false
                                            : false,
                                        onChanged: (value) {
                                          if (value != null) {
                                            if (value) {
                                              updateFence(fence.id);
                                            } else {
                                              removeFence(fence.id);
                                            }
                                          }
                                        }),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        deleteFenceConfirm(fence.id);
                                      },
                                    )
                                  ])
                            ])
                      ])))
            ])));
  }

  Future<void> _showProgress(bool status) async {
    if (status) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: [
                CircularProgressIndicator(),
                Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(AppLocalizations.of(context)!
                        .translate('sharedLoading'))),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<dynamic> deleteFenceConfirm(dynamic id) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Fence'),
        content: Text('Are you sure?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () => {deleteFence(id)},
            /*Navigator.of(context).pop(true)*/
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
