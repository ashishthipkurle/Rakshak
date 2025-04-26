import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../api.dart';
import 'build_organization_tiles.dart';

class BloodBanks extends StatefulWidget {
  const BloodBanks({Key? key}) : super(key: key);

  @override
  State<BloodBanks> createState() => _BloodBanksState();
}

class _BloodBanksState extends State<BloodBanks> with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  final Box boxLogin = Hive.box("login");
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get user coordinates
    double latitude = boxLogin.get("latitude") ?? 0.0;
    double longitude = boxLogin.get("longitude") ?? 0.0;

    // Check if location is available
    if (latitude == 0 || longitude == 0) {
      return _buildLocationErrorView();
    }

    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              // Search bar and refresh button row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    // Search bar - now takes less width
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search blood banks...',
                            prefixIcon: const Icon(Icons.search, color: Colors.red),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                    // Refresh button moved here
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Material(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _refreshData,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.red,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.map),
                      text: "Map View",
                    ),
                    Tab(
                      icon: Icon(Icons.list),
                      text: "List View",
                    ),
                  ],
                ),
              ),

              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Map View
                    _buildBloodBanksList(latitude, longitude, isMap: true),

                    // List View
                    _buildBloodBanksList(latitude, longitude, isMap: false),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Removed floating action button from here
      ),
    );
  }

  Widget _buildLocationErrorView() {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 800),
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.locationCrosshairs,
                color: Colors.red[400],
                size: 70,
              ),
              const SizedBox(height: 24),
              Text(
                "Location Required",
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Please enable your location to view blood banks near you.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {}); // Refresh to check for location permission again
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  "Try Again",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 6,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            "Something went wrong",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Try Again", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_state.png', // Add this image to your assets
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            "No Blood Banks Found",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "We couldn't find any blood banks in your area. Try changing your location or try again later.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodBanksList(double latitude, double longitude, {required bool isMap}) {
    return FutureBuilder<List>(
      future: apiService.getBloodBanks(latitude, longitude),
      builder: (context, snapshot) {
        if (_isRefreshing || snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingView();
        } else if (snapshot.hasError) {
          return _buildErrorView(snapshot.error.toString());
        } else if (snapshot.hasData && snapshot.data is List) {
          final bloodBanks = snapshot.data as List;

          // Filter based on search query if not empty
          final filteredBloodBanks = _searchQuery.isEmpty
              ? bloodBanks
              : bloodBanks.where((bank) =>
          bank['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();

          if (filteredBloodBanks.isEmpty) {
            return _buildEmptyView();
          }

          if (isMap) {
            // Map View
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: buildBloodBanksMap(context, filteredBloodBanks, latitude, longitude),
              ),
            );
          } else {
            // List View
            return AnimationLimiter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredBloodBanks.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 300),
                      child: SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: buildOrganizationTiles(context, index, filteredBloodBanks),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        } else {
          return _buildEmptyView();
        }
      },
    );
  }
}