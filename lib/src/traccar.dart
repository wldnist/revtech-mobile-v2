import 'dart:convert';

import 'package:gpspro/src/model/CommandModel.dart';
import 'package:gpspro/src/model/MaintenanceModel.dart';
import 'package:gpspro/src/model/NotificationModel.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/Device.dart';
import 'model/Event.dart';
import 'model/GeofenceModel.dart';
import 'model/NotificationType.dart';
import 'model/PositionModel.dart';
import 'model/RouteReport.dart';
import 'model/Stop.dart';
import 'model/Summary.dart';
import 'model/Trip.dart';

class Traccar {
  /// Sends an HTTP POST request with the given headers and body to the given URL.
  ///
  /// [body] sets the body of the request. It can be a [String], a [List<int>] or
  /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
  /// used as the body of the request. The content-type of the request will
  /// default to "text/plain".
  ///
  /// If [body] is a List, it's used as a list of bytes for the body of the
  /// request.
  ///
  /// If [body] is a Map, it's encoded as form fields using [encoding]. The
  /// content-type of the request will be set to
  /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
  ///
  /// [encoding] defaults to [utf8].
  ///
  /// For more fine-grained control over the request, use [Request] or
  /// [StreamedRequest] instead.
  static Map<String, String> headers = {};
  static String? serverURL;
  static String? socketURL;

  static Future<http.Response?> login(_purchaseCode, email, password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // final response = await http.get(Uri.parse(
    //     "http://gennissi.com/gpspro/verify.php?code=" +
    //         _purchaseCode +
    //         "&domain=" +
    //         serverURL));
    //
    // if (json.decode(response.body)["success"] == true) {
    if (prefs.containsKey('url')) {
      serverURL = prefs.get('url').toString();
      var uri = Uri.parse(serverURL!);

      String socketScheme;
      if (uri.scheme == "http") {
        socketScheme = "ws://";
      } else {
        socketScheme = "wss://";
      }

      if (uri.hasPort) {
        socketURL =
            socketScheme + uri.host + ":" + uri.port.toString() + "/api/socket";
      } else {
        socketURL = socketScheme + uri.host + "/api/socket";
      }
    } else {
      serverURL = "http://demo.traccar.org";
    }

    print(serverURL);

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    Map<String, String> header = {
      "Content-Type": "application/x-www-form-urlencoded"
    };
    try {
      final response = await http.post(Uri.parse(serverURL! + "/api/session"),
          body: {"email": email, "password": password}, headers: header);

      updateCookie(response);

      /// Sends an HTTP POST request with the given headers and body to the given URL.
      ///
      /// [body] sets the body of the request. It can be a [String], a [List<int>] or
      /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
      /// used as the body of the request. The content-type of the request will
      /// default to "text/plain".
      ///
      /// If [body] is a List, it's used as a list of bytes for the body of the
      /// request.
      ///
      /// If [body] is a Map, it's encoded as form fields using [encoding]. The
      /// content-type of the request will be set to
      /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
      ///
      /// [encoding] defaults to [utf8].
      ///
      /// For more fine-grained control over the request, use [Request] or
      /// [StreamedRequest] instead.
      if (response.statusCode == 200) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return null;
    }
    // } else {
    //   return response;
    // }
  }

