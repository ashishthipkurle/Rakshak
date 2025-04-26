import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget buildTopDonorsSection(List topDonors) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      children: [
        const Text(
          "Top Donors",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Second place
              if (topDonors.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: buildTopDonorCard(topDonors[1], 2, Colors.grey.shade400),
                ),

              // First place (center, larger)
              if (topDonors.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: buildTopDonorCard(topDonors[0], 1, Colors.amber, isLarger: true),
                ),

              // Third place
              if (topDonors.length > 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: buildTopDonorCard(topDonors[2], 3, Colors.brown.shade300),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildTopDonorCard(dynamic donor, int position, Color medalColor, {bool isLarger = false}) {
  final String firstName = donor['first_name'] ?? '';
  final String lastName = donor['last_name'] ?? '';
  final int donations = donor['total_donations'] ?? 0;

  // Increase the size slightly to accommodate content
  final double size = isLarger ? 120.0 : 100.0;

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(4),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Medal and donation count
        SizedBox(
          height: isLarger ? 50 : 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                backgroundColor: medalColor.withOpacity(0.2),
                radius: isLarger ? 22 : 18,
                child: Icon(
                  FontAwesomeIcons.medal,
                  color: medalColor,
                  size: isLarger ? 22 : 18,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    donations.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLarger ? 10 : 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Name and donation text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First name
                Text(
                  firstName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isLarger ? 13 : 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                // Last name (if available)
                if (lastName.isNotEmpty)
                  Text(
                    lastName,
                    style: TextStyle(
                      fontSize: isLarger ? 11 : 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                // Donation amount
                Text(
                  "${donations * 450} mL",
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: isLarger ? 11 : 9,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildModernLeaderboardItem(BuildContext context, int index, dynamic userData) {
  if (userData == null) {
    return const SizedBox.shrink();
  }

  int rank = index + 1;
  final String firstName = userData['first_name'] ?? '';
  final String lastName = userData['last_name'] ?? '';
  final int donations = userData['total_donations'] ?? 0;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Hero(
      tag: "donor_${userData['email'] ?? rank}",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show donor details on tap
            _showDonorDetails(context, userData);
          },
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Rank
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      rank.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$firstName $lastName",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${donations * 450} mL donated",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Donations count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          donations.toString(),
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void _showDonorDetails(BuildContext context, dynamic userData) {
  final String firstName = userData['first_name'] ?? '';
  final String lastName = userData['last_name'] ?? '';
  final int donations = userData['total_donations'] ?? 0;
  final String bloodGroup = userData['blood_group'] ?? 'Unknown';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.red.shade100,
                child: Text(
                  "${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "$firstName $lastName",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Blood Group: $bloodGroup",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn("Donations", donations.toString()),
                _buildStatColumn("Blood Donated", "${donations * 450} mL"),
                _buildStatColumn("Lives Saved", "${(donations / 3).ceil()}"),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Donation History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // You would fetch actual donation history here
            // This is a placeholder
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: Icon(Icons.bloodtype, color: Colors.red.shade700),
                  ),
                  title: Text("Donation #${donations - index}"),
                  subtitle: Text("${DateTime.now().subtract(Duration(days: index * 90)).toString().substring(0, 10)}"),
                  trailing: const Text("450 mL"),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildStatColumn(String title, String value) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.red.shade600,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  );
}