import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/theme/CustomColor.dart';

import '../../traccar_gennissi.dart';

class ReportStopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ReportStopPageState();
}

class _ReportStopPageState extends State<ReportStopPage> {
  late ReportArguments args;
  List<Stop> _stopList = [];
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
      // ignore: unnecessary_null_comparison
      if (args != null) {
        _timer.cancel();
        Traccar.getStops(args.id.toString(), args.from, args.to)
            .then((value) => {
                  _stopList.addAll(value!),
                  _postsController.add(1),
                  isLoading = false,
                  setState(() {})
                });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as ReportArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.name,
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
                child: Text(AppLocalizations.of(context)!.translate('noData')),
              );
            }
          }),
    );
  }

  Widget loadReport() {
    return ListView.builder(
      itemCount: _stopList.length,
      itemBuilder: (context, index) {
        final stop = _stopList[index];
        return reportRow(stop);
      },
    );
  }

  Widget reportRow(Stop s) {
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
                      formatTime(s.startTime!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      formatTime(s.endTime!),
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
                          convertDistance(s.startOdometer!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("positionOdometer") +
                          ": " +
                          convertDistance(s.endOdometer!),
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
                              .translate("reportDuration") +
                          ": " +
                          convertDuration(s.duration!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("reportEngineHours") +
                          ": " +
                          convertDuration(s.engineHours!),
                      style: TextStyle(fontSize: 11),
                    )),
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                              .translate("reportSpentFuel") +
                          ": " +
                          s.spentFuel.toString(),
                      style: TextStyle(fontSize: 11),
                    )),
                  ],
                ),
                s.address != null
                    ? Row(
                        children: [
                          Expanded(
                              child: Text(
                            AppLocalizations.of(context)!
                                    .translate("positionAddress") +
                                ": " +
                        utf8.decode(s.address!.codeUnits),
                            style: TextStyle(fontSize: 11),
                          )),
                        ],
                      )
                    : new Container(),
              ],
            )));
  }
}
