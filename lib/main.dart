import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/routes.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/traccar_gennissi.dart';
import 'package:redux/redux.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';


void main() {
  runApp(Phoenix(
      child:MyApp()));
}

Locale? _locale;

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Store<AppState> store =
        Store<AppState>(appStateReducer, initialState: AppState.initialState());

    return StoreProvider<AppState>(
      store: store,
      child: StoreBuilder<AppState>(
          onInit: (store) => store.dispatch({}),
          builder: (BuildContext context, Store<AppState> store) => MaterialApp(
                supportedLocales: [
                  Locale('en', ''),
                  Locale('fa', ''),
                  Locale('es', ''),
                  Locale('fr', ''),
                  Locale('pl', ''),
                  Locale('pt', ''),
                  Locale('tr', '')
                ],
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                locale: _locale,
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                theme: ThemeData(
                  fontFamily: 'Poppins',
                  primarySwatch: CustomColor.primaryColor,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                initialRoute: '/',
                routes: routes,
              )),
    );
  }
}
