import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpspro/arguments/DeviceArguments.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/model/PinInformation.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/widgets/CustomProgressIndicatorWidget.dart';
import 'package:gpspro/widgets/TrackMapPinPillComponent.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';

class TrackDevicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TrackDeviceState();
}

class _TrackDeviceState extends State<TrackDevicePage> {
  late DeviceArguments args;
  Set<Marker> _markers = Set<Marker>();
  late bool isLoading;
  MapType _currentMapType = MapType.normal;
  double currentZoom = 14.0;
  bool _trafficEnabled = false;
  Color _trafficBackgroundButtonColor = CustomColor.secondaryColor;
  Color _mapTypeBackgroundColor = CustomColor.secondaryColor;
  Color _trafficForegroundButtonColor = CustomColor.primaryColor;
  Color _mapTypeForegroundColor = CustomColor.primaryColor;
  PinInformation currentlySelectedPin = PinInformation(
      speed: '',
      status: 'loading....',
      location: LatLng(0, 0),
      updatedTime: 'Loading....',
      name: 'Loading....',
      charging: false,
      ignition: false,
      batteryLevel: "",
      address: null,
      labelColor: Colors.grey,
      blocked: null,
      calcTotalDist: null,
      deviceId: 0,
      device: null);
  late PinInformation sourcePinInfo;
  late PinInformation destinationPinInfo;
  double pinPillPosition = 0;

  Device device = Device();
  PositionModel position = PositionModel();
  bool pageDestoryed = false;
  late SharedPreferences prefs;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  @override
  initState() {
    checkPreference();
    super.initState();
    drawPolyline();
    sourcePinInfo = PinInformation(
        name: "",
        location: LatLng(0, 0),
        address: '',
        speed: '',
        status: '',
        updatedTime: '',
        charging: false,
        ignition: false,
        batteryLevel: "",
        deviceId: 0,
        labelColor: Colors.blueAccent,
        blocked: false,
        device: null,
        calcTotalDist: null);
  }

  void drawPolyline() async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        width: 6,
        polylineId: id,
        color: Colors.greenAccent,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _initialRegion = CameraPosition(
    target: LatLng(0, 0),
    zoom: 0,
  );

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
    final Uint8List markerIcon = await getBytesFromAsset(iconPath, 100);

    CameraPosition cPosition = CameraPosition(
      target: LatLng(pos.latitude!, pos.longitude!),
      zoom: currentZoom,
    );

    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(cPosition));

    _markers = Set<Marker>();

    var pinPosition = LatLng(pos.latitude!, pos.longitude!);
    _markers.removeWhere((m) => m.markerId.value == pos.deviceId.toString());

    _markers.add(Marker(
      markerId: MarkerId(pos.deviceId.toString()),
      position: pinPosition,
      rotation: pos.course!,
      icon: BitmapDescriptor.fromBytes(markerIcon),
    ));
    polylineCoordinates.add(pinPosition);
    String fLastUpdate = formatTime(device.lastUpdate!);

    bool chargingStatus = false, ignitionStatus = false;
    String batteryLevelValue = "";

    if (pos.attributes!.containsKey("charge")) {
      chargingStatus = pos.attributes!["charge"];
    }

    if (pos.attributes!.containsKey("ignition")) {
      ignitionStatus = pos.attributes!["ignition"];
    }

    if (pos.attributes!.containsKey("batteryLevel")) {
      batteryLevelValue = pos.attributes!["batteryLevel"].toString() + "%";
    }

    sourcePinInfo = PinInformation(
        name: device.name,
        location: LatLng(pos.latitude!, pos.longitude!),
        address: pos.address,
        status: device.status,
        speed: convertSpeed(pos.speed!),
        updatedTime: fLastUpdate,
        charging: chargingStatus,
        ignition: ignitionStatus,
        batteryLevel: batteryLevelValue,
        deviceId: device.id,
        labelColor: CustomColor.primaryColor,
        calcTotalDist: null,
        blocked: false,
        device: null);

    currentlySelectedPin = sourcePinInfo;

    // ignore: unnecessary_null_comparison
    if (_markers != null) {
      if (isLoading) {
        _showProgress(false);
        isLoading = false;
        setState(() {});
      }
    }
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
      _mapTypeBackgroundColor = _currentMapType == MapType.normal
          ? CustomColor.secondaryColor
          : CustomColor.primaryColor;
      _mapTypeForegroundColor = _currentMapType == MapType.normal
          ? CustomColor.primaryColor
          : CustomColor.secondaryColor;
    });
  }

  void _trafficEnabledPressed() {
    setState(() {
      _trafficEnabled = _trafficEnabled == false ? true : false;
      _trafficBackgroundButtonColor = _trafficEnabled == false
          ? CustomColor.secondaryColor
          : CustomColor.primaryColor;

      _trafficForegroundButtonColor = _trafficEnabled == false
          ? CustomColor.primaryColor
          : CustomColor.secondaryColor;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  currentMapStatus(CameraPosition position) {
    currentZoom = position.zoom;
  }

  @override
  void dispose() {
    pageDestoryed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as DeviceArguments;

    return StoreConnector<AppState, ViewModel>(
      converter: (Store<AppState> store) => ViewModel.create(store),
      builder: (BuildContext context, ViewModel viewModel) => SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: Text(args.name,
                    style: TextStyle(color: CustomColor.secondaryColor)),
                iconTheme: IconThemeData(
                  color: CustomColor.secondaryColor, //change your color here
                ),
              ),
              body: buildMap(viewModel))),
    );
  }

  Widget buildMap(ViewModel viewModel) {
    device = viewModel.devices![args.id] as Device;
    if (viewModel.positions!.containsKey(args.id)) {
      if (!pageDestoryed) {
        updateMarker(viewModel.positions![args.id] as PositionModel);
      }
      return Stack(
        children: <Widget>[
          Container(
            child: GoogleMap(
              mapType: _currentMapType,
              initialCameraPosition: _initialRegion,
              onCameraMove: currentMapStatus,
              trafficEnabled: _trafficEnabled,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                CustomProgressIndicatorWidget().showProgressDialog(context,
                    AppLocalizations.of(context)!.translate('sharedLoading'));
                isLoading = true;
              },
              polylines: Set<Polyline>.of(polylines.values),
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              markers: _markers,
            ),
          ),
          TrackMapPinPillComponent(
              pinPillPosition: pinPillPosition,
              currentlySelectedPin: currentlySelectedPin),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 5, 0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: _onMapTypeButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: _mapTypeBackgroundColor,
                    foregroundColor: _mapTypeForegroundColor,
                    mini: true,
                    child: const Icon(Icons.map, size: 30.0),
                  ),
                  FloatingActionButton(
                    heroTag: "traffic",
                    onPressed: _trafficEnabledPressed,
                    mini: true,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: _trafficBackgroundButtonColor,
                    foregroundColor: _trafficForegroundButtonColor,
                    child: const Icon(Icons.traffic, size: 30.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Text("No data"),
      );
    }
  }

  Future<void> _showProgress(bool status) async {
    if (status) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
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
