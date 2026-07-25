// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import '../../services/map_service.dart';

// class TrackingScreen extends StatefulWidget {
//   final String requestId;

//   const TrackingScreen({super.key, required this.requestId});

//   @override
//   State<TrackingScreen> createState() => _TrackingScreenState();
// }

// class _TrackingScreenState extends State<TrackingScreen> {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   GoogleMapController? mapController;

//   final PolylinePoints polylinePoints = PolylinePoints();

//   StreamSubscription<DocumentSnapshot>? driverSubscription;

//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};

//   LatLng? patientLocation;
//   LatLng? driverLocation;
//   LatLng? hospitalLocation;

//   String driverId = "";

//   String driverName = "Waiting...";
//   String driverPhone = "";

//   String ambulanceNo = "";

//   String hospitalName = "";
//   String hospitalAddress = "";

//   String status = "searching";

//   double distance = 0;

//   String eta = "--";

//   bool mapReady = false;

//   @override
//   void initState() {
//     super.initState();

//     loadAssignment();
//   }

//   @override
//   void dispose() {
//     driverSubscription?.cancel();
//     mapController?.dispose();
//     super.dispose();
//   }

//   Future<void> drawPolyline() async {
//     if (driverLocation == null || patientLocation == null) return;

//     final result = await polylinePoints.getRouteBetweenCoordinates(
//       googleApiKey: "YAIzaSyC2s1_HU-3zAlPRiNynwqANtthHjR0fxJ0",
//       request: PolylineRequest(
//         origin: PointLatLng(
//           driverLocation!.latitude,
//           driverLocation!.longitude,
//         ),
//         destination: PointLatLng(
//           patientLocation!.latitude,
//           patientLocation!.longitude,
//         ),
//         mode: TravelMode.driving,
//       ),
//     );
//     print("Status: ${result.status}");
//     print("Error: ${result.errorMessage}");
//     print("Points: ${result.points.length}");

//     if (result.points.isEmpty) return;

//     final routePoints = result.points
//         .map((e) => LatLng(e.latitude, e.longitude))
//         .toList();

