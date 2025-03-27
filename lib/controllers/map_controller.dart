import 'package:get/get.dart';
import '../models/fly_identification.dart';
import '../services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_model.dart';
import 'auth_controller.dart';
import 'identification_controller.dart';

class MapController extends GetxController {
  final LocationService _locationService = LocationService();
  final AuthController authController = Get.find<AuthController>();
  final IdentificationController identificationController = Get.find<IdentificationController>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<LocationModel?> currentLocation = Rx<LocationModel?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxList<IdentificationResult> mappedIdentifications = <IdentificationResult>[].obs;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
    loadIdentificationLocations();
  }

  @override
  void onClose() {
    mapController.value?.dispose();
    super.onClose();
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      currentLocation.value = await _locationService.getCurrentLocation();

      // Center map on current location if available
      if (currentLocation.value != null && mapController.value != null) {
        mapController.value!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(
              currentLocation.value!.latitude,
              currentLocation.value!.longitude,
            ),
          ),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Load identification locations
  Future<void> loadIdentificationLocations() async {
    if (authController.userModel.value == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Get identifications with location data
      mappedIdentifications.value = identificationController.identificationHistory
          .where((result) =>
      result.additionalData.containsKey('location') &&
          result.additionalData['location'] != null)
          .toList();

      // Create markers
      markers.clear();

      // Add current location marker if available
      if (currentLocation.value != null) {
        markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: LatLng(
              currentLocation.value!.latitude,
              currentLocation.value!.longitude,
            ),
            infoWindow: InfoWindow(
              title: 'Your Location',
              snippet: currentLocation.value!.address ?? 'Current Location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      }

      // Add identification markers
      for (var i = 0; i < mappedIdentifications.length; i++) {
        final result = mappedIdentifications[i];
        final locationData = result.additionalData['location'] as Map<String, dynamic>;
        final location = LocationModel.fromJson(locationData);

        markers.add(
          Marker(
            markerId: MarkerId('identification_${result.id}'),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: result.species.name,
              snippet: '${(result.confidenceScore * 100).toStringAsFixed(1)}% confidence',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () {
              // Show identification details
            },
          ),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Set map controller
  void setMapController(GoogleMapController controller) {
    mapController.value = controller;

    // Center map on current location if available
    if (currentLocation.value != null) {
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            currentLocation.value!.latitude,
            currentLocation.value!.longitude,
          ),
        ),
      );
    }
  }

  // Get camera position for current location
  CameraPosition get initialCameraPosition {
    if (currentLocation.value != null) {
      return CameraPosition(
        target: LatLng(
          currentLocation.value!.latitude,
          currentLocation.value!.longitude,
        ),
        zoom: 14,
      );
    }

    // Default position (will be updated when location is available)
    return CameraPosition(
      target: LatLng(0, 0),
      zoom: 2,
    );
  }
}

