import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthConfig {
  // Auth0 credentials loaded from environment variables
  static String get domain => dotenv.env['AUTH0_DOMAIN'] ?? 'dev-u8zgmufz2dsmixi8.us.auth0.com';
  static String get clientId => dotenv.env['AUTH0_CLIENT_ID'] ?? 'WA8Li160ytkh67bxesZ5LmYdhjK7Verh';
  // Note: Client secret is typically not needed for mobile apps, but kept here for reference
  static String get clientSecret => dotenv.env['AUTH0_CLIENT_SECRET'] ?? '';
  
  // Initialize Auth0
  static void initialize() {
    // This will be called in main.dart
  }
}

