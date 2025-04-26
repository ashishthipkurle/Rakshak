import 'package:Rakshak/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';


class ApiService {
  final String _baseUrl = '';
  final String _apiKey = '';

  Future<http.Response> createUser(String email, String password, Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/signUp');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
          ...userData,
        }),
      );

      return response;
    } catch (error) {
      print('The error is $error');
      return http.Response('Error', 500);
    }
  }

  Future<Map<String, dynamic>> getUserData(String email) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('users')
          .select()
          .eq('email', email)
          .single();

      return response ?? {};
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }


  Future<Map<String, dynamic>> signin(String email, String password) async {

    final url = Uri.parse('$_baseUrl/auth/v1/token?grant_type=password');
    final headers = {
      'Content-Type': 'application/json',
      'apikey': _apiKey,
      'Authorization': 'Bearer $_apiKey'
    };
    final body = json.encode({
      'email': email,
      'password': password,
    });

    try {
      final authService = AuthService();
      bool success = await authService.signIn(email, password);

      if (success) {

        final userData = await getUserData(email);
        return {
          'success': true,
          'user': userData
        };
      } else {
        return {'success': false, 'error': 'Invalid credentials'};
      }
    } catch (e) {
      print('Sign in error: $e');
      return {'success': false, 'error': 'Network error'};
    }
  }




  Future<bool> logout(String phoneNumber) async {
    try {

      final authService = AuthService();
      await authService.signOut();
      return true;
    } catch (e) {
      debugPrint('Error signing out: $e');
      return false;
    }
  }



  Future<bool> editProfile(
      String fname,
      String mname,
      String lname,
      String email,
      String address,
      String phoneNumber,
      String birthDate,
      String bloodGroup) async {
    try {

      final response = await Supabase.instance.client
          .from('users')
          .update({
        'first_name': fname,
        'middle_name': mname,
        'last_name': lname,
        'email': email,
        'address': address,
        'birth_date': birthDate,
        'blood_group': bloodGroup,
      })
          .eq('phone_number', phoneNumber)
          .select();

      debugPrint('Profile update response: $response');
      return response != null;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }


  Future<List> getLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/users?order=total_donations.desc'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'id': item['id'] ?? '',
          'first_name': item['first_name'] ?? '',
          'last_name': item['last_name'] ?? '',
          'total_donations': item['total_donations'] ?? 0,

        }).toList();
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (error) {
      print('The error is $error');
      return [];
    }
  }



  Future<List> getRequests(String phoneNumber) async {
    try {
      // Use the standard Supabase REST API endpoint pattern
      final response = await http.get(
        Uri.parse('https://xnvqeqirpztsprdiydfs.supabase.co/rest/v1/blood_requests?phone_number=eq.$phoneNumber&order=request_date.desc'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhudnFlcWlycHp0c3ByZGl5ZGZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0NTQ0MzMsImV4cCI6MjA1NjAzMDQzM30.BNhdtVndoiRPnp6yyUJemjqKe-3GlR6o-h24EBHD4zg',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => {
          'requestDate': item['request_date'],
          'bloodGroup': item['blood_group'],
          'bloodType': item['blood_type'],
          'needByDate': item['need_by_date'],
          'quantity': item['quantity'],
          'address': item['address'],
          'fulfilled_by': item['fulfilled_by'],
        }).toList();
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('The error is $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getDonations(String phoneNumber, String field) async {
    try {

      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/donations?phone_number=eq.$phoneNumber&order=donation_date.desc'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Raw donation data from API: $data');


        final transformedData = data.map((item) => {
          'donationDate': item['donation_date'],
          'upperBP': _ensureIntValue(item['upper_bp']),
          'lowerBP': _ensureIntValue(item['lower_bp']),
          'blood_group': item['blood_group'],
          'location': item['location'],
        }).toList();

        print('Transformed donation data: $transformedData');
        return {'donations': transformedData, 'totalDonations': data.length};
      } else {
        print('Request failed with status: ${response.statusCode}');
        return {'donations': [], 'totalDonations': 0};
      }
    } catch (e) {
      print('Error getting donations: $e');
      return {'donations': [], 'totalDonations': 0};
    }
  }

