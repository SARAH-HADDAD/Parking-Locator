import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Home()
    );
  }
}

class Home extends  StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  //=Position(longitude: 3.05997, 36.7762, timestamp: null, accuracy: null, altitude: null, heading: null, speed: null, speedAccuracy: null);
  double long = 3.05997, lat =36.7762;
  late StreamSubscription<Position> positionStream;
  final key = 'AIzaSyAPESixyiDS-Ag-_tYl19IxqiMaK-PAANY';


  @override
  void initState() {
    checkGps();
    super.initState();
  }

  checkGps() async {
    //check if GPS is enabled:
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
      //check Location Permission or Request Location Permission:
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        }else if(permission == LocationPermission.deniedForever){
          print("'Location permissions are permanently denied");
        }else{
          haspermission = true;
        }
      }else{
        haspermission = true;
      }

      if(haspermission){
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    //get the current GPS locations such as Longitude and Latitude
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    long = position.longitude;
    lat = position.latitude;
    setState(() {
      //refresh UI
    });
//How to Listen to GPS Location: Longitude and Latitude Change Stream:

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {
      long = position.longitude;
      lat = position.latitude;

      setState(() {
        //refresh UI on update
      });
    });
  }
  Future<Map> getData() async{
    String api = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${long}&rankby=distance&keyword=parking&type=parking&key=AIzaSyAPESixyiDS-Ag-_tYl19IxqiMaK-PAANY";
    http.Response response = await http.get(Uri.parse(api));

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    String api = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${long}&rankby=distance&keyword=parking&type=parking&key=AIzaSyAPESixyiDS-Ag-_tYl19IxqiMaK-PAANY";
    double width = MediaQuery.of(context).size.width;
    return
      Scaffold(
          body:SingleChildScrollView(
          child : Column(children:<Widget> [
            if (long != 3.05997) Container(
                height: MediaQuery.of(context).size.height/3,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  markers: {Marker(markerId:MarkerId('_kGooglePlex'),
                    infoWindow: InfoWindow(title: 'Google Plex'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: LatLng(position.latitude,position.longitude),
                  )},
                  initialCameraPosition:CameraPosition(
                    target: LatLng(position.latitude,position.longitude),
                    zoom: 14.4746,

                  ),
                )
            ) else Text("wait"),
            ParkingGetter(width),
          ],
          )
          )
      );
  }
  FutureBuilder<Map<dynamic, dynamic>> ParkingGetter(double width) {
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot ){
          //Whare we get all JSON data, we set up widgets
          if(snapshot.hasData)
          {
            // return Text(snapshot.data.toString());

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(), // this to make the list view non scrollable
              shrinkWrap: true, // this to tell the list view tahkem un minimum de place au cas ou thewsi tefehmi kollech mdrr
              itemCount: snapshot.data!["results"].length,
              itemBuilder: (context, index) {
                // String parking = snapshot.data!["results"][index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    SizedBox(
                        height: 200,
                        width: width,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 5),
                                  child: Text(
                                    snapshot.data!["results"][index]["name"],
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 10),
                                  child:Row(children:<Widget> [
                                    RatingBarIndicator(
                                      rating: (snapshot.data!["results"][index]["rating"]).toDouble(),
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 17.0,
                                      direction: Axis.horizontal,
                                    ),
                                    Text(
                                      " (${snapshot.data!["results"][index]["user_ratings_total"].toString()})                                                              ",
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),

                                     IconButton(
                                      icon: const Icon(Icons.directions, size: 30.0),
                                       padding: new EdgeInsets.all(0.0),
                                       color: Theme.of(context).primaryColor,
                                      onPressed: () {},
                                    ),
                                  ],),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 10),
                                  child: Text(
                                    snapshot.data!["results"][index]["vicinity"],
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 10),
                                  child:Text(
                                    "${(Geolocator.distanceBetween(lat,long, snapshot.data!["results"][index]["geometry"]["location"]["lat"],snapshot.data!["results"][index]["geometry"]["location"]["lng"])).round()} Meters",
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        )
                    ),
                    const SizedBox(height: 15,),
                    // Widget to display the list of project
                  ],
                );
              },
            );

          }
          else
          {
            return const Text("Error 404",
              style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w600 ),
            );
          }
        });}
}