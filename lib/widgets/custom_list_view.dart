import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:route_tracker/models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomListView extends StatelessWidget {
   CustomListView({super.key , required this.places });
   List<PlaceModel> places ;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated (
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(title: Text(places[index].description!) , 
           leading: Icon(FontAwesomeIcons.mapPin ) ,
           trailing: IconButton(
            icon: Icon(FontAwesomeIcons.circleArrowRight) ,
            onPressed: () {},
            ) ,
           ) ;
        },
        separatorBuilder: (context, index) {
          return Divider(height: 0,) ;
        },
        itemCount: places.length ,
      
      ),
    );
  }
}