// Helper method to ensure we get integer values
  int? _ensureIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.round();
    return null;
  }

  Future<bool> sendRequest(
      String phoneNumber,
      String bloodGroup,
      int quantity,
      String bloodType,
      String address,
      DateTime needByDate) async {
    try {
      // Use the REST API to insert directly into your table
      final url = Uri.parse('$_baseUrl/rest/v1/blood_requests');

      final Map<String, dynamic> requestData = {
        'phone_number': phoneNumber,
        'blood_group': bloodGroup,
        'quantity': quantity,
        'blood_type': bloodType,
        'address': address,
        'need_by_date': needByDate.toIso8601String(),
        'request_date': DateTime.now().toIso8601String(),
        'fulfilled_by': null
      };

      print('Request URL: $url');
      print('Request Headers: {Content-Type: application/json, apikey: $_apiKey}');
      print('Request Body: ${json.encode(requestData)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Prefer': 'return=minimal'
        },
        body: json.encode(requestData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending request: $e');
      return false;
    }
  }



  Future<Map> register(
      String fname,
      String? mname,
      String lname,
      String email,
      String address,
      String phoneNumber,
      String password,
      String birthDate,
      String bloodGroup,
      String gender,
      int diabetes) async {
    final url = Uri.parse('$_baseUrl/api/register');
    mname ??= "";

    try {
      final response = await http.post(url, body: {
        "phoneNumber": phoneNumber,
        "fname": fname,
        "mname": mname,
        "lname": lname,
        "address": address,
        "gender": gender,
        "password": password,
        "diabetes": diabetes.toString(),
        "birthDate": birthDate,
        "email": email,
        "bloodGroup": bloodGroup,
      });
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print(responseData);
        return responseData;
      } else {
        print('Request failed with status: ${response.statusCode}. '
            'The error is ${response.body}');
        return responseData;
      }
    } catch (error) {
      print('The error is $error');
      return {'success': false, 'error': 'Something went wrong'};
    }
  }

  Future<List> getOrganizations(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/organizations'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Blood banks data: ${data.length} items returned');

        // If no real data, use mock data
        if (data.isEmpty) {
          return _getMockBloodBanks(latitude, longitude);
        }

        return data;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return _getMockBloodBanks(latitude, longitude);
      }
    } catch (error) {
      print('The error is $error');
      return _getMockBloodBanks(latitude, longitude);
    }
  }




  Future<List> getEvents(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/events'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Events data: ${data.length} items returned');

        // If no real data, use mock data
        if (data.isEmpty) {
          return _getMockEvents(latitude, longitude);
        }

        return data;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return _getMockEvents(latitude, longitude);
      }
    } catch (error) {
      print('The error is $error');
      return _getMockEvents(latitude, longitude);
    }
  }




  List _getMockBloodBanks(double latitude, double longitude) {
    return [
      {
        'id': 1,
        'name': 'City Blood Bank',
        'address': '123 Healthcare Ave',
        'contact': '+1-555-123-4567',
        'latitude': latitude + 0.01,
        'longitude': longitude + 0.01
      },
      {
        'id': 2,
        'name': 'Memorial Hospital Blood Center',
        'address': '456 Medical Blvd',
        'contact': '+1-555-987-6543',
        'latitude': latitude - 0.02,
        'longitude': longitude + 0.02
      }
    ];
  }

