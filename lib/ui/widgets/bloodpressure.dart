import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Rakshak/api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';

class BloodPressure extends StatefulWidget {
  const BloodPressure({super.key});

  @override
  State<BloodPressure> createState() => _BloodPressureState();
}

class _BloodPressureState extends State<BloodPressure> {
  ApiService apiService = ApiService();
  final Box _boxLogin = Hive.box("login");

  Future<Map<String, dynamic>> _fetchBloodPressureData() async {
    final String phoneNumber = _boxLogin.get('phoneNumber');
    return await apiService.getDonations(phoneNumber, 'donations');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchBloodPressureData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final donations = snapshot.data!['donations'] as List<dynamic>;

          if (donations.isEmpty) {
            return _buildNoDonationsScreen();
          } else {
            return _buildDonationsScreen(donations);
          }
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildNoDonationsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.heartPulse,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'No blood pressure data available.',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your blood pressure readings will appear here\nafter your first donation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsScreen(List<dynamic> donations) {
    // Debug the donations data
    print('Received ${donations.length} donations: $donations');

    // Organize donations by month year
    final Map<int, Map<String, dynamic>> monthlyData = {};

    // Process the donations data
    for (final donation in donations) {
      // Debug each donation
      print('Processing donation: ${donation['donationDate']}, upperBP: ${donation['upperBP']}, lowerBP: ${donation['lowerBP']}');

      // Verify data types
      print('BP data types - upperBP: ${donation['upperBP']?.runtimeType}, lowerBP: ${donation['lowerBP']?.runtimeType}');

      final DateTime donationDate = DateTime.parse(donation['donationDate']);
      final int yearMonthInteger = donationDate.year * 100 + donationDate.month;

      // Convert to integers if they're coming as strings
      final upperBP = donation['upperBP'] != null ?
      (donation['upperBP'] is String ? int.tryParse(donation['upperBP']) : donation['upperBP']) : null;
      final lowerBP = donation['lowerBP'] != null ?
      (donation['lowerBP'] is String ? int.tryParse(donation['lowerBP']) : donation['lowerBP']) : null;

      if (upperBP != null && lowerBP != null) {
        if (!monthlyData.containsKey(yearMonthInteger)) {
          monthlyData[yearMonthInteger] = {
            "month": donationDate.month,
            "year": donationDate.year,
            "upperBP": upperBP,
            "lowerBP": lowerBP,
            "count": 1,
          };
        } else {
          final existingData = monthlyData[yearMonthInteger]!;
          final int existingCount = existingData["count"] as int;
          final int existingUpperBP = existingData["upperBP"] as int;
          final int existingLowerBP = existingData["lowerBP"] as int;

          monthlyData[yearMonthInteger] = {
            "month": donationDate.month,
            "year": donationDate.year,
            "upperBP": (existingUpperBP * existingCount + upperBP) ~/ (existingCount + 1),
            "lowerBP": (existingLowerBP * existingCount + lowerBP) ~/ (existingCount + 1),
            "count": existingCount + 1,
          };
        }
      }
    }

    print('Monthly data after processing: $monthlyData');

    // Create chart data
    List<FlSpot> upperSpots = [];
    List<FlSpot> lowerSpots = [];

    final sortedMonths = monthlyData.keys.toList()..sort();

    // Add data points for valid BP readings
    for (final yearMonthInteger in sortedMonths) {
      final bloodPressure = monthlyData[yearMonthInteger]!;
      final int month = bloodPressure["month"] as int;
      final int year = bloodPressure["year"] as int;
      final int? upperBP = bloodPressure["upperBP"];
      final int? lowerBP = bloodPressure["lowerBP"];

      // Calculate x position for the month
      final double xPosition = year + (month - 1) / 12;

      if (upperBP != null) {
        upperSpots.add(FlSpot(xPosition, upperBP.toDouble()));
      }

      if (lowerBP != null) {
        lowerSpots.add(FlSpot(xPosition, lowerBP.toDouble()));
      }
    }

    print('Upper spots: $upperSpots');
    print('Lower spots: $lowerSpots');

    // Check if we have any valid BP readings to display
    if (upperSpots.isEmpty || lowerSpots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.heartPulse,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              'No blood pressure readings recorded',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You have donations, but no blood pressure values were recorded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }


    // Get the latest BP if available
    int? latestSystolic;
    int? latestDiastolic;

    if (sortedMonths.isNotEmpty) {
      final latest = monthlyData[sortedMonths.last]!;
      latestSystolic = latest['upperBP'];
      latestDiastolic = latest['lowerBP'];
    }

    // Return the chart UI if we have data
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BP Status Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Blood Pressure Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Latest BP Reading
                      Column(
                        children: [
                          const Text(
                            'Latest Reading',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (latestSystolic != null && latestDiastolic != null)
                                ? '$latestSystolic / $latestDiastolic'
                                : 'Not recorded',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'mmHg',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // BP Category
                      Column(
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _getBPCategory(latestSystolic, latestDiastolic),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Blood Pressure Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your blood pressure over time',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          // Line Chart
          SizedBox(
            height: 300,
            child: LineChart(
              _createLineChartData(upperSpots, lowerSpots),
            ),
          ),
          const SizedBox(height: 16),
          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Systolic', Colors.red),
              const SizedBox(width: 24),
              _buildLegendItem('Diastolic', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  LineChartData _createLineChartData(List<FlSpot> upperSpots, List<FlSpot> lowerSpots) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 20,
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              // Extract year and month from the float value correctly
              // x-position format is: year + (month-1)/12
              final int year = value.toInt();
              final int month = ((value - year) * 12).round() + 1;

              // Validate month range
              final String monthStr = (month >= 1 && month <= 12)
                  ? ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month]
                  : '???';

              return Text(
                '$monthStr\n$year',
                style: const TextStyle(fontSize: 10),
              );
            },
            interval: 1,
          ),
        ),
        // Keep your leftTitles as they are
      ),
      // Rest of your chart configuration
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: upperSpots.first.x - 0.5,
      maxX: upperSpots.last.x + 0.5,
      minY: 40, // Standard minimum for BP charts
      maxY: 200, // Standard maximum for BP charts
      lineBarsData: [
        _createLineBar(upperSpots, Colors.red),
        _createLineBar(lowerSpots, Colors.blue),
      ],
    );
  }

  LineChartBarData _createLineBar(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.2),
      ),
    );
  }

  Color _getBPColor(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) {
      return Colors.grey;
    }

    if (systolic >= 180 || diastolic >= 120) {
      return Colors.red[900]!;
    } else if (systolic >= 140 || diastolic >= 90) {
      return Colors.red;
    } else if (systolic >= 130 || diastolic >= 80) {
      return Colors.orange;
    } else if (systolic >= 90 && diastolic >= 60) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  Widget _getBPCategory(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) {
      return const Chip(
        label: Text('Not Recorded'),
        backgroundColor: Colors.grey,
        labelStyle: TextStyle(color: Colors.white),
      );
    }

    String category;
    Color color;

    if (systolic >= 180 || diastolic >= 120) {
      category = 'Hypertensive Crisis';
      color = Colors.red[900]!;
    } else if (systolic >= 140 || diastolic >= 90) {
      category = 'Hypertension';
      color = Colors.red;
    } else if (systolic >= 130 || diastolic >= 80) {
      category = 'Elevated';
      color = Colors.orange;
    } else if (systolic >= 90 && diastolic >= 60) {
      category = 'Normal';
      color = Colors.green;
    } else {
      category = 'Low';
      color = Colors.blue;
    }

    return Chip(
      label: Text(category),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}