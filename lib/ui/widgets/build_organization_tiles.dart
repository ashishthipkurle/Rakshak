import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rounded_expansion_tile/rounded_expansion_tile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Widget buildOrganizationTiles(
    BuildContext context, int index, List organizationData) {
  // Extract data handling remains the same
  double latitude;
  if (organizationData[index]['latitude'] is double) {
    latitude = organizationData[index]['latitude'];
  } else {
    latitude = double.tryParse(organizationData[index]['latitude'].toString()) ?? 0.0;
  }

  double longitude;
  if (organizationData[index]['longitude'] is double) {
    longitude = organizationData[index]['longitude'];
  } else {
    longitude = double.tryParse(organizationData[index]['longitude'].toString()) ?? 0.0;
  }

  String name = organizationData[index]['name']?.toString() ?? 'Unknown';
  String address = organizationData[index]['address']?.toString() ?? 'No address available';
  String contact = organizationData[index]['contact']?.toString() ?? 'No contact available';

  String distanceText = 'Unknown distance';
  if (organizationData[index]['distance'] != null) {
    double? distance = organizationData[index]['distance'] is double
        ? organizationData[index]['distance']
        : double.tryParse(organizationData[index]['distance'].toString());

    if (distance != null) {
      distanceText = '${distance.toStringAsFixed(2)} km away';
    }
  }

  return Padding(
    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: RoundedExpansionTile(
        minVerticalPadding: 10,
        duration: const Duration(milliseconds: 200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        tileColor: const Color(0xFF75AF4C),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                  letterSpacing: 1.2,
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: "Rubik",
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              distanceText,
              style: const TextStyle(
                  color: Colors.white, fontFamily: "Rubik", fontSize: 14),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_drop_down_rounded, size: 50, color: Colors.white),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.green[50],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Address:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "Rubik"),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    address,
                    style: const TextStyle(fontSize: 16, fontFamily: "Rubik"),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Contact:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "Rubik"),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    contact,
                    style: const TextStyle(fontSize: 16, fontFamily: "Rubik"),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.28,
                    width: double.infinity,
                    child: buildMapSection(context, latitude, longitude),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildMapSection(BuildContext context, double latitude, double longitude) {
  if (kIsWeb) {
    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 12,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("marker_1"),
              position: LatLng(latitude, longitude),
            )
          },
        ),
      );
    } catch (e) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "Map not available",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5),
              Text(
                "Please try again later",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  } else {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("marker_1"),
            position: LatLng(latitude, longitude),
          )
        },
      ),
    );
  }
}

// New function to show all blood banks on a single map
Widget buildBloodBanksMap(BuildContext context, List organizationData, double userLatitude, double userLongitude) {
  // Create markers for all blood banks
  Set<Marker> markers = {};

  // Add user's location marker
  markers.add(
      Marker(
        markerId: const MarkerId("user_location"),
        position: LatLng(userLatitude, userLongitude),
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      )
  );

  // Add markers for all blood banks
  for (int i = 0; i < organizationData.length; i++) {
    double lat;
    double lng;

    if (organizationData[i]['latitude'] is double) {
      lat = organizationData[i]['latitude'];
    } else {
      lat = double.tryParse(organizationData[i]['latitude'].toString()) ?? 0.0;
    }

    if (organizationData[i]['longitude'] is double) {
      lng = organizationData[i]['longitude'];
    } else {
      lng = double.tryParse(organizationData[i]['longitude'].toString()) ?? 0.0;
    }

    String name = organizationData[i]['name']?.toString() ?? 'Unknown';

    markers.add(
        Marker(
          markerId: MarkerId("bank_$i"),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name),
        )
    );
  }

  return SizedBox(
    height: 300,
    width: double.infinity,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(userLatitude, userLongitude),
          zoom: 11,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    ),
  );
}
