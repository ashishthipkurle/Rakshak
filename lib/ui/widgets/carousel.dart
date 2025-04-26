import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_pkg;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:Rakshak/api.dart';

class Carousel extends StatefulWidget {
  final int picture;

  const Carousel({Key? key, required this.picture}) : super(key: key);

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final Box boxLogin = Hive.box("login");
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
  }

  Future<void> _checkAndRequestLocationPermission() async {
    setState(() => _isLoading = true);

    final double? storedLat = boxLogin.get("latitude");
    final double? storedLng = boxLogin.get("longitude");

    if (storedLat != null && storedLat != 0 && storedLng != null && storedLng != 0) {
      setState(() => _isLoading = false);
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      await boxLogin.put("latitude", position.latitude);
      await boxLogin.put("longitude", position.longitude);

      setState(() {});
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        height: 150,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final double latitude = boxLogin.get("latitude") ?? 0.0;
    final double longitude = boxLogin.get("longitude") ?? 0.0;

    if (latitude == 0 || longitude == 0) {
      return buildNoLocationContainer(context);
    } else {
      return FutureBuilder<List>(
        future: apiService.getEvents(latitude, longitude),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final events = snapshot.data as List;

            if (events.isEmpty) {
              return buildNoEventsContainer(context);
            }

            return buildTextBasedCarousel(context, events);
          } else {
            return buildNoEventsContainer(context);
          }
        },
      );
    }
  }

  Widget buildTextBasedCarousel(BuildContext context, List events) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade100,
            Colors.red.shade300,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: carousel_pkg.CarouselSlider.builder(
        itemCount: events.length,
        itemBuilder: (context, index, realIndex) {
          final event = events[index];
          final name = event['name'] as String? ?? 'No Name';
          final description = event['description'] as String? ?? 'No Description';
          final location = event['location'] as String? ?? 'No Location';

          String dateStr = 'No Date';
          if (event['date'] != null) {
            try {
              final dateTime = DateTime.parse(event['date'].toString());
              dateStr = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
            } catch (e) {
              dateStr = event['date'].toString();
            }
          }

          return Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 8),
                  Text('Location: $location'),
                  const SizedBox(height: 8),
                  Text('Date: $dateStr'),
                ],
              ),
            ),
          );
        },
        options: carousel_pkg.CarouselOptions(
          height: 180,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.easeInOut,
          pauseAutoPlayOnTouch: true,
          aspectRatio: 16 / 9,
          viewportFraction: 0.9,
        ),
      ),
    );
  }

  Widget buildNoLocationContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).dividerColor,
            Theme.of(context).disabledColor,
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Please turn on your location to view upcoming events.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Icon(
                FontAwesomeIcons.circleExclamation,
                color: Colors.red,
                size: 40,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _checkAndRequestLocationPermission,
                child: const Text("Enable Location"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNoEventsContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).dividerColor,
            Theme.of(context).disabledColor,
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 150,
        child: const Center(
          child: Text(
            "No upcoming events found in your area",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}