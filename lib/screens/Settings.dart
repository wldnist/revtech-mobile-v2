import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/screens/CommonMethod.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/widgets/AlertDialogCustom.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../traccar_gennissi.dart';

class SettingsPage extends StatefulWidget {
  final ViewModel model;

  SettingsPage(this.model);
  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? user;
  late SharedPreferences prefs;

  //StreamController<Device> _postsController;
  bool isLoading = true;
  final TextEditingController _newPassword = new TextEditingController();
  final TextEditingController _retypePassword = new TextEditingController();

  int online = 0, offline = 0, unknown = 0;

  @override
  initState() {
    //_postsController = new StreamController();
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

  logout() {
    Traccar.sessionLogout().then((value) => {
      prefs.clear(),
      widget.model.devices!.clear(),
      widget.model.positions!.clear(),
      widget.model.events!.clear(),
      Phoenix.rebirth(context)
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.translate('settings'),
                style: TextStyle(color: CustomColor.secondaryColor)),
            iconTheme: IconThemeData(
              color: CustomColor.secondaryColor, //change your color here
            ),
          ),
          body: new Column(children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(1.0),
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: new Card(
                elevation: 1.0,
                child: ListTile(
                  title: Text(
                    new String.fromCharCodes(new Runes(user!.name!)),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    new String.fromCharCodes(new Runes(user!.email!)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: OutlinedButton(
                    onPressed: () {
                      logout();
                    },
                    child: Text(
                        AppLocalizations.of(context)!.translate("logout"),
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: settings(),
            ),
          ]));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('settings')),
        ),
        body: new Center(
          child: new CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget settings() {
    return new Card(
        elevation: 1.0,
        child: Column(
          children: <Widget>[
            // ListTile(
            //   title: Text(
            //     AppLocalizations.of(context)
            //         .translate("diablePopupNotification"),
            //     style: TextStyle(fontSize: 13),
            //   ),
            //   trailing: Switch(
            //       value: prefs.getBool("popup_notify"),
            //       onChanged: (bool x) {
            //         prefs.setBool("popup_notify", x);
            //         setState(() {});
            //       }),
            // ),
            // Divider(),
            ListTile(
              title: Text("Notifications"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.pushNamed(context, "/enableNotifications");
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.translate("changePassword"),
                style: TextStyle(fontSize: 13),
              ),
              onTap: () {
                changePasswordDialog(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.translate("userExpirationTime"),
                style: TextStyle(fontSize: 13),
              ),
              trailing: Text(
                user!.expirationTime != null
                    ? formatTime(user!.expirationTime!)
                    : 'Not Found',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Divider(),
            ListTile(
                title: Text(
                  AppLocalizations.of(context)!.translate("sharedMaintenance"),
                  style: TextStyle(fontSize: 13),
                ),
                onTap: (){
                  Navigator.pushNamed(context, "/maintenance");
                }
            ),
            Divider(),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.translate("branding"),
                style: TextStyle(fontSize: 13),
              ),
              onTap: () {
                onSheetShowContents(context);
              },
            ),
          ],
        ));
  }

  void onSheetShowContents(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.30,
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          ),
        ),
        child: Center(
          child: bottomSheetContent(),
        ),
      ),
    );
  }

  Widget bottomSheetContent() {
    return SafeArea(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 5, 0),
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: Text(
                        AppLocalizations.of(context)!.translate("branding"),
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ))),
              InkWell(
                child: Icon(
                  Icons.close,
                  size: 40,
                ),
                onTap: () => {Navigator.pop(context)},
              )
            ],
          ),
          Divider(),
          Expanded(child: loadPlan())
        ],
      ),
    );
  }

  Widget loadPlan() {
    return Container(
        height: 150.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 1,
          itemBuilder: (context, index) {
            return loadPlanInfo();
          },
        ));
  }

  Widget loadPlanInfo() {
    return Card(
      elevation: 2.0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.99,
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 25,
                margin: EdgeInsets.only(left: 8, top: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(colors: [
                      const Color(0xFF189ad3).withOpacity(0.8),
                      const Color(0xff557AC7).withOpacity(0.5)
                    ])),
                child: Text(
                  AppLocalizations.of(context)!.translate("brandingTitle"),
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8, top: 7),
              child: Center(
                child: Text(
                    AppLocalizations.of(context)!.translate("brandingDesc")),
              ),
            )
          ],
        ),
      ),
    );
  }

  void changePasswordDialog(BuildContext context) {
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 220.0,
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            child: new TextField(
                              controller: _newPassword,
                              decoration: new InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('newPassword')),
                              obscureText: true,
                            ),
                          ),
                          new Container(
                            child: new TextField(
                              controller: _retypePassword,
                              decoration: new InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .translate('retypePassword')),
                              obscureText: true,
                            ),
                          ),
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
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  updatePassword();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.translate('ok'),
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
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

  void updatePassword() {
    if (_newPassword.text == _retypePassword.text) {
      final user = User.fromJson(jsonDecode(prefs.getString("userJson")!));
      user.password = _newPassword.text;
      String userReq = json.encode(user.toJson());

      Traccar.updateUser(userReq, prefs.getString("userId")!).then((value) => {
            AlertDialogCustom().showAlertDialog(
                context,
                AppLocalizations.of(context)!
                    .translate('passwordUpdatedSuccessfully'),
                AppLocalizations.of(context)!.translate('changePassword'),
                AppLocalizations.of(context)!.translate('ok'))
          });
    } else {
      AlertDialogCustom().showAlertDialog(
          context,
          AppLocalizations.of(context)!.translate('passwordNotSame'),
          AppLocalizations.of(context)!.translate('failed'),
          AppLocalizations.of(context)!.translate('ok'));
    }
  }
}
