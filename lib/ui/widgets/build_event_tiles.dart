import 'package:flutter/material.dart';
import 'package:rounded_expansion_tile/rounded_expansion_tile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

Widget buildEventTiles(BuildContext context, int index, List eventData) {
  // Handle latitude - might already be a double or might be a string
  double latitude;
  if (eventData[index]['latitude'] is double) {
    latitude = eventData[index]['latitude'];
  } else {
    latitude = double.tryParse(eventData[index]['latitude'].toString()) ?? 0.0;
  }

  // Handle longitude - might already be a double or might be a string
  double longitude;
  if (eventData[index]['longitude'] is double) {
    longitude = eventData[index]['longitude'];
  } else {
    longitude = double.tryParse(eventData[index]['longitude'].toString()) ?? 0.0;
  }

  // Safe extraction of event data with null checks
  String name = eventData[index]['name']?.toString() ?? 'Unknown Event';
  String description = eventData[index]['description']?.toString() ?? 'No description available';
  String location = eventData[index]['location']?.toString() ?? 'No location information';

  // Format the date properly
  String formattedDate = 'Date not specified';
  if (eventData[index]['date'] != null) {
    try {
      DateTime eventDate = DateTime.parse(eventData[index]['date'].toString());
      formattedDate = DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(eventDate);
    } catch (e) {
      formattedDate = eventData[index]['date'].toString();
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
        tileColor: const Color(0xFF4CAF50),
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
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedDate,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Rubik",
                  fontSize: 14
              ),
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
                children: [
                  const Text(
                    "Description:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: "Rubik"
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, fontFamily: "Rubik"),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Location:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: "Rubik"
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 16, fontFamily: "Rubik"),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latitude, longitude),
                        zoom: 12,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("event_marker"),
                          position: LatLng(latitude, longitude),
                        )
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}