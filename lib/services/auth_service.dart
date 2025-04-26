import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> signUp(String email, String password, Map<String, dynamic> userData) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Add the user ID to the userData map
        userData['id'] = response.user!.id;

        // Save additional user data to the database
        final insertResponse = await _client
            .from('users')
            .insert(userData)
            .select();

        if (insertResponse.isEmpty) {

          return false;
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      print('Email: $email');
      print('Password: $password');

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}