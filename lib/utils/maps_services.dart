import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_/models/location_info/lat_lng.dart';
import 'package:route_tracker_/models/location_info/location.dart';
import 'package:route_tracker_/models/location_info/location_info.dart';
import 'package:route_tracker_/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_/models/routes_model/routes_model.dart';
import 'package:route_tracker_/utils/google_maps_places_services.dart';
import 'package:route_tracker_/utils/location_services.dart';
import 'package:route_tracker_/utils/routes_services.dart';

class MapsServices {
  LocationService locationService = LocationService() ;
  GoogleMapsPlacesServices googleMapsPlacesServices = GoogleMapsPlacesServices() ;
  RoutesServices routesServices = RoutesServices() ;

  Future<void> getPredictions( { required String input , required List<PlaceModel> places , required String sessionToken } ) async {
    if (input.isNotEmpty) {
      var result = await googleMapsPlacesServices.getPredictions(
        input: input,
      );
      places.clear();
      places.addAll(result);
    } else {
      places.clear();
    }
  }

  Future<LatLng> updateCurrentLocation({required GoogleMapController googleMapController , required Set<Marker> markers }) async {
    try {
      var locationData = await locationService.getLocation();
      LatLng currentPosition = LatLng(locationData.latitude!, locationData.longitude!);

      Marker currentPositionMarker = Marker(
        markerId: MarkerId("current"),
        position: currentPosition,
      );
      CameraPosition myCurrentCameraPoistion = CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 16,
      );

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(myCurrentCameraPoistion),
      );
      markers.add(currentPositionMarker);
      return currentPosition ;
    } on LocationServiceException {
      throw Exception('Location services Exception') ;
    } on LocationPermissionException {
      throw Exception('Location permission Exception') ;
    } catch (e) {
      throw Exception('unexpected error') ;
    }
  }

  getLatLngBounds({required List<LatLng> points}) {
    var southwestlat =  points.first.latitude ;
    var southwestlng = points.first.longitude ;
    var northEastlat = points.first.latitude ;
    var northEastlng = points.first.longitude ;

    for (var point in points) {
      southwestlat = min(southwestlat, point.latitude);
      southwestlng = min(southwestlng, point.longitude);
      northEastlat = max(northEastlat, point.latitude);
      northEastlng = max(northEastlng, point.longitude);

    }
}

  void displayRoute({ required List<LatLng> points ,required Set<Polyline> polylines }) {
    Polyline route = Polyline(
      polylineId: PolylineId("polyline id"),
      points: points,
      color: Colors.blueAccent,
      width: 5,
    );
    polylines.add(route) ;
  }


  List<LatLng> getDecodedRoute({ required RoutesModel routes}) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(
      routes.routes!.first.polyline!.encodedPolyline!,
    );
    List<LatLng> points =
        result.map((e) => LatLng(e.latitude, e.longitude)).toList();
    return points;
  }



  Future<List<LatLng>> getRouteData({ required LatLng currentPosition , required LatLng destination }) async {
    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
        ),
      ),
    );
    LocationInfoModel destinationModel = LocationInfoModel(
      location: LocationModel(
        latLng: LatLngModel(
          latitude: destination.latitude,
          longitude: destination.longitude,
        ),
      ),
    );
    var routes = await routesServices.fetchRoutes(
      origin: origin,
      destination: destinationModel,
    );
    var points = getDecodedRoute( routes: routes);
    return points;
  }

}