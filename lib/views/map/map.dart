import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/map_controller.dart';
import '../../widgets/custom_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = Get.find<MapController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Identification Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              mapController.getCurrentLocation();
              mapController.loadIdentificationLocations();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Map to be implemented here'
        ),
      )

      // Stack(
      //   children: [
      //     Obx(() {
      //       return GoogleMap(
      //         initialCameraPosition: mapController.initialCameraPosition,
      //         markers: mapController.markers,
      //         myLocationEnabled: true,
      //         myLocationButtonEnabled: false,
      //         mapType: MapType.normal,
      //         zoomControlsEnabled: false,
      //         onMapCreated: (controller) {
      //           mapController.setMapController(controller);
      //         },
      //       );
      //     }),
      //     Positioned(
      //       bottom: 16,
      //       right: 16,
      //       child: Column(
      //         children: [
      //           FloatingActionButton(
      //             heroTag: 'btn_location',
      //             mini: true,
      //             child: Icon(Icons.my_location),
      //             onPressed: () => mapController.getCurrentLocation(),
      //           ),
      //           SizedBox(height: 8),
      //           FloatingActionButton(
      //             heroTag: 'btn_list',
      //             mini: true,
      //             child: Icon(Icons.list),
      //             onPressed: () => _showIdentificationsList(context),
      //           ),
      //         ],
      //       ),
      //     ),
      //     Positioned(
      //       top: 16,
      //       left: 16,
      //       right: 16,
      //       child: Obx(() {
      //         if (mapController.errorMessage.isNotEmpty) {
      //           return Container(
      //             padding: EdgeInsets.all(12),
      //             decoration: BoxDecoration(
      //               color: Colors.red.withOpacity(0.9),
      //               borderRadius: BorderRadius.circular(8),
      //             ),
      //             child: Text(
      //               mapController.errorMessage.value,
      //               style: TextStyle(color: Colors.white),
      //             ),
      //           );
      //         }
      //         return SizedBox.shrink();
      //       }),
      //     ),
      //     Obx(() {
      //       if (mapController.isLoading.value) {
      //         return Center(
      //           child: CircularProgressIndicator(),
      //         );
      //       }
      //       return SizedBox.shrink();
      //     }),
      //   ],
      // ),
    );
  }

  // void _showIdentificationsList(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Container(
  //         padding: EdgeInsets.all(16),
  //         constraints: BoxConstraints(
  //           maxHeight: MediaQuery.of(context).size.height * 0.6,
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Identification Locations',
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close),
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 8),
  //             Obx(() {
  //               if (mapController.mappedIdentifications.isEmpty) {
  //                 return Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Center(
  //                     child: Text(
  //                       'No identifications with location data yet',
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ),
  //                 );
  //               }
  //
  //               return Expanded(
  //                 child: ListView.builder(
  //                   itemCount: mapController.mappedIdentifications.length,
  //                   itemBuilder: (context, index) {
  //                     final result = mapController.mappedIdentifications[index];
  //                     final locationData = result.additionalData['location'] as Map<String, dynamic>;
  //
  //                     return CustomCard(
  //                       padding: EdgeInsets.all(12),
  //                      // margin: EdgeInsets.only(bottom: 8),
  //                       onTap: () {
  //                         // Center map on this location
  //                         if (mapController.mapController.value != null) {
  //                           mapController.mapController.value!.animateCamera(
  //                             CameraUpdate.newLatLng(
  //                               LatLng(
  //                                 locationData['latitude'],
  //                                 locationData['longitude'],
  //                               ),
  //                             ),
  //                           );
  //                           Navigator.pop(context);
  //                         }
  //                       },
  //                       child: Row(
  //                         children: [
  //                           ClipRRect(
  //                             borderRadius: BorderRadius.circular(8),
  //                             child: Image.network(
  //                               result.imageUrl,
  //                               width: 60,
  //                               height: 60,
  //                               fit: BoxFit.cover,
  //                             ),
  //                           ),
  //                           SizedBox(width: 12),
  //                           Expanded(
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text(
  //                                   result.species.name,
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 4),
  //                                 Text(
  //                                   locationData['address'] ?? 'Unknown location',
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.grey[600],
  //                                   ),
  //                                   maxLines: 2,
  //                                   overflow: TextOverflow.ellipsis,
  //                                 ),
  //                                 SizedBox(height: 4),
  //                                 Text(
  //                                   '${(result.confidenceScore * 100).toStringAsFixed(1)}% confidence',
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Theme.of(context).primaryColor,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           Icon(Icons.chevron_right),
  //                         ],
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               );
  //             }),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}

