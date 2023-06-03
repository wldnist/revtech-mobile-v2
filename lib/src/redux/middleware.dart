import 'package:redux/redux.dart';

import 'actions.dart';
import 'appstate.dart';

void appStateMiddleware(
    Store<AppState> store, action, NextDispatcher next) async {
  next(action);

  if (action is UpdatePositionAction ||
      action is UpdateDeviceAction ||
      action is UpdateGeofenceAction ||
      action is AddEventsAction) {}
}
