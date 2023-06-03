import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gpspro/arguments/ReportArgumnets.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/theme/CustomColor.dart';

class ReportListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  late ReportArguments args;

  // ignore: non_constant_identifier_names
  Material Items(IconData icon, String heading, Color cColor) {
    return Material(
        color: Colors.white,
        elevation: 14.0,
        shadowColor: CustomColor.primaryColor,
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          onTap: () {
            if (heading ==
                AppLocalizations.of(context)!.translate('reportRoute')) {
              Navigator.pushNamed(context, "/reportRoute",
                  arguments: ReportArguments(
                      args.id, args.from, args.to, args.name, args.device));
            } else if (heading ==
                AppLocalizations.of(context)!.translate('reportEvents')) {
              Navigator.pushNamed(context, "/reportEvent",
                  arguments: ReportArguments(
                      args.id, args.from, args.to, args.name, args.device));
            } else if (heading ==
                AppLocalizations.of(context)!.translate('reportTrips')) {
              Navigator.pushNamed(context, "/reportTrip",
                  arguments: ReportArguments(
                      args.id, args.from, args.to, args.name, args.device));
            } else if (heading ==
                AppLocalizations.of(context)!.translate('reportStops')) {
              Navigator.pushNamed(context, "/reportStop",
                  arguments: ReportArguments(
                      args.id, args.from, args.to, args.name, args.device));
            } else if (heading ==
                AppLocalizations.of(context)!.translate('reportSummary')) {
              Navigator.pushNamed(context, "/reportSummary",
                  arguments: ReportArguments(
                      args.id, args.from, args.to, args.name, args.device));
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Text(
                            heading,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cColor,
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: cColor,
                        borderRadius: BorderRadius.circular(24.0),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as ReportArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('reportDashboard'),
            style: TextStyle(color: CustomColor.secondaryColor)),
        iconTheme: IconThemeData(
          color: CustomColor.secondaryColor, //change your color here
        ),
      ),
      body: StaggeredGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: <Widget>[
          Items(
              Icons.show_chart,
              AppLocalizations.of(context)!.translate('reportRoute'),
              CustomColor.primaryColor),
          Items(
              Icons.info_outline,
              AppLocalizations.of(context)!.translate('reportEvents'),
              CustomColor.primaryColor),
          Items(
              Icons.timeline,
              AppLocalizations.of(context)!.translate('reportTrips'),
              CustomColor.primaryColor),
          Items(
              Icons.block,
              AppLocalizations.of(context)!.translate('reportStops'),
              CustomColor.primaryColor),
          Items(
              Icons.list,
              AppLocalizations.of(context)!.translate('reportSummary'),
              CustomColor.primaryColor),
          //Items(Icons.assessment, "Chart", 0xFF1E88E5)
        ],
        staggeredTiles: [
          StaggeredTile.extent(1, 150.0),
          StaggeredTile.extent(1, 150.0),
          StaggeredTile.extent(1, 150.0),
          StaggeredTile.extent(1, 150.0),
          StaggeredTile.extent(1, 150.0),
          //StaggeredTile.extent(1, 130.0)
        ],
      ),
    );
  }
}
