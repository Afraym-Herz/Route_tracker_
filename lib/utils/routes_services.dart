import 'package:route_tracker_/models/location_info/location_info.dart';
import 'package:route_tracker_/models/route_modifiers.dart';
import 'package:route_tracker_/models/routes_model/route.dart';
import 'package:http/http.dart' as http;

class RoutesServices {
  final String baseUrl =
      "https://routes.googleapis.com/directions/v2:computeRoutes";
  final String apiKey = 'AIzaSyC87Tt3tfO6aYids0BZStXXbrdAy05jQCI';

  Future<RouteModel> fetchRoutes({ required LocationInfo origin , required  LocationInfo destination , RoutesModifiers? routeModifiers }) async {
    Uri uri = Uri.parse(baseUrl);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
    };

    Map<String, dynamic> body = {
      "origin": origin.toJson(),
      "destination":destination.toJson(),
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": routeModifiers?.toJson() ?? RoutesModifiers().toJson() ,
      "languageCode": "en-US",
      "units": "IMPERIAL",
    };
  }
}
