import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gpspro/arguments/DeviceArguments.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';

class DeviceInfo extends StatefulWidget {
  @override
  _DeviceInfoState createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  late DeviceArguments args;
  late Device device;
  late PositionModel position;
  SharedPreferences? prefs;

  @override
  initState() {
    checkPreference();
    super.initState();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    // if(_timer.isActive) {
    //   _timer.cancel();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as DeviceArguments;

    return StoreConnector<AppState, ViewModel>(
        converter: (Store<AppState> store) => ViewModel.create(store),
        builder: (BuildContext context, ViewModel viewModel) => Scaffold(
              appBar: AppBar(
                title: Text(args.name,
                    style: TextStyle(color: CustomColor.secondaryColor)),
                iconTheme: IconThemeData(
                  color: CustomColor.secondaryColor, //change your color here
                ),
              ),
              body: SingleChildScrollView(child: loadDevice(viewModel)),
            ));
  }

  Widget loadDevice(ViewModel viewModel) {
    Device? d = viewModel.devices![args.id];
    String iconPath = "images/marker_default_offline.png";

    String status;

    if (d!.status == "unknown") {
      status = 'static';
    } else {
      status = d.status!;
    }

    if (d.category != null) {
      iconPath = "images/marker_" + d.category! + "_" + status + ".png";
    } else {
      iconPath = "images/marker_default" + "_" + status + ".png";
    }
    return new Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(1.0),
        ),
        new Container(
          child: new Padding(
            padding: const EdgeInsets.all(1.0),
            child: new Card(
              elevation: 5.0,
              child: Column(children: <Widget>[
                Container(
                    child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 10.0, left: 5.0),
                      child: Image.asset(
                        iconPath,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    Container(
                        width: 200,
                        padding: EdgeInsets.only(top: 10.0, left: 5.0),
                        child: Text(
                          d.status!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                )),
                SizedBox(height: 5.0),
              ]),
            ),
          ),
        ),
        Container(child: positionDetails(viewModel)),
        Container(child: Text("Sensors", style: TextStyle(fontSize: 16))),
        Container(child: sensorInfo(viewModel))
      ],
    );
  }

  Widget positionDetails(ViewModel viewModel) {
    if (viewModel.positions!.containsKey(args.id)) {
      PositionModel? position = viewModel.positions![args.id];
      Device? device = viewModel.devices![args.id];

      return Card(
        elevation: 5.0,
        child: Column(children: <Widget>[
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.bookmark,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Text(AppLocalizations.of(context)!
                            .translate('deviceType')),
                      ),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child: Text(device!.model == null
                      ? AppLocalizations.of(context)!.translate('noData')
                      : device.model)),
            ],
          )),
          SizedBox(height: 5.0),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.gps_fixed,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 3.0),
                          child: Text(AppLocalizations.of(context)!
                              .translate('positionLatitude'))),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child: Text(position!.latitude!.toStringAsFixed(5))),
            ],
          )),
          SizedBox(height: 5.0),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.gps_fixed,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Text(AppLocalizations.of(context)!
                            .translate('positionLongitude')),
                      ),
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child: Text(position.longitude!.toStringAsFixed(5))),
            ],
          )),
          SizedBox(height: 5.0),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.av_timer,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 3.0),
                          child: Text(AppLocalizations.of(context)!
                              .translate('positionSpeed')))
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child: Text(convertSpeed(position.speed!))),
            ],
          )),
          SizedBox(height: 5.0),
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(Icons.directions,
                            color: CustomColor.primaryColor, size: 25.0),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 3.0),
                          child: Text(AppLocalizations.of(context)!
                              .translate('positionCourse')))
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 10.0),
                  child: Text(convertCourse(position.course!))),
            ],
          )),
          SizedBox(height: 5.0),
          position.address != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  utf8.decode(position.address!.codeUnits),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ]),
                    )
                  ],
                )
              : new Container(),
          SizedBox(height: 5.0),
        ]),
      );
    } else {
      return Container(
        child: Text(AppLocalizations.of(context)!.translate('noData')),
      );
    }
  }

  Widget sensorInfo(ViewModel viewModel) {
    if (viewModel.positions!.containsKey(args.id)) {
      Map<String, dynamic> attributes =
          viewModel.positions![args.id]!.attributes!;
      List<Widget> keyList = [];

      for (var entry in attributes.entries) {
        if (entry.key == "totalDistance" || entry.key == "distance") {
          keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text(
                      AppLocalizations.of(context)!.translate(entry.key) != null
                          ? AppLocalizations.of(context)!.translate(entry.key)
                          : entry.key)),
              new Expanded(child: Text(convertDistance(entry.value)))
            ],
          ));
        } else if (entry.key == "hours") {
          keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text(
                      AppLocalizations.of(context)!.translate(entry.key) != null
                          ? AppLocalizations.of(context)!.translate(entry.key)
                          : entry.key)),
              new Expanded(child: Text(convertDuration(entry.value)))
            ],
          ));
        } else if (entry.key == "ignition") {
          keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text(
                      AppLocalizations.of(context)!.translate(entry.key) != null
                          ? AppLocalizations.of(context)!.translate(entry.key)
                          : entry.key)),
              new Expanded(
                  child: Text(entry.value
                      ? AppLocalizations.of(context)!.translate("on")
                      : AppLocalizations.of(context)!.translate("off")))
            ],
          ));
        } else {
          keyList.add(new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                  child: Text(
                      AppLocalizations.of(context)!.translate(entry.key) != null
                          ? AppLocalizations.of(context)!.translate(entry.key)
                          : entry.key)),
              new Expanded(child: Text(entry.value.toString()))
            ],
          ));
        }
      }
      return new Card(
          elevation: 5.0,
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: keyList)));
    } else {
      return new Container();
    }
  }
}
