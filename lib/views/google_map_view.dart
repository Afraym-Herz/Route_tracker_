import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/utils/google_maps_places_services.dart';
import 'package:route_tracker/utils/location_services.dart';
import 'package:route_tracker/widgets/custom_list_view.dart';
import 'package:route_tracker/widgets/custom_text_field.dart';

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

  @override
  void initState() {
    initalCameraPoistion = const CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
    textEditingController = TextEditingController();
    googleMapsPlacesServices = GoogleMapsPlacesServices();
    fetchPrediction();
    super.initState();
  }

  void fetchPrediction() {
    textEditingController.addListener(() async {
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
              SizedBox(height: 16,), 
              CustomListView(places: places,),
            ],
          ),
          
        ),
      ],
    );
  }

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      LatLng currentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
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
}
