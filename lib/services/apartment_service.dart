import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/property.dart';

/// Service for fetching apartment listings from various sources
/// Supports multiple Nigerian cities: Abuja, Lagos, Port Harcourt, and Nigeria-wide
class ApartmentService {
  // Google Places API key loaded from environment variables
  // Get it from: https://console.cloud.google.com/google/maps-apis
  static String get _googlePlacesApiKey => 
    dotenv.env['GOOGLE_PLACES_API_KEY'] ?? 'AIzaSyBVUrOefWS2PtJ0CpGjG2Gc4mEGzvEQ-Bc';
  
  // Base URL for Google Places API
  static const String _placesApiBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // Nigerian city coordinates
  static const Map<String, Map<String, double>> _cityCoordinates = {
    'Abuja': {'lat': 9.0765, 'lng': 7.3986},
    'Lagos': {'lat': 6.5244, 'lng': 3.3792},
    'Port Harcourt': {'lat': 4.8156, 'lng': 7.0498},
  };

  /// Fetch apartments for a specific city or Nigeria-wide
  /// [city] can be 'Abuja', 'Lagos', 'Port Harcourt', or null for Nigeria-wide search
  static Future<List<Property>> fetchApartments({String? city}) async {
    try {
      // If API key is not set, use fallback data
      if (_googlePlacesApiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
        print('Google Places API key not configured. Using fallback data.');
        return _getFallbackProperties(city);
      }

      // Try multiple approaches
      List<Property> apartments = [];
      
      // Approach 1: Google Places Text Search (most reliable)
      apartments = await _fetchFromGooglePlacesTextSearch(city);
      
      // Approach 2: If no results, try Nearby Search
      if (apartments.isEmpty && city != null) {
        apartments = await _fetchFromGooglePlacesNearby(city);
      }
      
      // Approach 3: If still no results, try alternative sources
      if (apartments.isEmpty) {
        apartments = await _fetchFromAlternativeSources(city);
      }
      
      // Fallback to static data if all methods fail
      if (apartments.isEmpty) {
        print('No apartments found from APIs, using fallback data');
        return _getFallbackProperties(city);
      }
      
      return apartments;
    } catch (e) {
      print('Error fetching apartments: $e');
      return _getFallbackProperties(city);
    }
  }

  /// Fetch apartments using Google Places Text Search API
  static Future<List<Property>> _fetchFromGooglePlacesTextSearch(String? city) async {
    try {
      final query = city != null 
          ? 'shortlet apartments $city Nigeria'
          : 'shortlet apartments Nigeria';
      
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        '$_placesApiBaseUrl/textsearch/json?query=$encodedQuery&key=$_googlePlacesApiKey&type=lodging'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'] != null) {
          return _parseGooglePlacesResults(data['results'], city);
        } else {
          print('Google Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        }
      }
    } catch (e) {
      print('Error in Google Places Text Search: $e');
    }
    return [];
  }

