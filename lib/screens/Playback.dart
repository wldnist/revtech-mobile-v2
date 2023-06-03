import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/model/PinInformation.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/widgets/AlertDialogCustom.dart';
import 'package:gpspro/widgets/CustomProgressIndicatorWidget.dart';

import '../../traccar_gennissi.dart';
import 'CommonMethod.dart';

class PlaybackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  bool _isPlaying = false;
  var _isPlayingIcon = Icons.pause_circle_outline;
  bool _trafficEnabled = false;
  MapType _currentMapType = MapType.normal;
  Color _trafficButtonColor = CustomColor.primaryColor;
  Set<Marker> _markers = Set<Marker>();
  double currentZoom = 14.0;
  late StreamController<PositionModel> _postsController;
  late Timer _timer;
  Timer? timerPlayBack;
  late ReportArguments args;
  List<PositionModel> routeList = [];
  late bool isLoading;
  double pinPillPosition = 0;
  PinInformation currentlySelectedPin = PinInformation(
      speed: '',
      status: 'loading....',
      location: LatLng(0, 0),
      updatedTime: 'Loading....',
      name: 'Loading....',
      address: null,
      labelColor: Colors.grey,
      blocked: null,
      charging: null,
      calcTotalDist: null,
      batteryLevel: null,
      deviceId: 0,
      device: null,
      ignition: null);
  int _sliderValue = 0;
  int _sliderValueMax = 0;
  int playbackTime = 200;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  List<Choice> choices = [];

  late Choice _selectedChoice; // The app's "state".

  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if (_selectedChoice.title ==
        AppLocalizations.of(context)!.translate('slow')) {
      playbackTime = 400;
      timerPlayBack!.cancel();
      playRoute();
    } else if (_selectedChoice.title ==
        AppLocalizations.of(context)!.translate('medium')) {
      playbackTime = 200;
      timerPlayBack!.cancel();
      playRoute();
    } else if (_selectedChoice.title ==
        AppLocalizations.of(context)!.translate('fast')) {
      playbackTime = 100;
      timerPlayBack!.cancel();
      playRoute();
    }
  }

  @override
  initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  Timer interval(Duration duration, func) {
    Timer function() {
      Timer timer = new Timer(duration, function);

      func(timer);

      return timer;
    }

    return new Timer(duration, function);
  }

  void playRoute() async {
    var iconPath = "images/arrow.png";
    final Uint8List? icon = await getBytesFromAsset(iconPath, 80);
    interval(new Duration(milliseconds: playbackTime), (timer) {
      if (routeList.length != _sliderValue) {
        _sliderValue++;
      }
      timerPlayBack = timer;
      _markers = Set<Marker>();
      if (routeList.length - 1 == _sliderValue.toInt()) {
        timerPlayBack!.cancel();
      } else if (routeList.length != _sliderValue.toInt()) {
        moveCamera(routeList[_sliderValue.toInt()]);
        _markers.add(
          Marker(
            markerId:
                MarkerId(routeList[_sliderValue.toInt()].deviceId.toString()),
            position: LatLng(routeList[_sliderValue.toInt()].latitude!,
                routeList[_sliderValue.toInt()].longitude!), // updated position
            rotation: routeList[_sliderValue.toInt()].course!,
            icon: BitmapDescriptor.fromBytes(icon!),
          ),
        );
        setState(() {});
      } else {
        timerPlayBack!.cancel();
      }
    });
  }

  void playUsingSlider(int pos) async {
    var iconPath = "images/arrow.png";
    final Uint8List? icon = await getBytesFromAsset(iconPath, 80);
    _markers = Set<Marker>();
    if (routeList.length != _sliderValue.toInt()) {
      moveCamera(routeList[_sliderValue.toInt()]);
      _markers.add(
        Marker(
          markerId:
              MarkerId(routeList[_sliderValue.toInt()].deviceId.toString()),
          position: LatLng(routeList[_sliderValue.toInt()].latitude!,
              routeList[_sliderValue.toInt()].longitude!), // updated position
          rotation: routeList[_sliderValue.toInt()].course!,
          icon: BitmapDescriptor.fromBytes(icon!),
        ),
      );
      setState(() {});
    }
  }

  void moveCamera(PositionModel pos) async {
    CameraPosition cPosition = CameraPosition(
      target: LatLng(pos.latitude!, pos.longitude!),
      zoom: currentZoom,
    );

    if (isLoading) {
      _showProgress(false);
    }
    isLoading = false;
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  getReport() {
    _timer = new Timer.periodic(Duration(milliseconds: 1000), (timer) {
      // ignore: unnecessary_null_comparison
      if (args != null) {
        _timer.cancel();
        Traccar.getPositions(args.id.toString(), args.from, args.to)
            .then((value) => {
                  if (value!.length != 0)
                    {
                      routeList.addAll(value),
                      _sliderValueMax = value.length - 1,
                      value.forEach((element) {
                        _postsController.add(element);
                        polylineCoordinates
                            .add(LatLng(element.latitude!, element.longitude!));
                      }),
                      if (value.length != 0) {playRoute(), setState(() {})}
                    }
                  else
                    {
                      if (isLoading)
                        {
                          _showProgress(false),
                          isLoading = false,
                        },
                      AlertDialogCustom().showAlertDialog(
                          context,
                          AppLocalizations.of(context)!.translate('noData'),
                          AppLocalizations.of(context)!.translate('failed'),
                          AppLocalizations.of(context)!.translate('ok'))
                    }
                });
        drawPolyline();
      }
    });
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

  void _playPausePressed() {
    setState(() {
      _isPlaying = _isPlaying == false ? true : false;
      if (_isPlaying) {
        timerPlayBack!.cancel();
      } else {
        playRoute();
      }
      _isPlayingIcon = _isPlaying == false
          ? Icons.pause_circle_outline
          : Icons.play_circle_outline;
    });
  }

  currentMapStatus(CameraPosition position) {
    currentZoom = position.zoom;
  }

  @override
  void dispose() {
    // ignore: unnecessary_null_comparison
    if (timerPlayBack != null) {
      if (timerPlayBack!.isActive) {
        timerPlayBack!.cancel();
      }
    }
    super.dispose();
  }

  static final CameraPosition _initialRegion = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as ReportArguments;
    choices = <Choice>[
      Choice(
          title: AppLocalizations.of(context)!.translate('slow'),
          icon: Icons.directions_car),
      Choice(
          title: AppLocalizations.of(context)!.translate('medium'),
          icon: Icons.directions_bike),
      Choice(
          title: AppLocalizations.of(context)!.translate('fast'),
          icon: Icons.directions_boat),
    ];
    _selectedChoice = choices[0];
    return Scaffold(
      appBar: AppBar(
        title: Text(args.name,
            style: TextStyle(color: CustomColor.secondaryColor)),
        iconTheme: IconThemeData(
          color: CustomColor.secondaryColor, //change your color here
        ),
        actions: <Widget>[
          // action button
          PopupMenuButton<Choice>(
            onSelected: _select,
            icon: Icon(Icons.timer),
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
          mapType: _currentMapType,
          initialCameraPosition: _initialRegion,
          onCameraMove: currentMapStatus,
          trafficEnabled: _trafficEnabled,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;
            CustomProgressIndicatorWidget().showProgressDialog(context,
                AppLocalizations.of(context)!.translate('sharedLoading'));
            isLoading = true;
          },
          markers: _markers,
          polylines: Set<Polyline>.of(polylines.values),
        ),
//            TrackMapPinPillComponent(
//                pinPillPosition: pinPillPosition,
//                currentlySelectedPin: currentlySelectedPin
//            ),
        Padding(
          padding: const EdgeInsets.all(10.0),
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
        playBackControls(),
      ]),
    );
  }

  Widget playBackControls() {
    String fUpdateTime =
        AppLocalizations.of(context)!.translate('sharedLoading');
    String speed = AppLocalizations.of(context)!.translate('sharedLoading');
    if (routeList.length > _sliderValue.toInt()) {
      fUpdateTime = formatTime(routeList[_sliderValue.toInt()].fixTime!);
      speed = convertSpeed(routeList[_sliderValue.toInt()].speed!);
    }

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(10),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Row(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(top: 5.0, left: 5.0),
                          child: InkWell(
                            child: Icon(_isPlayingIcon,
                                color: CustomColor.primaryColor, size: 50.0),
                            onTap: () {
                              _playPausePressed();
                            },
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 5.0, left: 0.0),
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Slider(
                            value: _sliderValue.toDouble(),
                            onChanged: (newSliderValue) {
                              setState(
                                  () => _sliderValue = newSliderValue.toInt());
                              // ignore: unnecessary_null_comparison
                              if (timerPlayBack != null) {
                                if (!timerPlayBack!.isActive) {
                                  playUsingSlider(newSliderValue.toInt());
                                }
                              }
                            },
                            min: 0,
                            max: _sliderValueMax.toDouble(),
                          )),
                    ],
                  )),
              new Container(
                margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Icon(Icons.radio_button_checked,
                          color: CustomColor.primaryColor, size: 20.0),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(AppLocalizations.of(context)!
                              .translate('positionSpeed') +
                          ": " +
                          speed),
                    ),
                  ],
                ),
              ),
              _sliderValue.toInt() > 0
                  ? routeList[_sliderValue.toInt()].address != null
                      ? Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Icon(Icons.location_on_outlined,
                                  color: CustomColor.primaryColor, size: 25.0),
                            ),
                            Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.0, left: 5.0, right: 0),
                                        child: Text(
                                          utf8.decode(utf8.encode(
                                              routeList[_sliderValue.toInt()]
                                                  .address!)),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ]),
                            )
                          ],
                        )
                      : new Container()
                  : new Container(),
              new Container(
                margin: EdgeInsets.fromLTRB(5, 5, 0, 5),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Icon(Icons.av_timer,
                          color: CustomColor.primaryColor, size: 20.0),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(AppLocalizations.of(context)!
                              .translate('deviceLastUpdate') +
                          ": " +
                          fUpdateTime),
                    ),
                  ],
                ),
              ),
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
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
