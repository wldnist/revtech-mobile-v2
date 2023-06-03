import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpspro/arguments/FenceArguments.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/ui/custom_icon.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';
import 'CommonMethod.dart';

class GeofenceAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _GeofenceAddPageState();
}

class _GeofenceAddPageState extends State<GeofenceAddPage> {
  FenceArguments? args;
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;
  Color _trafficButtonColor = CustomColor.primaryColor;
  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  double _valRadius = 100;
  double _valRadiusMax = 10000;
  bool addFenceVisible = false;
  bool deleteFenceVisible = false;
  bool addClicked = false;
  final TextEditingController _fenceName = new TextEditingController();
  late LatLng _position;
  late SharedPreferences prefs;
  late User user;
  late int deleteFenceId;
  bool isLoading = false;

  late Marker newFenceMarker;
  Device device = Device();
  bool pageDestoryed = false;

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
    setState(() {});
  }

  Future<BitmapDescriptor> _myPainterToBitmap(String label, String icon) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    CustomIcon myPainter = CustomIcon(label, icon);

    final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 30, color: Colors.black),
        ),
        textDirection: TextDirection.ltr);
    textPainter.layout();

    myPainter.paint(canvas,
        Size(textPainter.size.width + 30, textPainter.size.height + 25));
    final ui.Image image = await recorder.endRecording().toImage(
        textPainter.size.width.toInt() + 30,
        textPainter.size.height.toInt() + 25 + 50);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List data = byteData!.buffer.asUint8List();
    setState(() {});
    return BitmapDescriptor.fromBytes(data);
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    mapController.animateCamera(CameraUpdate.zoomTo(4));
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _trafficEnabledPressed() {
    setState(() {
      _trafficEnabled = _trafficEnabled == false ? true : false;
      _trafficButtonColor =
          _trafficEnabled == false ? CustomColor.primaryColor : Colors.green;
    });
  }

  void addFenceMarker() {
    if (addClicked) {
      setState(() {
        _myPainterToBitmap(
                AppLocalizations.of(context)!.translate('newFence'), "marker")
            .then((BitmapDescriptor bitmapDescriptor) {
          _markers.add(Marker(
            markerId: MarkerId("marker"),
            position: _position,
            icon: bitmapDescriptor,
            anchor: Offset(0.5, 1),
            draggable: true,
            onDragEnd: (value) {},
          ));
          updateNewCircle(_valRadius);
          addFenceVisible = true;
          mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: _position, zoom: 15)));
        });
      });
    }
  }

  void updateMarker(PositionModel pos) async {
    var iconPath;

    if (device.category != null) {
      if (device.status == "unknown") {
        iconPath = "images/marker_" + device.category! + "_static.png";
      } else {
        iconPath =
            "images/marker_" + device.category! + "_" + device.status! + ".png";
      }
    } else {
      if (device.status == "unknown") {
        iconPath = "images/marker_default_static.png";
      } else {
        iconPath = "images/marker_default_" + device.status! + ".png";
      }
    }
    final Uint8List? markerIcon = await getBytesFromAsset(iconPath, 100);

    CameraPosition cPosition = CameraPosition(
      target: LatLng(pos.latitude!, pos.longitude!),
      zoom: 14.0,
    );

    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(cPosition));

    _markers = Set<Marker>();

    var pinPosition = LatLng(pos.latitude!, pos.longitude!);
    //_markers.removeWhere((m) => m.markerId.value == pos.deviceId.toString());

    _markers.add(Marker(
      markerId: MarkerId(pos.deviceId.toString()),
      position: pinPosition,
      rotation: pos.course!,
      icon: BitmapDescriptor.fromBytes(markerIcon!),
    ));
  }

  @override
  void dispose() {
    pageDestoryed = true;
    super.dispose();
  }

  void updateNewCircle(radius) {
    _circles = Set<Circle>();
    setState(() {
      _circles.add(Circle(
          circleId: CircleId("circle"),
          fillColor: Color(0x40189ad3),
          strokeColor: Color(0),
          strokeWidth: 2,
          center: _position,
          radius: radius));
    });
  }

  void submitFence() {
    _showProgress(true);
    String pos = "CIRCLE (" +
        _circles.first.center.latitude.toString() +
        " " +
        _circles.first.center.longitude.toString() +
        ", " +
        _valRadius.toString() +
        ")";

    GeofenceModel fence = new GeofenceModel();
    fence.id = -1;
    fence.area = pos;
    fence.attributes = {};
    fence.calendarId = 0;
    fence.description = "";
    fence.name = _fenceName.text;

    var fenceCon = json.encode(fence);
    GeofenceModel fenceObj;
    Traccar.addGeofence(fenceCon.toString()).then((value) => {
          fenceObj = GeofenceModel.fromJson(json.decode(value.body)),
          updateFence(fenceObj.id)
        });
  }

  void updateFence(id) {
    GeofencePermModel permissionModel = new GeofencePermModel();
    permissionModel.deviceId = args!.deviceId;
    permissionModel.geofenceId = id;

    var perm = json.encode(permissionModel);
    Traccar.addPermission(perm.toString()).then((value) => {
          if (value.statusCode == 204)
            {
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
              Navigator.pop(context)
            }
          else
            {
              _showProgress(false),
            }
        });
  }

  static final CameraPosition _initialRegion = CameraPosition(
    target: LatLng(0, 0),
    zoom: 3,
  );

  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as FenceArguments;

    return StoreConnector<AppState, ViewModel>(
      converter: (Store<AppState> store) => ViewModel.create(store),
      builder: (BuildContext context, ViewModel viewModel) => SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                    args != null
                        ? args!.name
                        : AppLocalizations.of(context)!
                            .translate("sharedLoading"),
                    style: TextStyle(color: CustomColor.secondaryColor)),
                iconTheme: IconThemeData(
                  color: CustomColor.secondaryColor, //change your color here
                ),
              ),
              body: buildMap(viewModel))),
    );
  }

  Widget buildMap(ViewModel viewModel) {
    device = viewModel.devices![args!.deviceId] as Device;
    if (viewModel.positions!.containsKey(args!.deviceId)) {
      if (!pageDestoryed) {
        if (_markers.isEmpty) {
          updateMarker(viewModel.positions![args!.deviceId] as PositionModel);
        }
      }
      return Scaffold(
        body: Stack(children: <Widget>[
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _initialRegion,
            onTap: (pos) {
              _position = pos;
              addClicked = true;
              addFenceMarker();
            },
            trafficEnabled: _trafficEnabled,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              isLoading = true;
            },
            markers: _markers,
            circles: _circles,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 55, 5, 0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: _onMapTypeButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: CustomColor.primaryColor,
                    child: const Icon(Icons.map, size: 30.0),
                    mini: true,
                  ),
                  FloatingActionButton(
                    heroTag: "traffic",
                    onPressed: _trafficEnabledPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: _trafficButtonColor,
                    mini: true,
                    child: const Icon(Icons.traffic, size: 30.0),
                  ),
                ],
              ),
            ),
          ),
          addFenceVisible ? addFenceControls() : new Container()
        ]),
      );
    } else {
      return new Container();
    }
  }

  Widget addFenceControls() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Row(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width * 0.90,
                          padding: EdgeInsets.all(5.0),
                          child: TextField(
                            controller: _fenceName,
                            decoration: new InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .translate('fenceName')),
                          )),
                    ],
                  )),
              new Container(
                  width: MediaQuery.of(context).size.width * 0.97,
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    children: <Widget>[
                      Text(AppLocalizations.of(context)!.translate('radius')),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Slider(
                            value: _valRadius,
                            onChanged: (newSliderValue) {
                              setState(() {
                                _valRadius = newSliderValue;
                                updateNewCircle(_valRadius);
                              });
                            },
                            min: 100,
                            max: _valRadiusMax,
                          )),
                      Text(
                        _valRadius.toStringAsFixed(0),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  )),
              new Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width * 0.86,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_fenceName.text.isNotEmpty) {
                                submitFence();
                              } else {
                                Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!
                                        .translate("enterFenceName"),
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
                            child: Text(AppLocalizations.of(context)!
                                .translate('addGeofence')),
                          )),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
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
}

class Choice {
  Choice({title, icon});

  late final String title;
  late final IconData icon;
}
