import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Search extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
body: Column(children:<Widget> [
  Container(
    height: MediaQuery.of(context).size.height/3,
    width: MediaQuery.of(context).size.width,
    child: GoogleMap(
      initialCameraPosition:CameraPosition(
          target: LatLng(37.42796133580664, -122.085749655962),
          zoom: 14.4746,

      ),
    ),
  )
],),

    );
  }
}