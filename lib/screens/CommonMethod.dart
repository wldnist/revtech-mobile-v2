import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

String formatTime(String time) {
  DateTime lastUpdate = DateTime.parse(time);
  return DateFormat('dd-MM-yyyy hh:mm:ss aa').format(lastUpdate.toLocal());
}

String convertSpeed(double speed) {
  double factor = 1.852;
  double floatSpeed = (speed * factor);
  return floatSpeed.toInt().toString() + " Km/hr";
}

String convertDistance(double distance) {
  double calcDistance = distance / 1000;
  return calcDistance.toStringAsFixed(2) + " Km";
}

String convertDuration(int duration) {
  double hours = duration / 3600000;
  double minutes = duration % 3600000 / 60000;
  return hours.toInt().toString() +
      " hr" +
      " " +
      minutes.toInt().toString() +
      " min";
}

Future<Uint8List?> getBytesFromAsset(String path, int width) async {
  if (path.isNotEmpty) {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  } else {
    return null;
  }
}

LatLngBounds boundsFromLatLngList(List<dynamic> list) {
  assert(list.isNotEmpty);
  double? x0, x1, y0, y1;
  list.forEach((value) {
    if (x0 == null) {
      x0 = x1 = value.latitude;
      y0 = y1 = value.longitude;
    } else {
      if (value.latitude > x1) x1 = value.latitude;
      if (value.latitude < x0) x0 = value.latitude;
      if (value.longitude > y1) y1 = value.longitude;
      if (value.longitude < y0) y0 = value.longitude;
    }
  });
  return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
}

LatLngBounds boundsFromLatLngGeofenceList(Set<Marker> list) {
  assert(list.length > 0);
  double? x0, x1, y0, y1;
  list.forEach((value) {
    if (x0 == null) {
      x0 = x1 = value.position.latitude;
      y0 = y1 = value.position.longitude;
    } else {
      if (value.position.latitude > x1!) x1 = value.position.latitude;
      if (value.position.latitude < x0!) x0 = value.position.latitude;
      if (value.position.longitude > y1!) y1 = value.position.longitude;
      if (value.position.longitude < y0!) y0 = value.position.longitude;
    }
  });
  return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
}

Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
    String path, int width) async {
  final Uint8List? imageData = await getBytesFromAsset(path, width);
  return BitmapDescriptor.fromBytes(imageData!);
}

String formatReportDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date.toLocal());
}

String formatReportTime(TimeOfDay timeOfDay) {
  return timeOfDay.hour.toString() + ":" + timeOfDay.minute.toString();
}

String convertCourse(double course) {
  if ((course >= 15) && (course < 75)) {
    return "NE";
  } else if ((course >= 75) && (course < 105)) {
    return "E";
  } else if ((course >= 105) && (course < 165)) {
    return "SE";
  } else if ((course >= 165) && (course < 195)) {
    return "S";
  } else if ((course >= 195) && (course < 255)) {
    return "SW";
  } else if ((course >= 255) && (course < 285)) {
    return "W";
  } else if ((course >= 285) && (course < 345)) {
    return "NW";
  } else {
    return "N";
  }
}
