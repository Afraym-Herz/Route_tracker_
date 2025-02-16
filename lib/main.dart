import 'package:flutter/material.dart';
import 'package:route_tracker/views/google_map_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     
      home: Scaffold(  body:  SafeArea(child: GoogleMapView()) , resizeToAvoidBottomInset: false, )
    );
  }
}
