import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Rakshak/api.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class PastDonations extends StatefulWidget {
  const PastDonations({super.key});

  @override
  State<PastDonations> createState() => _PastDonationsState();
}

class _PastDonationsState extends State<PastDonations> with SingleTickerProviderStateMixin {
  ApiService apiService = ApiService();
  final Box _boxLogin = Hive.box("login");
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    HapticFeedback.mediumImpact();
    setState(() {});
    return Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    String phoneNumber = _boxLogin.get("phoneNumber").toString();
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.red,
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      child: FutureBuilder<Map<String, dynamic>>(
        future: apiService.getDonations(phoneNumber, "donations"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final jsonData = snapshot.data as Map<String, dynamic>;
            final donationData = jsonData['donations'] as List;
            final totalDonations = jsonData['totalDonations'] as int;
            _boxLogin.put("totalDonations", totalDonations);

            if (donationData.isEmpty) {
              return _buildEmptyState();
            }

            return _buildDonationsList(donationData, totalDonations);
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }

  Widget _buildDonationsList(List donationData, int totalDonations) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: _buildSummaryCard(totalDonations),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final donation = donationData[index];

                // Animation for staggered list items
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.05 * (index + 1)),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      0.4 + (index * 0.1).clamp(0.0, 0.6),
                      1.0,
                      curve: Curves.easeOutQuart,
                    ),
                  )),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.4 + (index * 0.1).clamp(0.0, 0.6),
                          1.0,
                          curve: Curves.easeOutQuart,
                        ),
                      ),
                    ),
                    child: _buildDonationCard(donation, index),
                  ),
                );
              },
              childCount: donationData.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int totalDonations) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade300, Colors.red.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Donation Summary",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                totalDonations.toString(),
                "Donations",
                Icons.favorite,
              ),
              _buildSummaryItem(
                "${totalDonations * 450}",
                "mL Blood",
                Icons.water_drop,
              ),
              _buildSummaryItem(
                "${totalDonations * 3}",
                "Lives Saved",
                Icons.people,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDonationCard(dynamic donation, int index) {
    // Format donation date
    String donationDate = donation['donationDate'] != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(donation['donationDate']))
        : 'N/A';

    // Try all possible field names for blood group
    String bloodType = donation['bloodGroup'] ??
        donation['blood_group'] ??
        donation['bloodtype'] ??
        donation['blood_type'] ?? 'N/A';

    // Try all possible field names for location
    String location = donation['bloodBank'] ??
        donation['blood_bank'] ??
        donation['location'] ??
        donation['hospital'] ??
        donation['donationLocation'] ?? 'N/A';

    // Handle blood pressure
    int upperBP = donation['upperBP'] ?? 0;
    int lowerBP = donation['lowerBP'] ?? 0;
    String bloodPressure = upperBP == 0 && lowerBP == 0
        ? 'N/A'
        : '$upperBP/$lowerBP';

    // Default quantity
    String quantity = donation['quantity'] ?? '450 ml';

    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          // Show detailed info in dialog/sheet
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          bloodType,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        donationDate,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quantity,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(Icons.local_hospital, location),
                  const SizedBox(width: 16),
                  _buildInfoItem(Icons.favorite_border, bloodPressure),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
              childCount: 5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load donations',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.volunteer_activism,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Donation Records',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You have not made any blood donations yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}