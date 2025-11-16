import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/auth_config.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Auth0 with your credentials from environment variables
  AuthService.initialize(
    domain: AuthConfig.domain,
    clientId: AuthConfig.clientId,
  );
  
  runApp(const ShortletApp());
}

class ShortletApp extends StatelessWidget {
  const ShortletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shortlet Apartments Abuja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
