import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

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
import 'package:route_tracker_/widgets/custom_list_view.dart';
import 'package:route_tracker_/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initalCameraPoistion;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late GoogleMapsPlacesServices googleMapsPlacesServices;
  List<PlaceModel> places = [];
  Set<Marker> markers = {};
  late Uuid uuid;
  String? sessionToken;
  late LatLng currentPosition;
  late LatLng destination;
  late RoutesServices routesServices;
  Set<Polyline> polylines = {};

  @override
  void initState() {
    initalCameraPoistion = const CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    textEditingController = TextEditingController();
    uuid = Uuid();
    googleMapsPlacesServices = GoogleMapsPlacesServices();
    fetchPrediction();
    routesServices = RoutesServices();

    super.initState();
  }

  void fetchPrediction() {
    textEditingController.addListener(() async {
      sessionToken ??= uuid.v4();
      if (textEditingController.text.isNotEmpty) {
        var result = await googleMapsPlacesServices.getPredictions(
          input: textEditingController.text,
        );
        places.clear();
        places.addAll(result);
        setState(() {});
      } else {
        places.clear();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: polylines,
          onMapCreated: (controller) {
            googleMapController = controller;
            updateCurrentLocation();
          },
          initialCameraPosition: initalCameraPoistion,
          zoomControlsEnabled: false,
          markers: markers,
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              customTextField(textEditingController: textEditingController),
              SizedBox(height: 16),
              CustomListView(
                places: places,
                googleMapsPlacesServices: googleMapsPlacesServices,
                onSelectedPlace: (placeDetailsModel) async {
                  textEditingController.clear();
                  places.clear();
                  sessionToken = null;
                  setState(() {});
                  destination = LatLng(
                    placeDetailsModel.geometry!.location!.lat!,
                    placeDetailsModel.geometry!.location!.lng!,
                  );
                  var points = await getRouteData();
                  displayRoute(points);
                  var bounds = getLatLngBounds(points: points) ;
                  googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 16));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      currentPosition = LatLng(locationData.latitude!, locationData.longitude!);

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
      setState(() {});
    } on LocationServiceException {
      // TODO:
    } on LocationPermissionException {
      // TODO :
    } catch (e) {
      // TODO:
    }
  }

  Future<List<LatLng>> getRouteData() async {
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
    var points = getDecodedRoute(routes);
    return points;
  }

  List<LatLng> getDecodedRoute(RoutesModel routes) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(
      routes.routes!.first.polyline!.encodedPolyline!,
    );
    List<LatLng> points =
        result.map((e) => LatLng(e.latitude, e.longitude)).toList();
    return points;
  }

  void displayRoute(List<LatLng> points) {
    Polyline route = Polyline(
      polylineId: PolylineId("polyline id"),
      points: points,
      color: Colors.blueAccent,
      width: 5,
    );
    polylines.add(route) ;
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
}
