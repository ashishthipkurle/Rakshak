import 'package:flutter/material.dart';
import 'package:Rakshak/api.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MyRequests extends StatefulWidget {
  const MyRequests({super.key});

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  ApiService apiService = ApiService();
  final Box _boxLogin = Hive.box("login");
  String _filterStatus = "All";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  bool _isRefreshing = false;

  final List<String> _statusFilters = ["All", "Fulfilled", "Unfulfilled"];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
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
    String phoneNumber = _boxLogin.get("phoneNumber").toString();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.red,
        child: FadeIn(
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                      hintText: 'Search by blood group, type or address...',
                      prefixIcon: const Icon(Icons.search, color: Colors.red),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),

              // Filter chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusFilters.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(_statusFilters[index]),
                        selected: _filterStatus == _statusFilters[index],
                        selectedColor: Colors.red.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _filterStatus == _statusFilters[index]
                              ? Colors.red
                              : Colors.grey[700],
                          fontWeight: _filterStatus == _statusFilters[index]
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _filterStatus = _statusFilters[index];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // Request List
              Expanded(
                child: FutureBuilder<List>(
                  future: apiService.getRequests(phoneNumber),
                  builder: (context, snapshot) {
                    if (_isRefreshing || snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingView();
                    } else if (snapshot.hasError) {
                      return _buildErrorView(snapshot.error.toString());
                    } else if (snapshot.hasData) {
                      final requestData = snapshot.data as List;

                      if (requestData.isEmpty) {
                        return _buildEmptyView();
                      }

                      // Filter by status if needed
                      var filteredData = requestData;
                      if (_filterStatus == "Fulfilled") {
                        filteredData = requestData.where((request) =>
                        request['fulfilled_by'] != null).toList();
                      } else if (_filterStatus == "Unfulfilled") {
                        filteredData = requestData.where((request) =>
                        request['fulfilled_by'] == null).toList();
                      }

                      // Filter by search query if needed
                      if (_searchQuery.isNotEmpty) {
                        filteredData = filteredData.where((request) =>
                        request['bloodGroup'].toString().toLowerCase().contains(_searchQuery) ||
                            request['bloodType'].toString().toLowerCase().contains(_searchQuery) ||
                            request['address'].toString().toLowerCase().contains(_searchQuery)
                        ).toList();
                      }

                      if (filteredData.isEmpty) {
                        return _buildNoResultsView();
                      }

                      return AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _buildRequestCard(context, filteredData[index]),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return _buildEmptyView();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map requestData) {
    bool isFulfilled = requestData['fulfilled_by'] != null;
    DateTime requestDate = DateTime.parse(requestData['requestDate']);
    DateTime needByDate = DateTime.parse(requestData['needByDate']);
    bool isUrgent = needByDate.difference(DateTime.now()).inDays <= 2;

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show detailed view
            _showRequestDetails(context, requestData);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isFulfilled ? Colors.green[50] : (isUrgent ? Colors.red[50] : Colors.orange[50]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isFulfilled ? "Fulfilled" : (isUrgent ? "Urgent" : "Pending"),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isFulfilled ? Colors.green[700] : (isUrgent ? Colors.red[700] : Colors.orange[700]),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Requested on: ${DateFormat('MMM d, yyyy').format(requestDate)}",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        "Blood Group",
                        requestData['bloodGroup'],
                        Icons.bloodtype,
                        Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        "Blood Type",
                        requestData['bloodType'],
                        Icons.category,
                        Colors.purple,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        "Quantity",
                        "${requestData['quantity']} units",
                        Icons.scale,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      "Needed by: ",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy - h:mm a').format(needByDate),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isUrgent ? Colors.red[700] : Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        requestData['address'],
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isFulfilled) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Fulfilled by: ${requestData['fulfilled_by']}",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  void _showRequestDetails(BuildContext context, Map requestData) {
    bool isFulfilled = requestData['fulfilled_by'] != null;
    DateTime requestDate = DateTime.parse(requestData['requestDate']);
    DateTime needByDate = DateTime.parse(requestData['needByDate']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Request Details",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFulfilled ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFulfilled ? "Fulfilled" : "Pending",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isFulfilled ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTimelineItem(
              title: "Request Created",
              time: DateFormat('MMM d, yyyy - h:mm a').format(requestDate),
              isCompleted: true,
              isFirst: true,
            ),
            _buildTimelineItem(
              title: "Processing",
              time: "Blood banks notified",
              isCompleted: true,
            ),
            _buildTimelineItem(
              title: "Matching Donors",
              time: "Finding compatible donors",
              isCompleted: isFulfilled,
            ),
            _buildTimelineItem(
              title: "Fulfillment",
              time: isFulfilled
                  ? "Fulfilled by ${requestData['fulfilled_by']}"
                  : "Waiting for fulfillment",
              isCompleted: isFulfilled,
              isLast: true,
            ),
            const SizedBox(height: 24),
            Text(
              "Request Information",
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow("Blood Group", requestData['bloodGroup']),
            _buildDetailRow("Blood Type", requestData['bloodType']),
            _buildDetailRow("Quantity", "${requestData['quantity']} units"),
            _buildDetailRow("Need By", DateFormat('MMM d, yyyy - h:mm a').format(needByDate)),
            _buildDetailRow("Delivery Address", requestData['address']),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFulfilled
                    ? null
                    : () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Request status updated",
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  isFulfilled ? "Fulfilled" : "Update Request",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required bool isCompleted,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
              Text(
                time,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? Colors.grey[800] : Colors.grey[500],
                  ),
                ),
              ),
              SizedBox(height: isLast ? 0 : 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
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
          Icon(Icons.bloodtype_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            "No Requests Yet",
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
              "You haven't made any blood requests. Create a new request when you need blood.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            "No Matching Requests",
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
              "No requests match your current filters. Try adjusting your search or filter settings.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}