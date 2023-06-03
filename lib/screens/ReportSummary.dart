import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/theme/CustomColor.dart';

import '../../traccar_gennissi.dart';

class ReportSummaryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ReportSummaryPageState();
}

class _ReportSummaryPageState extends State<ReportSummaryPage> {
  late ReportArguments args;
  List<Summary> _summaryList = [];
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
        Traccar.getSummary(args.id.toString(), args.from, args.to)
            .then((value) => {
                  _summaryList.addAll(value!),
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
      itemCount: _summaryList.length,
      itemBuilder: (context, index) {
        final summary = _summaryList[index];
        return reportRow(summary);
      },
    );
  }

  Widget reportRow(Summary s) {
    return Card(
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                          .translate("positionDistance"),
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertDistance(s.distance!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                          .translate("reportStartOdometer"),
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertDistance(s.startOdometer!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                          .translate("reportEndOdometer"),
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertDistance(s.endOdometer!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                          .translate("reportAverageSpeed"),
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertSpeed(s.averageSpeed!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                          .translate("reportMaximumSpeed"),
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertSpeed(s.maxSpeed!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                          .translate("reportEngineHours"),
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      convertDuration(s.engineHours!),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
                Padding(padding: EdgeInsets.all(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      AppLocalizations.of(context)!
                          .translate("reportSpentFuel"),
                      style: TextStyle(
                          fontSize: 15, color: CustomColor.primaryColor),
                    )),
                    Expanded(
                        child: Text(
                      s.spentFuel.toString(),
                      style: TextStyle(fontSize: 15),
                    )),
                  ],
                ),
              ],
            )));
  }
}
