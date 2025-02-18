import 'dart:async';

import 'package:route_tracker_/utils/maps_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker_/models/place_autocomplete_model/place_autocomplete_model.dart';
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
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  List<PlaceModel> places = [];
  Set<Marker> markers = {};
  late Uuid uuid;
  String? sessionToken;
  late LatLng destination;
  Set<Polyline> polylines = {};
  late MapsServices mapsServices;
  late LatLng currentPosition;
  Timer? debounce;

  @override
  void initState() {
    initalCameraPoistion = const CameraPosition(target: LatLng(0, 0));
    textEditingController = TextEditingController();
    uuid = const Uuid();
    fetchPrediction();
    mapsServices = MapsServices();

    super.initState();
  }

  void fetchPrediction() {
    textEditingController.addListener(() async {
      debounce = Timer(const Duration(microseconds: 200), () async {
        if (debounce?.isActive ?? false) {
          debounce?.cancel();
        }
        sessionToken ??= uuid.v4();
        await mapsServices.getPredictions(
          input: textEditingController.text,
          sessionToken: sessionToken!,
          places: places,
        );
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    googleMapController.dispose();
    debounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: polylines,
          onMapCreated: (controller) async {
            googleMapController = controller;
            mapsServices.updateCurrentLocation(
              googleMapController: controller,
              markers: markers,
              onUpdatecurrentLocation: () {
                setState(() {});
              },
            );
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
              const SizedBox(height: 16),
              CustomListView(
                places: places,
                googleMapsPlacesServices: mapsServices.googleMapsPlacesServices,
                onSelectedPlace: (placeDetailsModel) async {
                  textEditingController.clear();
                  places.clear();
                  sessionToken = null;
                  setState(() {});
                  destination = LatLng(
                    placeDetailsModel.geometry!.location!.lat!,
                    placeDetailsModel.geometry!.location!.lng!,
                  );
                  var points = await mapsServices.getRouteData(
                    currentPosition: currentPosition,
                    destination: destination,
                  );
                  mapsServices.displayRoute(
                    points: points,
                    polylines: polylines,
                  );
                  var bounds = mapsServices.getLatLngBounds(points: points);
                  googleMapController.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 16),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