  /// Fetch apartments using Google Places Nearby Search API
  static Future<List<Property>> _fetchFromGooglePlacesNearby(String city) async {
    try {
      final coords = _cityCoordinates[city];
      if (coords == null) return [];
      
      final url = Uri.parse(
        '$_placesApiBaseUrl/nearbysearch/json?location=${coords['lat']},${coords['lng']}&radius=10000&type=lodging&keyword=shortlet%20apartment&key=$_googlePlacesApiKey'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'] != null) {
          return _parseGooglePlacesResults(data['results'], city);
        }
      }
    } catch (e) {
      print('Error in Google Places Nearby Search: $e');
    }
    return [];
  }

  /// Parse Google Places API results into Property objects
  static List<Property> _parseGooglePlacesResults(List<dynamic> results, String? city) {
    final List<Property> properties = [];
    int idCounter = 1;

    for (var result in results) {
      try {
        final name = result['name'] ?? 'Apartment $idCounter';
        final location = result['formatted_address'] ?? 
                        result['vicinity'] ?? 
                        (city != null ? '$city, Nigeria' : 'Nigeria');
        final rating = (result['rating'] ?? 4.5).toDouble();
        final priceLevel = result['price_level'] ?? 2; // 0-4 scale
        final price = _estimatePriceFromLevel(priceLevel);
        
        // Get photos
        String imageUrl = 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800';
        if (result['photos'] != null && result['photos'].isNotEmpty) {
          final photoRef = result['photos'][0]['photo_reference'];
          imageUrl = '$_placesApiBaseUrl/photo?maxwidth=800&photoreference=$photoRef&key=$_googlePlacesApiKey';
        }

        // Get place details for more info (phone, website, etc.)
        final placeId = result['place_id'];
        final phone = result['formatted_phone_number'] ?? 
                     result['international_phone_number'] ?? 
                     null;

        final property = Property(
          id: placeId ?? idCounter.toString(),
          name: name,
          location: location,
          price: price,
          imageUrl: imageUrl,
          description: 'Beautiful shortlet apartment in $location. Perfect for short stays and business trips.',
          bedrooms: _estimateBedrooms(name),
          bathrooms: _estimateBathrooms(name),
          propertyArea: '100 sqm',
          cctv: 5,
          parkingSpots: 1,
          year: 2024,
          agent: Agent(
            name: 'Property Manager',
            email: 'contact@apartment.com',
            imageUrl: 'https://i.pravatar.cc/150?img=12',
            phone: phone,
          ),
          rating: rating,
          reviewerName: 'Guest',
          reviewerImage: 'https://i.pravatar.cc/150?img=33',
        );

        properties.add(property);
        idCounter++;
      } catch (e) {
        print('Error parsing place result: $e');
        continue;
      }
    }

    return properties;
  }

  /// Fetch from alternative sources (can be extended with other APIs)
  static Future<List<Property>> _fetchFromAlternativeSources(String? city) async {
    // This can be extended to fetch from:
    // - PropertyPro API
    // - ToLet API
    // - Private Property API
    // - Other Nigerian real estate APIs
    
    // For now, return empty list
    return [];
  }

  /// Get fallback properties based on city
  static List<Property> _getFallbackProperties(String? city) {
    if (city == null || city == 'Abuja') {
      return PropertyData.getAbujaProperties();
    } else if (city == 'Lagos') {
      return PropertyData.getLagosProperties();
    } else if (city == 'Port Harcourt') {
      return PropertyData.getPortHarcourtProperties();
    } else {
      // Return mixed properties for Nigeria-wide
      return PropertyData.getAllNigeriaProperties();
    }
  }

  /// Estimate price from Google Places price level (0-4 scale)
  static double _estimatePriceFromLevel(int priceLevel) {
    // Price levels: 0=Free, 1=Inexpensive, 2=Moderate, 3=Expensive, 4=Very Expensive
    switch (priceLevel) {
      case 0:
        return 10000.0; // Free/very cheap
      case 1:
        return 25000.0; // Inexpensive
      case 2:
        return 50000.0; // Moderate
      case 3:
        return 100000.0; // Expensive
      case 4:
        return 200000.0; // Very expensive
      default:
        return 50000.0; // Default moderate price
    }
  }

  /// Estimate bedrooms from property name/description
  static int _estimateBedrooms(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('studio')) return 1;
    if (lowerName.contains('1 bed') || lowerName.contains('one bed')) return 1;
    if (lowerName.contains('2 bed') || lowerName.contains('two bed')) return 2;
    if (lowerName.contains('3 bed') || lowerName.contains('three bed')) return 3;
    if (lowerName.contains('4 bed') || lowerName.contains('four bed')) return 4;
    if (lowerName.contains('5 bed') || lowerName.contains('five bed')) return 5;
    if (lowerName.contains('penthouse') || lowerName.contains('villa')) return 5;
    return 2; // Default
  }

  /// Estimate bathrooms from property name/description
  static int _estimateBathrooms(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('studio')) return 1;
    final bedrooms = _estimateBedrooms(name);
    // Usually bathrooms = bedrooms - 1, minimum 1
    return bedrooms > 1 ? bedrooms - 1 : 1;
  }
}

