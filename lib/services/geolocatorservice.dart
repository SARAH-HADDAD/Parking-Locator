import 'package:geolocator/geolocator.dart';
/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
class GeoLocatorService{
  Future<Position> geoLocation() async {
    var geolocation=Geolocation();
    retun await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
}