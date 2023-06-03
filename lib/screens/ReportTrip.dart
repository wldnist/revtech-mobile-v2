import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/theme/CustomColor.dart';

import '../../traccar_gennissi.dart';

class ReportTripPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ReportTripPageState();
}

class _ReportTripPageState extends State<ReportTripPage> {
  ReportArguments? args;
  List<Trip> _tripList = [];
  late StreamController<int> _postsController;
  late Timer _timer;
  bool isLoading = true;

  @override
  void initState() {
    _postsController = new StreamController();
    getReport();
    super.initState();
  }

  getReport() {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (args != null) {
        _timer.cancel();
        Traccar.getTrip(args!.id.toString(), args!.from, args!.to)
            .then((value) => {
                  _tripList.addAll(value!),
                  _postsController.add(1),
                  isLoading = false,
                  setState(() {})
                });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)?.settings.arguments as ReportArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args!.name,
            style: TextStyle(color: CustomColor.secondaryColor)),
        iconTheme: IconThemeData(
          color: CustomColor.secondaryColor, //change your color here
        ),
      ),
      body: StreamBuilder<int>(
          stream: _postsController.stream,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              return loadReport();
            } else if (isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: Text(AppLocalizations.of(context)?.translate('noData')),
              );
            }
          }),
    );
  }

  Widget loadReport() {
    return ListView.builder(
      itemCount: _tripList.length,
      itemBuilder: (context, index) {
        final trip = _tripList[index];
        return reportRow(trip);
      },
    );
  }

  Widget reportRow(Trip t) {
    return Card(
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                        AppLocalizations.of(context)!
                            .translate("reportStartTime"),
                        style: TextStyle(color: Colors.green)),
                    Text(
                        AppLocalizations.of(context)!
                            .translate("reportEndTime"),
                        style: TextStyle(color: Colors.red))
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      formatTime(t.startTime!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      formatTime(t.endTime!),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("positionOdometer") +
                          ": " +
                          convertDistance(t.startOdometer!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("positionOdometer") +
                          ": " +
                          convertDistance(t.endOdometer!),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("positionDistance") +
                          ": " +
                          convertDistance(t.distance!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("reportAverageSpeed") +
                          ": " +
                          convertSpeed(t.averageSpeed!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("reportMaximumSpeed") +
                          ": " +
                          convertSpeed(t.maxSpeed!),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("reportDuration") +
                          ": " +
                          convertDuration(t.duration!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("reportSpentFuel") +
                          ": " +
                          t.spentFuel.toString(),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                t.startAddress != null
                    ? Row(
                        children: [
                          Expanded(
                              child: Text(
                            AppLocalizations.of(context)!
                                    .translate("reportStartAddress") +
                                ": " +
                              utf8.decode(t.startAddress!.codeUnits),
                            style: TextStyle(fontSize: 11),
                          )),
                        ],
                      )
                    : new Container(),
                t.endAddress != null
                    ? Row(
                        children: [
                          Expanded(
                              child: Text(
                            AppLocalizations.of(context)!
                                    .translate("reportEndAddress") +
                                ": " +
                              utf8.decode(t.endAddress!.codeUnits),
                            style: TextStyle(fontSize: 11),
                          )),
                        ],
                      )
                    : new Container(),
              ],
            )));
  }
}