// Helper method for mock events
  List _getMockEvents(double latitude, double longitude) {
    return [
      {
        'id': 1,
        'name': 'Community Blood Drive',
        'description': 'Monthly blood donation event',
        'location': 'City Community Center',
        'date': '2023-07-15T09:00:00',
        'latitude': latitude + 0.02,
        'longitude': longitude + 0.02
      },
      {
        'id': 2,
        'name': 'University Blood Donation',
        'description': 'Student volunteer blood drive',
        'location': 'University Hospital',
        'date': '2023-07-22T10:00:00',
        'latitude': latitude - 0.02,
        'longitude': longitude - 0.02
      }
    ];
  }

  Future<List> getBloodBanks(double latitude, double longitude) async {
    try {
      // Fix the endpoint structure to match Supabase REST API format
      final response = await http.get(
        Uri.parse('${_baseUrl}/rest/v1/organizations?select=*'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Blood banks data: ${data.length} items returned');
        return data;
      } else {
        debugPrint('Failed to load blood banks: ${response.statusCode}');
        return _getMockBloodBanks(latitude, longitude);
      }
    } catch (e) {
      debugPrint('Error fetching blood banks: $e');
      return _getMockBloodBanks(latitude, longitude);
    }
  }


  Future<List> getAllRequests(String currentUserPhone) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/blood_requests?select=*&order=need_by_date.asc'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('All requests data: ${data.length} items returned');

        // Filter out fulfilled requests unless they belong to the current user
        final List<dynamic> filteredData = data.where((item) {
          final bool isUnfulfilled = item['fulfilled_by'] == null;
          final bool isOwnRequest = item['phone_number'] == currentUserPhone;

          // For debugging
          if (!isUnfulfilled && !isOwnRequest) {
            print('Filtering out fulfilled request: ${item['id']} (fulfilled by: ${item['fulfilled_by']})');
          }

          return isUnfulfilled || isOwnRequest;
        }).toList();

        print('Filtered requests: ${filteredData.length} items after filtering');

        return filteredData.map((item) => {
          'id': item['id'],
          'requestDate': item['request_date'],
          'bloodGroup': item['blood_group'],
          'bloodType': item['blood_type'],
          'needByDate': item['need_by_date'],
          'quantity': item['quantity'],
          'address': item['address'],
          'requesterPhone': item['phone_number'],
          'fulfilled_by': item['fulfilled_by'],
          'status': item['status'],
        }).toList();
      } else {
        print('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting all requests: $e');
      return [];
    }
  }

// Offer to donate
  Future<bool> offerToDonate(String requestId, String donorPhone) async {
    try {
      // Using direct HTTP request instead of client.from for better error visibility
      final url = Uri.parse('$_baseUrl/rest/v1/donation_offers');

      final payload = {
        'request_id': requestId,
        'donor_phone': donorPhone,
        'offer_date': DateTime.now().toIso8601String(),
        'status': 'pending'
      };

      print('Sending payload: $payload');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Prefer': 'return=minimal'
        },
        body: json.encode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Donation offer sent successfully');
        return true;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error offering to donate: $error');
      return false;
    }
  }

  Future<List> getDonationOffers(String requestId) async {
    final client = Supabase.instance.client;

    try {
      // First, get the basic donation offers
      final response = await client
          .from('donation_offers')
          .select()
          .eq('request_id', requestId)
          .order('offer_date', ascending: false);

      // For each donation offer, fetch the donor information separately
      List enrichedOffers = [];
      for (var offer in response) {
        // Check if this is an admin fulfillment
        if (offer['donor_phone'] == 'Admin') {
          // Create a placeholder user object for admin
          offer['users'] = {
            'first_name': 'Blood',
            'last_name': 'Bank',
            'phone_number': 'Admin',
            'address': 'Hospital Blood Bank'
          };
          enrichedOffers.add(offer);
        } else {
          // Regular user offer - get donor information using donor_phone
          try {
            final userResponse = await client
                .from('users')
                .select()
                .eq('phone_number', offer['donor_phone'])
                .single();

            // Add user data to the offer object
            if (userResponse != null) {
              offer['users'] = userResponse;
            }
            enrichedOffers.add(offer);
          } catch (e) {
            print('Error fetching user data for donor: $e');
            // Still add the offer even if we can't get user data
            offer['users'] = {
              'first_name': 'Unknown',
              'last_name': 'Donor',
              'phone_number': offer['donor_phone']
            };
            enrichedOffers.add(offer);
          }
        }
      }

      return enrichedOffers;
    } catch (error) {
      print('Error getting donation offers: $error');
      return [];
    }
  }

  // Future<List> getDonationOffers(String requestId) async {
  //   final client = Supabase.instance.client;
  //
  //   try {
  //     // First, get the basic donation offers
  //     final response = await client
  //         .from('donation_offers')
  //         .select()
  //         .eq('request_id', requestId)
  //         .order('offer_date', ascending: false);
  //
  //     // For each donation offer, fetch the donor information separately
  //     List enrichedOffers = [];
  //     for (var offer in response) {
  //       // Get donor information using donor_phone
  //       final userResponse = await client
  //           .from('users')
  //           .select()
  //           .eq('phone_number', offer['donor_phone'])
  //           .single();
  //
  //       // Add user data to the offer object
  //       if (userResponse != null) {
  //         offer['users'] = userResponse;
  //       }
  //
  //       enrichedOffers.add(offer);
  //     }
  //
  //     return enrichedOffers;
  //   } catch (error) {
  //     print('Error getting donation offers: $error');
  //     return [];
  //   }
  // }

