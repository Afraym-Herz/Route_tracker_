import 'dart:convert';

import 'package:http/http.dart' as http ;
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';
  
  class GoogleMapsPlacesServices {
final String apiKey = "AIzaSyC87Tt3tf06aYids0BZStXXbrdAy05jQCI";
final String baseUrl = "https://maps.googleapis.com/maps/api/place";

Future<List<PlaceModel>> getPredictions ({required String input}) async {
  var response = await http.get(Uri.parse("$baseUrl/autocompelte/json?apiKey=$apiKey&input=$input"));
  
  
  if (response.statusCode == 200 ){
    var data = jsonDecode(response.body)["predictions"] ;
  List<PlaceModel> places = [] ;
  for (var item in data  ) {
    places.add(PlaceModel.fromJson(item));
    return places ;
  }
  }
 throw Exception() ;
}
  }