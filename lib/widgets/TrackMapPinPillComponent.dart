import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpspro/arguments/DeviceArguments.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/model/PinInformation.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../traccar_gennissi.dart';

// ignore: must_be_immutable
class TrackMapPinPillComponent extends StatefulWidget {
  double pinPillPosition;
  PinInformation currentlySelectedPin;

  TrackMapPinPillComponent(
      {required this.pinPillPosition, required this.currentlySelectedPin});

  @override
  State<StatefulWidget> createState() => TrackMapPinPillComponentState();
}

class TrackMapPinPillComponentState extends State<TrackMapPinPillComponent> {
  String address = "Show Address";
  var latLng;
  String getAddress(lat, lng) {
    if (lat != null) {
      Traccar.geocode(lat, lng).then((value) => {
            print(value),
            if (value != null)
              {
                latLng = widget.currentlySelectedPin.location,
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
  Widget build(BuildContext context) {
    Color color;
    if (widget.currentlySelectedPin.location != latLng) {
      address = "Show Address";
    }
    if (widget.currentlySelectedPin.status == "online") {
      color = Colors.green;
    } else if (widget.currentlySelectedPin.status == "unknown") {
      color = Colors.yellow;
    } else {
      color = Colors.red;
    }

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          //margin: EdgeInsets.all(10),
          margin: EdgeInsets.fromLTRB(10, 0, 10, 30),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Container(
              //   width: 50, height: 50,
              //   margin: EdgeInsets.only(left: 5),
              //   child: ClipOval(child: Image.asset(widget.currentlySelectedPin.avatarPath, fit: BoxFit.cover )),
              // ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Row(children: <Widget>[
                              Icon(Icons.radio_button_checked,
                                  color: color, size: 20.0),
                              Padding(
                                  padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.38,
                                child: Text(
                                  utf8.decode(widget.currentlySelectedPin.name!.codeUnits),
                                  style: TextStyle(
                                      color: widget
                                          .currentlySelectedPin.labelColor,
                                      fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ]),
                            new Row(children: <Widget>[
                              InkWell(
                                child: Icon(Icons.info,
                                    color: CustomColor.primaryColor,
                                    size: 30.0),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/deviceInfo",
                                    arguments: DeviceArguments(
                                        widget.currentlySelectedPin.deviceId!,
                                        widget.currentlySelectedPin.name!,
                                        widget.currentlySelectedPin.device!),
                                  );
                                },
                              ),
                              InkWell(
                                child: Icon(Icons.directions,
                                    color: CustomColor.primaryColor,
                                    size: 30.0),
                                onTap: () async {
                                  String origin = widget.currentlySelectedPin
                                          .location!.latitude
                                          .toString() +
                                      "," +
                                      widget.currentlySelectedPin.location!
                                          .longitude
                                          .toString(); // lat,long like 123.34,68.56

                                  var url = '';
                                  var urlAppleMaps = '';
                                  if (Platform.isAndroid) {
                                    String query = Uri.encodeComponent(origin);
                                    url =
                                        "https://www.google.com/maps/search/?api=1&query=$query";
                                    await launch(url);
                                  } else {
                                    urlAppleMaps =
                                        'https://maps.apple.com/?q=$origin';
                                    url =
                                        "comgooglemaps://?saddr=&daddr=$origin&directionsmode=driving";
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else if (await canLaunch(
                                          urlAppleMaps)) {
                                        await launch(urlAppleMaps);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                      throw 'Could not launch $url';
                                    }
                                  }
                                },
                              ),
                              // Icon(Icons.streetview,
                              //     color: CustomColor.primaryColor, size: 30.0),
                            ]),
                          ]),
                      Divider(),
                      new Row(children: <Widget>[
                        Icon(Icons.speed,
                            color: CustomColor.primaryColor, size: 18.0),
                        Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                        Text(
                          AppLocalizations.of(context)!
                                  .translate('positionSpeed') +
                              ': ${widget.currentlySelectedPin.speed}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]),
                      new Row(children: <Widget>[
                        Icon(Icons.location_on_outlined,
                            color: color, size: 18.0),
                        Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              address = "Loading....";
                              setState(() {});
                              getAddress(
                                  widget.currentlySelectedPin.location!.latitude
                                      .toString(),
                                  widget
                                      .currentlySelectedPin.location!.longitude
                                      .toString());
                            },
                            child: Text(
                              address,
                              style:
                                  TextStyle(fontSize: 13, color: Colors.blue),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ]),
                      new Row(children: <Widget>[
                        Icon(Icons.timer_rounded,
                            color: CustomColor.primaryColor, size: 18.0),
                        Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
                        Text(
                            AppLocalizations.of(context)!
                                    .translate('deviceLastUpdate') +
                                ': ${widget.currentlySelectedPin.updatedTime}',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
