import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route_tracker_/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker_/models/place_details_model/place_details_model.dart';
import 'package:route_tracker_/utils/google_maps_places_services.dart';

class CustomListView extends StatelessWidget {
  CustomListView({
    super.key,
    required this.places,
    required this.googleMapsPlacesServices,
    required this.onSelectedPlace,
  });
  List<PlaceModel> places;
  final GoogleMapsPlacesServices googleMapsPlacesServices;
  final void Function(PlaceDetailsModel) onSelectedPlace;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(places[index].description!),
            leading: Icon(FontAwesomeIcons.mapPin),
            trailing: IconButton(
              icon: Icon(FontAwesomeIcons.circleArrowRight),
              onPressed: () async {
                var placeDetails = await googleMapsPlacesServices
                    .getPlaceDetails(placeId: places[index].placeId.toString());
                onSelectedPlace(placeDetails);
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(height: 0);
        },
        itemCount: places.length,
      ),
    );
  }
}
