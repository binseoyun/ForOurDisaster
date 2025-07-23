import 'package:geolocator/geolocator.dart';

Future<bool> checkLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  return permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
}
