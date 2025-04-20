import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  User? get currentUser => _supabase.auth.currentUser;
  
  // Check if user is logged in on app start
  AuthService() {
    _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }
  
  // Sign up with email and password
  Future<String?> signUp(String email, String password, String fullName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      
      if (response.user != null) {
        // Create a user profile in the database
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'full_name': fullName,
          'email': email,
        });
        notifyListeners();
        return null;
      } else {
        return 'Signup failed';
      }
    } catch (e) {
      return e.toString();
    }
  }
  
  // Login with email and password
  Future<String?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        notifyListeners();
        return null;
      } else {
        return 'Invalid credentials';
      }
    } catch (e) {
      return e.toString();
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
  
  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();
        
    return response;
  }
  
  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    
    await _supabase
        .from('profiles')
        .update(data)
        .eq('id', currentUser!.id);
        
    notifyListeners();
  }
}