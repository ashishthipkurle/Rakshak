import 'package:flutter/material.dart';
import 'package:Rakshak/api.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class AllRequests extends StatefulWidget {
  const AllRequests({super.key});

  @override
  State<AllRequests> createState() => _AllRequestsState();
}

class _AllRequestsState extends State<AllRequests> {
  ApiService apiService = ApiService();
  final Box _boxLogin = Hive.box("login");
  bool _isLoading = false;

  Future<List> _fetchRequests() async {
    String currentUserPhone = _boxLogin.get("phoneNumber").toString();
    // For debugging
    var requests = await apiService.getAllRequests(currentUserPhone);
    print('Fetched ${requests.length} requests: $requests');
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    String currentUserPhone = _boxLogin.get("phoneNumber").toString();

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        return Future.value();
      },
      child: Stack(
        children: [
          FutureBuilder<List>(
            future: _fetchRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final requestData = snapshot.data as List;

                return ListView.builder(
                  itemCount: requestData.length,
                  itemBuilder: (context, index) {
                    final request = requestData[index];
                    final bool isMyRequest = request['requesterPhone'] == currentUserPhone;

                    // Check if there are pending offers for this request
                    final hasPendingOffers = request['fulfilled_by'] != null;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${request['bloodGroup']} (${request['quantity']} units)",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildUrgencyBadge(request),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Needed by: ${DateFormat('MMM d, yyyy').format(DateTime.parse(request['needByDate']))}",
                              style: TextStyle(
                                color: _getUrgencyColor(request),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("Location: ${request['address']}"),
                            const SizedBox(height: 4),
                            Text("Type: ${request['bloodType']}"),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isMyRequest)
                                  ElevatedButton(
                                    onPressed: () => _viewDonationOffers(request['id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: Text(
                                      hasPendingOffers ? "View Offers" : "View Offers", // i have to change it
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: () => _offerToDonate(request),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text(
                                      "Offer to Donate",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    'No blood requests available',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(Map request) {
    final DateTime needByDate = DateTime.parse(request['needByDate']);
    final Duration timeUntilNeeded = needByDate.difference(DateTime.now());

    if (timeUntilNeeded.inHours < 24) {
      return Colors.red;
    } else if (timeUntilNeeded.inHours < 72) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget _buildUrgencyBadge(Map request) {
    final DateTime needByDate = DateTime.parse(request['needByDate']);
    final Duration timeUntilNeeded = needByDate.difference(DateTime.now());
    String urgencyText;
    Color badgeColor;

    if (timeUntilNeeded.inHours < 24) {
      urgencyText = 'Urgent';
      badgeColor = Colors.red;
    } else if (timeUntilNeeded.inHours < 72) {
      urgencyText = 'Soon';
      badgeColor = Colors.orange;
    } else {
      urgencyText = 'Scheduled';
      badgeColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        urgencyText,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }


  Future<void> _offerToDonate(Map request) async {
    final String currentUserPhone = _boxLogin.get("phoneNumber").toString();

    // Prevent multiple clicks
    if (_isLoading) return;

    bool confirmDonate = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Donation Offer'),
        content: Text(
            'Are you sure you want to donate ${request['quantity']} units of ${request['bloodGroup']} blood?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmDonate) {
      setState(() {
        _isLoading = true;
      });

      try {
        bool success = await apiService.offerToDonate(
          request['id'],
          currentUserPhone,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  success
                      ? 'Donation offer sent successfully!'
                      : 'Failed to send donation offer.'
              ),
              backgroundColor: success ? Colors.green : Colors.white,
            ),
          );

          if (success) {
            // Clear state before refreshing to avoid conflicts
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              setState(() {});
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _viewDonationOffers(String requestId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List offers = await apiService.getDonationOffers(requestId);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (offers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No donation offers available yet.')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Donation Offers'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return ListTile(
                  title: Text('${offer['users']['first_name']} ${offer['users']['last_name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offered on: ${DateFormat('MMM d, yyyy').format(DateTime.parse(offer['offer_date']))}',
                      ),
                      Text(
                        'Phone: ${offer['donor_phone']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (offer['status'] == 'pending')
                        ElevatedButton(
                          onPressed: () => _acceptOffer(offer),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Accept'),
                        ),
                      if (offer['status'] == 'accepted')
                        ElevatedButton(
                          onPressed: () => _confirmDonation(offer),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Donated'),
                        ),
                      if (offer['status'] == 'completed')
                        const Chip(
                          label: Text('Completed'),
                          backgroundColor: Colors.green,
                        ),
                      if (offer['status'] == 'rejected')
                        const Chip(
                          label: Text('Rejected'),
                          backgroundColor: Colors.white,
                        ),
                    ],
                  ),
                  isThreeLine: true, // Add this to ensure enough space for the additional subtitle line
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading offers: $error')),
        );
      }
    }
  }

  Future<void> _confirmDonation(Map offer) async {
    // Close the offer dialog first
    Navigator.pop(context);

    // Show confirmation dialog
    bool confirmDonation = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Donation'),
        content: Text(
            'Has ${offer['users']['first_name']} ${offer['users']['last_name']} completed the donation? This will update their donation history and leaderboard status.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmDonation) return;

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Process the confirmation
      bool success = await apiService.confirmDonation(offer['id']);

      // Allow UI to settle before showing feedback
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Donation confirmed! Donation history updated.'
                : 'Failed to confirm donation.'),
            backgroundColor: success ? Colors.green : Colors.white,
            duration: const Duration(seconds: 3),
          ),
        );

        if (success) {
          // Clear state and refresh after a small delay
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            setState(() {});
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptOffer(Map offer) async {
    // Close the offer dialog first
    Navigator.pop(context);

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Process the acceptance
      bool success = await apiService.acceptDonationOffer(offer['id']);

      // Fix: Allow UI to settle before feedback
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        // Fix: Corrected the success/failure message logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success
                    ? 'Donation offer accepted! The donor will contact you soon.'
                    : 'Failed to accept offer.'
            ),
            backgroundColor: success ? Colors.green : Colors.white,
            duration: const Duration(seconds: 4),
          ),
        );

        if (success) {
          // Clear state and refresh after a small delay
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            setState(() {});
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}