import 'package:geolocator/geolocator.dart';

class GeoLocatorService{
  late Position position;
Future<Position> getLocation() async {
  //get the current GPS locations such as Longitude and Latitude
  position= await Geolocator.getCurrentPosition({ LocationAccuracy desiredAccuracy = LocationAccuracy.best, bool forceAndroidLocationManager = false, Duration? timeLimit });
  return position;
}
}
