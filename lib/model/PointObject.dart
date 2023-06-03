import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PointObject {
  late final Widget child;
  late final LatLng location;

  PointObject({child, location});
}