  static Future<List<Device>?> getDevices() async {
    final response = await http.get(Uri.parse(serverURL! + "/api/devices"),
        headers: headers);

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Device.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<PositionModel>?> getPositionById(
      String deviceId, String posId) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/positions?deviceId=" +
            deviceId +
            "&id=" +
            posId),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => PositionModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<PositionModel>?> getPositions(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/positions?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => PositionModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<PositionModel>?> getLatestPositions() async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(Uri.parse(serverURL! + "/api/positions"),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => PositionModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Device>?> getDevicesById(String id) async {
    final response = await http
        .get(Uri.parse(serverURL! + "/api/devices?id=" + id), headers: headers);

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Device.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> sessionLogout() async {
    headers['content-type'] = "application/x-www-form-urlencoded";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.delete(Uri.parse(serverURL! + "/api/session"),
        headers: headers);
    return response;
  }

  static Future<http.Response> getSendCommands(String id) async {
    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! + "/api/commands/types?deviceId=" + id),
        headers: headers);
    return response;
  }

  static Future<http.Response> sendCommands(String command) async {
    headers['content-type'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.post(
        Uri.parse(serverURL! + "/api/commands/send"),
        body: command,
        headers: headers);
    return response;
  }

  static Future<http.Response> updateUser(String user, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.put(Uri.parse(serverURL! + "/api/users/" + id),
        body: user, headers: headers);
    print(response.body);
    return response;
  }

  static Future<List<RouteReport>?> getRoute(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/route?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => RouteReport.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<NotificationTypeModel>?> getNotificationTypes() async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! + "/api/notifications/types"),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list
          .map((model) => NotificationTypeModel.fromJson(model))
          .toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Event>?> getEvents(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/events?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Event.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<Event?> getEventById(String id) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(Uri.parse(serverURL! + "/api/events/" + id),
        headers: headers);
    if (response.statusCode == 200) {
      return Event.fromJson(json.decode(response.body));
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Event>?> getAllDeviceEvents(
      var deviceId, String from, String to) async {
    var uri =
    Uri(queryParameters: {'deviceId': deviceId, 'from': from, 'to': to});
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! + "/api/reports/events" + uri.toString()),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Event.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Trip>?> getTrip(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/trips?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Trip.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Stop>?> getStops(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/stops?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Stop.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Summary>?> getSummary(
      String deviceId, String from, String to) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! +
            "/api/reports/summary?deviceId=" +
            deviceId +
            "&from=" +
            from +
            "&to=" +
            to),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Summary.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<GeofenceModel>?> getGeoFencesByUserID(
      String userID) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! + "/api/geofences?userId=" + userID),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => GeofenceModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<GeofenceModel>?> getGeoFencesByDeviceID(
      String deviceId) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(serverURL! + "/api/geofences?deviceId=" + deviceId),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => GeofenceModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> addGeofence(String fence) async {
    headers['content-type'] = "application/json; charset=utf-8";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.post(Uri.parse(serverURL! + "/api/geofences"),
        body: fence, headers: headers);
    return response;
  }

  static Future<http.Response> addDevice(String device) async {
    headers['content-type'] = "application/json; charset=utf-8";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.post(Uri.parse(serverURL! + "/api/devices"),
        body: device, headers: headers);
    return response;
  }

  static Future<http.Response> updateGeofence(String fence, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.put(
        Uri.parse(serverURL! + "/api/geofences/" + id),
        body: fence,
        headers: headers);
    return response;
  }

  static Future<http.Response> updateDevices(String fence, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.put(
        Uri.parse(serverURL! + "/api/devices/" + id),
        body: fence,
        headers: headers);
    return response;
  }

  static Future<http.Response> addPermission(String permission) async {
    headers['content-type'] = "application/json; charset=utf-8";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.post(Uri.parse(serverURL! + "/api/permissions"),
        body: permission, headers: headers);
    return response;
  }

  static Future<StreamedResponse> deletePermission(deviceId, fenceId) async {
    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    http.Request rq =
    http.Request('DELETE', Uri.parse(serverURL! + "/api/permissions"))
      ..headers;
    rq.headers.addAll(<String, String>{
      "Accept": "application/json",
      "Content-type": "application/json; charset=utf-8",
      "cookie": headers['cookie'].toString()
    });
    rq.body = jsonEncode({"deviceId": deviceId, "geofenceId": fenceId});

    return http.Client().send(rq);
  }

  static updateCookie(http.Response response) {
    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    String rawCookie = response.headers['set-cookie'].toString();
    // ignore: unnecessary_null_comparison
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
      (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  static Future<http.Response> deleteGeofence(dynamic id) async {
    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http
        .delete(Uri.parse(serverURL! + "/api/geofences/$id"), headers: headers);
    return response;
  }

  static Future<http.Response?> geocode(String lat, String lng) async {
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(
            serverURL! + "/api/server/geocode?latitude=$lat&longitude=$lng"),
        headers: headers);
    if (response.statusCode == 200) {
      return response;
    } else {
      print(response.statusCode);
      return null;
    }
  }


  static Future<List<NotificationModel>?> getNotifications() async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.get(
        Uri.parse(serverURL! + "/api/notifications"),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list
          .map((model) => NotificationModel.fromJson(model))
          .toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<NotificationModel?> addNotifications(String notification) async {
    headers['Accept'] = "application/json";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.post(
        Uri.parse(serverURL! + "/api/notifications"),
        body: notification,
        headers: headers);
    if (response.statusCode == 200) {
      return NotificationModel.fromJson(json.decode(response.body));
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> deleteNotifications(String id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http
        .delete(Uri.parse(serverURL! + "/api/notifications/$id"), headers: headers);
    return response;
  }

  static Future<StreamedResponse> deleteMaintenancePermission(deviceId, fenceId) async {
    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    http.Request rq =
    http.Request('DELETE', Uri.parse(serverURL! + "/api/permissions"))
      ..headers;
    rq.headers.addAll(<String, String>{
      "Accept": "application/json",
      "Content-type": "application/json; charset=utf-8",
      "cookie": headers['cookie'].toString()
    });
    rq.body = jsonEncode({"deviceId": deviceId, "maintenanceId": fenceId});

    return http.Client().send(rq);
  }

  static Future<List<CommandModel>?> getSavedCommands(id) async {
    final response = await http.get(
        Uri.parse(serverURL! + "/api/commands/send?deviceId=" + id.toString()),
        headers: Traccar.headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => CommandModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<MaintenanceModel>?> getMaintenance() async {
    final response = await http.get(
        Uri.parse(serverURL! + "/api/maintenance"),
        headers: Traccar.headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => MaintenanceModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<MaintenanceModel>?> getMaintenanceByDeviceId(String id) async {
    final response = await http.get(
        Uri.parse(serverURL! + "/api/maintenance?deviceId=" + id.toString()),
        headers: Traccar.headers);
    if (response.statusCode == 200) {
      print(response.body);
      Iterable list = json.decode(response.body);
      return list.map((model) => MaintenanceModel.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> deleteMaintenance(dynamic id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http
        .delete(Uri.parse(serverURL! + "/api/maintenance/$id"), headers: headers);
    return response;
  }

  static Future<http.Response> addMaintenance(String m) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.post(Uri.parse(serverURL! + "/api/maintenance"),
        body: m, headers: headers);
    print(response.body);
    return response;
  }

  static Future<http.Response> updateMaintenance(String m) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.post(Uri.parse(serverURL! + "/api/maintenance"),
        body: m, headers: headers);
    print(response.body);
    return response;
  }

  static Future<http.Response> updateNotification(String notification, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";

    /// Sends an HTTP POST request with the given headers and body to the given URL.
    ///
    /// [body] sets the body of the request. It can be a [String], a [List<int>] or
    /// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
    /// used as the body of the request. The content-type of the request will
    /// default to "text/plain".
    ///
    /// If [body] is a List, it's used as a list of bytes for the body of the
    /// request.
    ///
    /// If [body] is a Map, it's encoded as form fields using [encoding]. The
    /// content-type of the request will be set to
    /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
    ///
    /// [encoding] defaults to [utf8].
    ///
    /// For more fine-grained control over the request, use [Request] or
    /// [StreamedRequest] instead.
    final response = await http.put(Uri.parse(serverURL! + "/api/notifications/" + id),
        body: notification, headers: headers);
    return response;
  }
}
