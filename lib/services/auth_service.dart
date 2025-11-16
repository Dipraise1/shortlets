import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Auth0? _auth0;
  static Credentials? _credentials;
  static UserProfile? _userProfile;
  
  // Initialize Auth0 - Replace with your Auth0 credentials
  static void initialize({
    required String domain,
    required String clientId,
  }) {
    _auth0 = Auth0(domain, clientId);
  }

  static Auth0? get auth0 => _auth0;

  // Login with Auth0
  static Future<bool> login() async {
    try {
      if (_auth0 == null) {
        throw Exception('Auth0 not initialized. Please configure Auth0 credentials.');
      }
      
      // Use custom URL scheme for development (doesn't require Associated Domains)
      // Set useHTTPS: true for production after Associated Domains is properly configured
      final credentials = await _auth0!.webAuthentication().login(useHTTPS: false);
      _credentials = credentials;
      _userProfile = credentials.user;
      
      // Save user info locally
      if (_userProfile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userProfile!.name ?? 'divine');
        await prefs.setString('user_email', _userProfile!.email ?? '');
        final pictureUrl = _userProfile!.pictureUrl?.toString() ?? '';
        await prefs.setString('user_picture', pictureUrl);
      }
      
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Sign up with Auth0
  static Future<bool> signUp() async {
    try {
      if (_auth0 == null) {
        throw Exception('Auth0 not initialized. Please configure Auth0 credentials.');
      }
      
      // Use custom URL scheme for development (doesn't require Associated Domains)
      // Set useHTTPS: true for production after Associated Domains is properly configured
      final credentials = await _auth0!.webAuthentication().login(
        useHTTPS: false,
        parameters: {'screen_hint': 'signup'},
      );
      _credentials = credentials;
      _userProfile = credentials.user;
      
      // Save user info locally
      if (_userProfile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userProfile!.name ?? 'divine');
        await prefs.setString('user_email', _userProfile!.email ?? '');
        final pictureUrl = _userProfile!.pictureUrl?.toString() ?? '';
        await prefs.setString('user_picture', pictureUrl);
      }
      
      return true;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      if (_auth0 != null && _credentials != null) {
        // Use custom URL scheme for development (doesn't require Associated Domains)
        // Set useHTTPS: true for production after Associated Domains is properly configured
        await _auth0!.webAuthentication().logout(useHTTPS: false);
      }
      _credentials = null;
      _userProfile = null;
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_picture');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    if (_credentials != null) {
      return true;
    }
    
    // Check local storage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') != null;
  }

  // Get current user name
  static Future<String> getUserName() async {
    if (_userProfile != null) {
      return _userProfile!.name ?? 'divine';
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'divine';
  }

  // Get current user email
  static Future<String> getUserEmail() async {
    if (_userProfile != null) {
      return _userProfile!.email ?? '';
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? '';
  }

  // Get current user picture
  static Future<String> getUserPicture() async {
    if (_userProfile != null) {
      return _userProfile!.pictureUrl?.toString() ?? 'https://i.pravatar.cc/150?img=1';
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_picture') ?? 'https://i.pravatar.cc/150?img=1';
  }
}

