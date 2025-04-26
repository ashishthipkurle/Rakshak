import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'settings.dart';
import 'history.dart';
import 'general.dart';
import 'leaderboard.dart';
import 'requests.dart';
import 'locations.dart';
import '../widgets/carousel.dart';

class Home extends StatefulWidget {
  final String userId;
  final bool isLoggedIn;

  const Home({
    Key? key,
    required this.userId,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late Future<Position> currentLocation;
  final Box boxLogin = Hive.box("login");
  late AnimationController _animationController;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    currentLocation = _determinePosition();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String firstName = boxLogin.get("fname") ?? "Guest";
    String lastName = boxLogin.get("lname") ?? "";
    final String? bloodGroup = boxLogin.get("bloodGroup") ?? "A+";
    final int totalDonations = boxLogin.get("totalDonations") ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        toolbarHeight: 100,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Welcome, $firstName",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.waving_hand,
                      color: Colors.amber[300],
                      size: 18,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bloodtype,
                        color: Colors.red[100],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bloodGroup!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Donations",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "$totalDonations",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.event_available,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Hero(
                  tag: 'events_carousel',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FutureBuilder<Position>(
                        future: currentLocation,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data?.longitude != null && snapshot.data?.latitude != null) {
                              boxLogin.put("latitude", snapshot.data!.latitude);
                              boxLogin.put("longitude", snapshot.data!.longitude);
                            } else {
                              boxLogin.put("latitude", 0);
                              boxLogin.put("longitude", 0);
                            }

                            final dynamic picture = boxLogin.get("picture");
                            final int pictureValue = (picture is int) ? picture : int.tryParse(picture.toString()) ?? 0;

                            return Carousel(picture: pictureValue);
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 57.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimationLimiter(
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      6,
                          (index) => AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: _buildActionCard(index, context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(int index, BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        "title": "Blood Bank & Events",
        "icon": Icons.location_on,
        "target": const Locations(),
        "color": Colors.blue[400]!,
      },
      {
        "title": "Donation History",
        "icon": Icons.article,
        "target": const History(),
        "color": Colors.green[400]!,
      },
      {
        "title": "Leaderboard",
        "icon": Icons.leaderboard,
        "target": const Leaderboard(),
        "color": Colors.amber[700]!,
      },
      {
        "title": "Request Blood",
        "icon": Icons.handshake_rounded,
        "target": const Requests(),
        "color": Colors.red[400]!,
      },
      {
        "title": "General Info",
        "icon": Icons.info,
        "target": const General(),
        "color": Colors.purple[400]!,
      },
      {
        "title": "Settings",
        "icon": Icons.settings,
        "target": const Settings(),
        "color": Colors.blueGrey[600]!,
      },
    ];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => actions[index]["target"],
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: actions[index]["color"].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                actions[index]["icon"],
                size: 32,
                color: actions[index]["color"],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              actions[index]["title"],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Refresh location data
    currentLocation = _determinePosition();

    // Wait for the location to update
    await currentLocation.then((position) {
      if (position.longitude != null && position.latitude != null) {
        boxLogin.put("latitude", position.latitude);
        boxLogin.put("longitude", position.longitude);
      }
    }).catchError((error) {
      print("Error refreshing location: $error");
    });

    // Force widget rebuild
    setState(() {});
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}