//     polylines = {
//       Polyline(
//         polylineId: const PolylineId("route"),
//         points: routePoints,
//         width: 6,
//         color: Colors.blue,
//       ),
//     };

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   Future<void> loadAssignment() async {
//     firestore
//         .collection("ambulance_assignments")
//         .where("requestId", isEqualTo: widget.requestId)
//         .limit(1)
//         .snapshots()
//         .listen((snapshot) async {
//           if (snapshot.docs.isEmpty) return;

//           final data = snapshot.docs.first.data();

//           status = (data["status"] ?? "searching").toString();

//           driverId = (data["driverId"] ?? "").toString();

//           driverName = (data["driverName"] ?? "").toString();

//           driverPhone = (data["driverPhone"] ?? "").toString();

//           ambulanceNo = (data["ambulanceNo"] ?? "").toString();

//           hospitalName = (data["hospitalName"] ?? "").toString();

//           hospitalAddress = (data["hospitalAddress"] ?? "").toString();

//           final pickupLat = (data["pickupLatitude"] as num?)?.toDouble() ?? 0;

//           final pickupLng = (data["pickupLongitude"] as num?)?.toDouble() ?? 0;

//           patientLocation = LatLng(pickupLat, pickupLng);

//           final hospitalLat = (data["hospitalLatitude"] as num?)?.toDouble();

//           final hospitalLng = (data["hospitalLongitude"] as num?)?.toDouble();

//           if (hospitalLat != null && hospitalLng != null) {
//             hospitalLocation = LatLng(hospitalLat, hospitalLng);
//           }
//           print("Patient Location: $patientLocation");
//           print("Hospital Location: $hospitalLocation");
//           print("Driver ID: $driverId");

//           updateMarkers();

//           if (driverId.isNotEmpty) {
//             listenDriver(driverId);
//           }

//           if (mounted) {
//             setState(() {});
//           }
//         });
//   }

//   void listenDriver(String id) {
//     driverSubscription?.cancel();

//     driverSubscription = firestore
//         .collection("drivers")
//         .doc(id)
//         .snapshots()
//         .listen((snapshot) async {
//           if (!snapshot.exists) return;

//           final driver = snapshot.data()!;

//           driverName = (driver["name"] ?? "").toString();
//           driverPhone = (driver["phone"] ?? "").toString();
//           ambulanceNo = (driver["ambulanceNo"] ?? "").toString();

//           final lat = (driver["latitude"] as num?)?.toDouble() ?? 0;

//           final lng = (driver["longitude"] as num?)?.toDouble() ?? 0;

//           driverLocation = LatLng(lat, lng);
//           print("Driver Location: $driverLocation");
//           print("Latitude: $lat");
//           print("Longitude: $lng");

//           if (patientLocation != null) {
//             distance = MapService.instance.calculateDistance(
//               start: driverLocation!,
//               end: patientLocation!,
//             );

//             if (distance <= 1) {
//               eta = "2 min";
//             } else if (distance <= 3) {
//               eta = "5 min";
//             } else if (distance <= 5) {
//               eta = "10 min";
//             } else if (distance <= 10) {
//               eta = "15 min";
//             } else {
//               eta = "${(distance / 0.6).ceil()} min";
//             }
//           }

//           updateMarkers();

//           // await drawPolyline();

//           await moveCamera();

//           if (mounted) {
//             setState(() {});
//           }
//         });
//   }

//   void updateMarkers() {
//     final updatedMarkers = <Marker>{};

//     if (patientLocation != null) {
//       updatedMarkers.add(
//         Marker(
//           markerId: const MarkerId("patient"),
//           position: patientLocation!,
//           infoWindow: const InfoWindow(title: "Patient"),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         ),
//       );
//     }

//     if (driverLocation != null) {
//       updatedMarkers.add(
//         Marker(
//           markerId: const MarkerId("driver"),
//           position: driverLocation!,
//           rotation: (driverLocation == null || patientLocation == null)
//               ? 0
//               : MapService.instance.getBearing(
//                   start: driverLocation!,
//                   end: patientLocation!,
//                 ),
//           infoWindow: InfoWindow(
//             title: ambulanceNo.isEmpty ? "Ambulance" : ambulanceNo,
//             snippet: driverName,
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//     }

//     if (hospitalLocation != null) {
//       updatedMarkers.add(
//         Marker(
//           markerId: const MarkerId("hospital"),
//           position: hospitalLocation!,
//           infoWindow: InfoWindow(title: hospitalName, snippet: hospitalAddress),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueGreen,
//           ),
//         ),
//       );
//     }

//     markers = updatedMarkers;
//     print("Markers Count: ${markers.length}");
//   }

//   Future<void> moveCamera() async {
//     if (!mapReady) return;
//     if (driverLocation == null || patientLocation == null) return;

//     double southLat = driverLocation!.latitude < patientLocation!.latitude
//         ? driverLocation!.latitude
//         : patientLocation!.latitude;

//     double northLat = driverLocation!.latitude > patientLocation!.latitude
//         ? driverLocation!.latitude
//         : patientLocation!.latitude;

//     double westLng = driverLocation!.longitude < patientLocation!.longitude
//         ? driverLocation!.longitude
//         : patientLocation!.longitude;

//     double eastLng = driverLocation!.longitude > patientLocation!.longitude
//         ? driverLocation!.longitude
//         : patientLocation!.longitude;

//     if (hospitalLocation != null) {
//       southLat = [
//         southLat,
//         hospitalLocation!.latitude,
//       ].reduce((a, b) => a < b ? a : b);

//       northLat = [
//         northLat,
//         hospitalLocation!.latitude,
//       ].reduce((a, b) => a > b ? a : b);

//       westLng = [
//         westLng,
//         hospitalLocation!.longitude,
//       ].reduce((a, b) => a < b ? a : b);

//       eastLng = [
//         eastLng,
//         hospitalLocation!.longitude,
//       ].reduce((a, b) => a > b ? a : b);
//     }

//     final bounds = LatLngBounds(
//       southwest: LatLng(southLat, westLng),
//       northeast: LatLng(northLat, eastLng),
//     );

//     await mapController?.animateCamera(
//       CameraUpdate.newLatLngBounds(bounds, 90),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Live Ambulance Tracking"),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 3,
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: patientLocation ?? const LatLng(23.3441, 85.3096),
//                 zoom: 15,
//               ),
//               markers: markers,
//               polylines: polylines,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               compassEnabled: true,
//               zoomControlsEnabled: false,
//               trafficEnabled: true,
//               buildingsEnabled: true,
//               indoorViewEnabled: false,
//               mapToolbarEnabled: false,
//               rotateGesturesEnabled: true,
//               tiltGesturesEnabled: true,
//               scrollGesturesEnabled: true,
//               zoomGesturesEnabled: true,
//               onMapCreated: (controller) async {
//                 mapController = controller;
//                 mapReady = true;

//                 await moveCamera();
//               },
//             ),
//           ),

//           Expanded(
//             flex: 2,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Card(
//                     elevation: 3,
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: status == "completed"
//                             ? Colors.green
//                             : status == "arrived"
//                             ? Colors.blue
//                             : status == "accepted"
//                             ? Colors.orange
//                             : Colors.red,
//                         child: const Icon(
//                           Icons.local_hospital,
//                           color: Colors.white,
//                         ),
//                       ),
//                       title: Text(
//                         status.toUpperCase(),
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: const Text("Current Ambulance Status"),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   Card(
//                     elevation: 3,
//                     child: ListTile(
//                       leading: const CircleAvatar(child: Icon(Icons.person)),
//                       title: Text(
//                         driverName.isEmpty ? "Waiting for Driver" : driverName,
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             driverPhone.isEmpty
//                                 ? "Driver not assigned"
//                                 : driverPhone,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             ambulanceNo.isEmpty
//                                 ? "Ambulance Pending"
//                                 : ambulanceNo,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   Card(
//                     elevation: 3,
//                     child: ListTile(
//                       leading: const CircleAvatar(child: Icon(Icons.route)),
//                       title: Text("${distance.toStringAsFixed(2)} km"),
//                       subtitle: Text("ETA : $eta"),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   if (hospitalName.isNotEmpty)
//                     Card(
//                       elevation: 3,
//                       child: ListTile(
//                         leading: const CircleAvatar(
//                           child: Icon(Icons.local_hospital),
//                         ),
//                         title: Text(hospitalName),
//                         subtitle: Text(
//                           hospitalAddress.isEmpty
//                               ? "Assigned Hospital"
//                               : hospitalAddress,
//                         ),
//                       ),
//                     ),

//                   const SizedBox(height: 20),

//                   if (driverLocation != null)
//                     SizedBox(
//                       width: double.infinity,
//                       height: 55,
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.my_location),
//                         label: const Text("Locate Ambulance"),
//                         onPressed: () async {
//                           await mapController?.animateCamera(
//                             CameraUpdate.newCameraPosition(
//                               CameraPosition(target: driverLocation!, zoom: 17),
//                             ),
//                           );
//                         },
//                       ),
//                     ),

//                   const SizedBox(height: 12),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 55,
//                     child: OutlinedButton.icon(
//                       icon: const Icon(Icons.refresh),
//                       label: const Text("Refresh Tracking"),
//                       onPressed: () async {
//                         updateMarkers();
//                         // await drawPolyline();
//                         await moveCamera();

//                         if (mounted) {
//                           setState(() {});
//                         }
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   SizedBox(
//                     width: double.infinity,
//                     height: 55,
//                     child: OutlinedButton.icon(
//                       icon: const Icon(Icons.arrow_back),
//                       label: const Text("Back"),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/map_service.dart';

class TrackingScreen extends StatefulWidget {
  final String requestId;

  const TrackingScreen({super.key, required this.requestId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  GoogleMapController? mapController;

  final PolylinePoints polylinePoints = PolylinePoints();

  StreamSubscription<DocumentSnapshot>? driverSubscription;

  StreamSubscription<QuerySnapshot>? assignmentSubscription;

  Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  LatLng? patientLocation;
  LatLng? driverLocation;
  LatLng? hospitalLocation;

  String driverId = "";

  String driverName = "Waiting...";

  String driverPhone = "";

  String ambulanceNo = "";

  String hospitalName = "";

  String hospitalAddress = "";

  String status = "searching";

  double distance = 0;

  String eta = "--";

  bool mapReady = false;

  /// Disable because Google Directions API requires billing.
  static const bool enablePolyline = false;

  @override
  void initState() {
    super.initState();

    loadAssignment();
  }

  @override
  void dispose() {
    assignmentSubscription?.cancel();
    driverSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> drawPolyline() async {
    if (!enablePolyline) return;

    if (driverLocation == null || patientLocation == null) return;

    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: "YOUR_GOOGLE_MAPS_API_KEY",
        request: PolylineRequest(
          origin: PointLatLng(
            driverLocation!.latitude,
            driverLocation!.longitude,
          ),
          destination: PointLatLng(
            patientLocation!.latitude,
            patientLocation!.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isEmpty) return;

      final routePoints = result.points
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();

      if (!mounted) return;

      setState(() {
        polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            points: routePoints,
            width: 6,
            color: Colors.blue,
          ),
        };
      });
    } catch (e) {
      debugPrint("Polyline Error: $e");
    }
  }

  Future<void> loadAssignment() async {
    assignmentSubscription?.cancel();

    assignmentSubscription = firestore
        .collection("ambulance_assignments")
        .where("requestId", isEqualTo: widget.requestId)
        .limit(1)
        .snapshots()
        .listen(
          (snapshot) async {
            if (snapshot.docs.isEmpty) {
              debugPrint("No assignment found.");
              return;
            }

            final data = snapshot.docs.first.data();

            status = (data["status"] ?? "searching").toString();

            final newDriverId = (data["driverId"] ?? "").toString();

            driverName = (data["driverName"] ?? "").toString();

            driverPhone = (data["driverPhone"] ?? "").toString();

            ambulanceNo = (data["ambulanceNo"] ?? "").toString();

            hospitalName = (data["hospitalName"] ?? "").toString();

            hospitalAddress = (data["hospitalAddress"] ?? "").toString();

            final pickupLat = (data["pickupLatitude"] as num?)?.toDouble();

            final pickupLng = (data["pickupLongitude"] as num?)?.toDouble();

            if (pickupLat != null && pickupLng != null) {
              patientLocation = LatLng(pickupLat, pickupLng);
            }

            final hospitalLat = (data["hospitalLatitude"] as num?)?.toDouble();

            final hospitalLng = (data["hospitalLongitude"] as num?)?.toDouble();

            if (hospitalLat != null && hospitalLng != null) {
              hospitalLocation = LatLng(hospitalLat, hospitalLng);
            } else {
              hospitalLocation = null;
            }

            debugPrint("========== Assignment ==========");
            debugPrint("Status : $status");
            debugPrint("Driver : $newDriverId");
            debugPrint("Patient : $patientLocation");
            debugPrint("Hospital : $hospitalLocation");
            debugPrint("===============================");

            /// Update markers immediately
            updateMarkers();

            /// Move camera if map is ready
            if (mapReady) {
              await moveCamera();
            }

            /// Start driver listener only if driver changes
            if (newDriverId.isNotEmpty && newDriverId != driverId) {
              driverId = newDriverId;
              listenDriver(driverId);
            }

            if (!mounted) return;

            setState(() {});
          },
          onError: (e) {
            debugPrint("Assignment Listener Error : $e");
          },
        );
  }

  void listenDriver(String id) {
    driverSubscription?.cancel();

    driverSubscription = firestore
        .collection("drivers")
        .doc(id)
        .snapshots()
        .listen(
          (snapshot) async {
            if (!snapshot.exists) return;

            final driver = snapshot.data()!;

            driverName = (driver["name"] ?? "").toString();
            driverPhone = (driver["phone"] ?? "").toString();
            ambulanceNo = (driver["ambulanceNo"] ?? "").toString();

            final lat = (driver["latitude"] as num?)?.toDouble();
            final lng = (driver["longitude"] as num?)?.toDouble();

            if (lat == null || lng == null) return;

            driverLocation = LatLng(lat, lng);

            debugPrint("========== Driver ==========");
            debugPrint("Driver Location : $driverLocation");
            debugPrint("===========================");

            if (patientLocation != null) {
              distance = MapService.instance.calculateDistance(
                start: driverLocation!,
                end: patientLocation!,
              );

              if (distance <= 1) {
                eta = "2 min";
              } else if (distance <= 3) {
                eta = "5 min";
              } else if (distance <= 5) {
                eta = "10 min";
              } else if (distance <= 10) {
                eta = "15 min";
              } else {
                eta = "${(distance / 0.6).ceil()} min";
              }
            }

            updateMarkers();

            if (enablePolyline) {
              await drawPolyline();
            }

            if (mapReady) {
              await moveCamera();
            }
          },
          onError: (e) {
            debugPrint("Driver Listener Error : $e");
          },
        );
  }

  void updateMarkers() {
    final Set<Marker> updatedMarkers = {};

    if (patientLocation != null) {
      updatedMarkers.add(
        Marker(
          markerId: const MarkerId("patient"),
          position: patientLocation!,
          infoWindow: const InfoWindow(title: "Patient"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    if (driverLocation != null) {
      updatedMarkers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: driverLocation!,
          rotation: (patientLocation == null)
              ? 0
              : MapService.instance.getBearing(
                  start: driverLocation!,
                  end: patientLocation!,
                ),
          flat: true,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: ambulanceNo.isEmpty ? "Ambulance" : ambulanceNo,
            snippet: driverName,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    if (hospitalLocation != null) {
      updatedMarkers.add(
        Marker(
          markerId: const MarkerId("hospital"),
          position: hospitalLocation!,
          infoWindow: InfoWindow(title: hospitalName, snippet: hospitalAddress),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    debugPrint("Markers : ${updatedMarkers.length}");

    if (!mounted) return;

    debugPrint("Markers : ${updatedMarkers.length}");

    if (!mounted) return;

    setState(() {
      markers = updatedMarkers;
    });
  }

  Future<void> moveCamera() async {
    if (!mapReady) return;

    if (mapController == null) return;

    try {
      // -------------------------------
      // Only Patient Available
      // -------------------------------
      if (patientLocation != null &&
          driverLocation == null &&
          hospitalLocation == null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: patientLocation!, zoom: 17),
          ),
        );
        return;
      }

      // -------------------------------
      // Patient + Driver
      // -------------------------------
      if (patientLocation != null &&
          driverLocation != null &&
          hospitalLocation == null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            patientLocation!.latitude < driverLocation!.latitude
                ? patientLocation!.latitude
                : driverLocation!.latitude,
            patientLocation!.longitude < driverLocation!.longitude
                ? patientLocation!.longitude
                : driverLocation!.longitude,
          ),
          northeast: LatLng(
            patientLocation!.latitude > driverLocation!.latitude
                ? patientLocation!.latitude
                : driverLocation!.latitude,
            patientLocation!.longitude > driverLocation!.longitude
                ? patientLocation!.longitude
                : driverLocation!.longitude,
          ),
        );

        await mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 120),
        );

        return;
      }

      // -------------------------------
      // Patient + Driver + Hospital
      // -------------------------------
      if (patientLocation != null &&
          driverLocation != null &&
          hospitalLocation != null) {
        final latitudes = [
          patientLocation!.latitude,
          driverLocation!.latitude,
          hospitalLocation!.latitude,
        ];

        final longitudes = [
          patientLocation!.longitude,
          driverLocation!.longitude,
          hospitalLocation!.longitude,
        ];

        latitudes.sort();
        longitudes.sort();

        final bounds = LatLngBounds(
          southwest: LatLng(latitudes.first, longitudes.first),
          northeast: LatLng(latitudes.last, longitudes.last),
        );

        await mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 160),
        );
      }
    } catch (e) {
      debugPrint("Camera Error : $e");

      // Fallback camera
      if (driverLocation != null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: driverLocation!, zoom: 17),
          ),
        );
      } else if (patientLocation != null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: patientLocation!, zoom: 17),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Ambulance Tracking"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          /// ==========================
          /// GOOGLE MAP
          /// ==========================
          Expanded(
            flex: 3,
            child: GoogleMap(
              key: const ValueKey("tracking_map"),

              initialCameraPosition: CameraPosition(
                target: patientLocation ?? const LatLng(23.3985, 85.2697),
                zoom: 17,
              ),

              markers: markers,

              polylines: polylines,

              myLocationEnabled: false,

              myLocationButtonEnabled: false,

              compassEnabled: true,

              zoomControlsEnabled: true,

              mapToolbarEnabled: false,

              trafficEnabled: true,

              buildingsEnabled: true,

              indoorViewEnabled: false,

              rotateGesturesEnabled: true,

              tiltGesturesEnabled: true,

              scrollGesturesEnabled: true,

              zoomGesturesEnabled: true,

              onMapCreated: (controller) async {
                mapController = controller;

                mapReady = true;

                /// Wait for first frame
                await Future.delayed(const Duration(milliseconds: 300));

                updateMarkers();

                await moveCamera();
              },
            ),
          ),

          /// ==========================
          /// INFORMATION
          /// ==========================
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [
                  Card(
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: status == "completed"
                            ? Colors.green
                            : status == "arrived"
                            ? Colors.blue
                            : status == "accepted"
                            ? Colors.orange
                            : Colors.red,

                        child: const Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        status.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: const Text("Current Ambulance Status"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    elevation: 3,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),

                      title: Text(
                        driverName.isEmpty ? "Waiting for Driver" : driverName,
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            driverPhone.isEmpty
                                ? "Driver not assigned"
                                : driverPhone,
                          ),

                          const SizedBox(height: 5),

                          Text(
                            ambulanceNo.isEmpty
                                ? "Ambulance Pending"
                                : ambulanceNo,

                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    elevation: 3,

                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.route)),

                      title: Text("${distance.toStringAsFixed(2)} km"),

                      subtitle: Text("ETA : $eta"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (hospitalName.isNotEmpty)
                    Card(
                      elevation: 3,

                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.local_hospital),
                        ),

                        title: Text(hospitalName),

                        subtitle: Text(
                          hospitalAddress.isEmpty
                              ? "Assigned Hospital"
                              : hospitalAddress,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (driverLocation != null)
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.my_location),

                        label: const Text("Locate Ambulance"),

                        onPressed: () async {
                          await mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: driverLocation!, zoom: 18),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),

                      label: const Text("Refresh Tracking"),

                      onPressed: () async {
                        updateMarkers();

                        if (enablePolyline) {
                          await drawPolyline();
                        }

                        await moveCamera();
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back),

                      label: const Text("Back"),

                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
