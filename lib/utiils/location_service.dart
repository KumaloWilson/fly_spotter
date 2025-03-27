import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationService {
  // Get current position
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      Get.snackbar(
        'Location Services Disabled',
        'Please enable location services to use this feature.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        Get.snackbar(
          'Permission Denied',
          'Location permissions are denied. Please enable them in app settings.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      Get.snackbar(
        'Permission Denied',
        'Location permissions are permanently denied. Please enable them in app settings.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // When we reach here, permissions are granted and we can get the position
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get current location: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Get address from coordinates
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return "${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      return "Unknown location";
    }
  }
}

