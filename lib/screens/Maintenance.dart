import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/src/model/MaintenanceModel.dart';
import 'package:gpspro/src/model/MaintenancePostModel.dart';
import 'package:gpspro/theme/CustomColor.dart';

import '../../traccar_gennissi.dart';

class MaintenancePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MaintenanceState();
}

class _MaintenanceState extends State<MaintenancePage> {
  late StreamController<int> _postsController;
  List<MaintenanceModel> maintenanceList = [];
  bool isLoading = true;
  int start = 0;

  final TextEditingController _nameFilter = new TextEditingController();
  final TextEditingController _typeFilter = new TextEditingController();
  final TextEditingController _startFilter = new TextEditingController();
  final TextEditingController _periodFilter = new TextEditingController();

  @override
  void initState() {
    _postsController = new StreamController();
    getMaintenance();
    super.initState();
  }

  void getMaintenance(){
    Traccar.getMaintenance().then((value) => {
      _postsController.add(1),
      maintenanceList.addAll(value!)
    });
  }

  void addMaintenance(){
    _showProgress(true);

    MaintenancePostModel m = MaintenancePostModel();
    m.id = -1;
    m.type = _typeFilter.text;
    m.name = _nameFilter.text;
    m.start = double.parse(_startFilter.text);
    m.period = double.parse(_periodFilter.text);

    var maintenanceJson = json.encode(m);

    Traccar.addMaintenance(maintenanceJson.toString()).then((value) => {
      if(value.statusCode == 200){
        _showProgress(false),
        Navigator.pop(context),
        maintenanceList.clear(),
        getMaintenance(),
        Fluttertoast.showToast(
            msg:
            AppLocalizations.of(context)!.translate("success"),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0)
      }else{
        Fluttertoast.showToast(
            msg:
            AppLocalizations.of(context)!.translate("errorMsg"),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0)
      }
    });
  }

  startValInc() async {
    start++;
    _startFilter.text = start.toString();
  }

  startValDec() async {
    if(start != 0) {
      start--;
      _startFilter.text = start.toString();
    }
  }

  periodValInc() async {
    start++;
    _periodFilter.text = start.toString();
  }

  periodValDec() async {
    if(start != 0) {
      start--;
      _periodFilter.text = start.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('sharedMaintenance'),
              style: TextStyle(color: CustomColor.secondaryColor)),
          actions: [
            GestureDetector(
              onTap: () {
                showMaintenanceDialog(context);
              },
              child: Icon(Icons.add),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
          ],
        ),
        body: maintenance());
  }

  void showMaintenanceDialog(BuildContext context) {

    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              Iterable list;
              return Container(
                height: 400,
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
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
                                      .translate('sharedMaintenance'), style: TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),

                                    new Container(
                                      child: new TextField(
                                        controller: _nameFilter,
                                        decoration: new InputDecoration(
                                            labelText:
                                            AppLocalizations.of(context)!.translate('name')),
                                      ),
                                    ),
                                    new Container(
                                      child: new TextField(
                                        controller: _typeFilter,
                                        decoration: new InputDecoration(
                                            labelText:
                                            AppLocalizations.of(context)!.translate('type')),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(onPressed: (){setState(startValDec());}, icon: Icon(Icons.keyboard_arrow_left_sharp)),
                                        new Container(
                                          width: MediaQuery.of(context).size.width / 3,
                                          child: new TextField(
                                            controller: _startFilter,
                                            decoration: new InputDecoration(
                                                labelText:
                                                AppLocalizations.of(context)!.translate('maintenanceStart')),
                                          ),
                                        ),
                                        IconButton(onPressed: (){setState(startValInc());}, icon: Icon(Icons.keyboard_arrow_right))
                                      ],
                                    ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(onPressed: (){periodValDec();}, icon: Icon(Icons.keyboard_arrow_left_sharp)),
                                  new Container(
                                    width: MediaQuery.of(context).size.width / 3,
                                    child: new TextField(
                                      controller: _periodFilter,
                                      decoration: new InputDecoration(
                                          labelText:
                                          AppLocalizations.of(context)!.translate('maintenancePeriod')),
                                    ),
                                  ),
                                  IconButton(onPressed: (){periodValInc();}, icon: Icon(Icons.keyboard_arrow_right))
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(5)),
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
                                      addMaintenance();
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
                  ],
                ),
              );
            }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }


  Widget maintenance() {
    return StreamBuilder<int>(
        stream: _postsController.stream,
        builder: (BuildContext context,
            AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            return maintenanceView();
          } else if (isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text(AppLocalizations.of(context)!.translate('noData')),
            );
          }
        });
  }

  Widget maintenanceView() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: maintenanceList.length,
        itemBuilder: (context, index) {
          final m = maintenanceList[index];
          return new Card(
            elevation: 3.0,
            child: Column(
              children: <Widget>[
                new ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Text(m.name!,
                          style: TextStyle(
                              fontSize: 13.0, fontWeight: FontWeight.bold)),
                      new Text(m.start.toString(),
                          style: TextStyle(
                              fontSize: 12.0)),
                      new Text(m.period.toString(),
                          style: TextStyle(
                              fontSize: 12.0)),
                    ],
                  ),
                  trailing: GestureDetector(
                    onTap: (){
                      deleteMaintenanceConfirm(m.id);
                    },
                    child:  Icon(Icons.delete
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  void deleteMaintenance(id) {
    _showProgress(true);
    Traccar.deleteMaintenance(id).then((value) => {
      if (value.statusCode == 204)
        {
          _showProgress(false),
          Navigator.of(context).pop(false),
          maintenanceList.clear(),
          getMaintenance(),
          setState(() {
            Fluttertoast.showToast(
                msg:
                AppLocalizations.of(context)!.translate("deleteMaintenance"),
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

  Future<dynamic> deleteMaintenanceConfirm(dynamic id) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Maintenance'),
        content: Text('Are you sure?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () => {deleteMaintenance(id)},
            /*Navigator.of(context).pop(true)*/
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