// Accept a donation offer


  Future<bool> acceptDonationOffer(String offerId) async {
    final client = Supabase.instance.client;

    try {
      // First, get basic information about the offer
      final offerResponse = await client
          .from('donation_offers')
          .select()
          .eq('id', offerId)
          .single();

      if (offerResponse == null) {
        print('Offer not found: $offerId');
        return false;
      }

      final String requestId = offerResponse['request_id'];
      final String donorPhone = offerResponse['donor_phone'];

      // Update the offer status
      await client
          .from('donation_offers')
          .update({'status': 'accepted'})
          .eq('id', offerId);

      // Mark other offers as rejected
      await client
          .from('donation_offers')
          .update({'status': 'rejected'})
          .eq('request_id', requestId)
          .neq('id', offerId);

      // Update the blood request as fulfilled with donor details
      await client
          .from('blood_requests')
          .update({
        'fulfilled_by': donorPhone
      })
          .eq('id', requestId);

      return true;
    } catch (error) {
      print('Error accepting donation offer: $error');
      return false;
    }
  }


  Future<bool> confirmDonation(String offerId) async {
    final client = Supabase.instance.client;

    try {
      // Get offer details
      final offerResponse = await client
          .from('donation_offers')
          .select()
          .eq('id', offerId)
          .single();

      if (offerResponse == null) return false;

      final String donorPhone = offerResponse['donor_phone'];
      final String requestId = offerResponse['request_id'];

      // Update status
      await client
          .from('donation_offers')
          .update({'status': 'donated'})
          .eq('id', offerId);

      // Get request details
      final requestResponse = await client
          .from('blood_requests')
          .select()
          .eq('id', requestId)
          .single();

      // Update donation count
      int currentDonations = 0;
      try {
        final userResponse = await client
            .from('users')
            .select('total_donations')
            .eq('phone_number', donorPhone)
            .single();
        currentDonations = userResponse['total_donations'] ?? 0;
      } catch (e) {
        print('Error getting current donations: $e');
      }

      await client
          .from('users')
          .update({'total_donations': currentDonations + 1})
          .eq('phone_number', donorPhone);

      // Record donation without BP values
      await client.from('donations').upsert({
        'phone_number': donorPhone,
        'blood_group': requestResponse['blood_group'],
        'donation_date': DateTime.now().toIso8601String(),
        'location': requestResponse['address'],
        'request_id': requestId
        // BP fields omitted intentionally
      });

      return true;
    } catch (error) {
      print('Error confirming donation: $error');
      return false;
    }
  }

}