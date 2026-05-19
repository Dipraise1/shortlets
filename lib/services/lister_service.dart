import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ListerProperty {
  final String id;
  String name;
  String location;
  String city;
  double price;
  String listingType; // 'shortlet' | 'rent'
  String propertyType; // 'apartment' | 'house'
  int bedrooms;
  int bathrooms;
  String description;
  List<String> imagePaths;
  bool isActive;
  final DateTime createdAt;

  ListerProperty({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    required this.price,
    this.listingType = 'shortlet',
    this.propertyType = 'apartment',
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.description = '',
    this.imagePaths = const [],
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'city': city,
        'price': price,
        'listingType': listingType,
        'propertyType': propertyType,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'description': description,
        'imagePaths': imagePaths,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ListerProperty.fromJson(Map<String, dynamic> j) => ListerProperty(
        id: j['id'],
        name: j['name'],
        location: j['location'],
        city: j['city'],
        price: (j['price'] as num).toDouble(),
        listingType: j['listingType'] ?? 'shortlet',
        propertyType: j['propertyType'] ?? 'apartment',
        bedrooms: j['bedrooms'] ?? 1,
        bathrooms: j['bathrooms'] ?? 1,
        description: j['description'] ?? '',
        imagePaths: List<String>.from(j['imagePaths'] ?? []),
        isActive: j['isActive'] ?? true,
        createdAt: DateTime.parse(j['createdAt']),
      );
}

class RentalRequest {
  final String id;
  final String propertyId;
  final String propertyName;
  final String renterName;
  final String renterEmail;
  final String renterPhone;
  final String dateInfo;
  final double totalPrice;
  final String message;
  final DateTime createdAt;
  String status; // 'pending' | 'accepted' | 'declined'

  RentalRequest({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.renterName,
    required this.renterEmail,
    required this.renterPhone,
    required this.dateInfo,
    required this.totalPrice,
    required this.message,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'propertyId': propertyId,
        'propertyName': propertyName,
        'renterName': renterName,
        'renterEmail': renterEmail,
        'renterPhone': renterPhone,
        'dateInfo': dateInfo,
        'totalPrice': totalPrice,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  factory RentalRequest.fromJson(Map<String, dynamic> j) => RentalRequest(
        id: j['id'],
        propertyId: j['propertyId'],
        propertyName: j['propertyName'],
        renterName: j['renterName'],
        renterEmail: j['renterEmail'],
        renterPhone: j['renterPhone'],
        dateInfo: j['dateInfo'],
        totalPrice: (j['totalPrice'] as num).toDouble(),
        message: j['message'] ?? '',
        createdAt: DateTime.parse(j['createdAt']),
        status: j['status'] ?? 'pending',
      );
}

class ListerService {
  static const _propertiesKey = 'lister_properties';
  static const _requestsKey = 'lister_requests';
  static const _profileKey = 'lister_profile';
  static const _verificationKey = 'lister_verification';
  static const _loggedInKey = 'lister_logged_in';

  // ── Auth / Session ────────────────────────────────────────────────────────

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }

  static Future<void> markLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
  }

  // ── Verification ──────────────────────────────────────────────────────────

  // status: 'unverified' | 'pending' | 'verified'
  static Future<String> getVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_verificationKey);
    if (raw == null) return 'unverified';
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return data['status'] as String? ?? 'unverified';
  }

  static Future<void> submitVerification(
      Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      ...data,
      'status': 'pending',
      'submittedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_verificationKey, jsonEncode(payload));
    await prefs.setString(_profileKey, jsonEncode({
      'name': data['fullName'] ?? '',
      'email': data['email'] ?? '',
      'phone': data['phone'] ?? '',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    }));
    await markLoggedIn();
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw != null) return Map<String, String>.from(jsonDecode(raw));
    return {
      'name': 'LS Woltoh',
      'email': 'lswoltoh07@gmail.com',
      'phone': '+2348012345678',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    };
  }

  // ── Properties ────────────────────────────────────────────────────────────

  static Future<List<ListerProperty>> getProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_propertiesKey) ?? [];
    return raw
        .map((s) => ListerProperty.fromJson(jsonDecode(s)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> saveProperty(ListerProperty p) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_propertiesKey) ?? [];
    final idx = list.indexWhere((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m['id'] == p.id;
    });
    final encoded = jsonEncode(p.toJson());
    if (idx >= 0) {
      list[idx] = encoded;
    } else {
      list.add(encoded);
    }
    await prefs.setStringList(_propertiesKey, list);
  }

  static Future<void> deleteProperty(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_propertiesKey) ?? [];
    list.removeWhere((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m['id'] == id;
    });
    await prefs.setStringList(_propertiesKey, list);
  }

  static Future<void> toggleActive(String id) async {
    final props = await getProperties();
    final p = props.firstWhere((x) => x.id == id);
    p.isActive = !p.isActive;
    await saveProperty(p);
  }

  // ── Requests ──────────────────────────────────────────────────────────────

  static Future<List<RentalRequest>> getRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_requestsKey);
    if (raw != null && raw.isNotEmpty) {
      return raw
          .map((s) => RentalRequest.fromJson(jsonDecode(s)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    // Demo requests
    return _demoRequests();
  }

  static Future<void> updateRequestStatus(
      String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    List<RentalRequest> requests;
    final raw = prefs.getStringList(_requestsKey);
    if (raw != null && raw.isNotEmpty) {
      requests = raw.map((s) => RentalRequest.fromJson(jsonDecode(s))).toList();
    } else {
      requests = _demoRequests();
    }
    final idx = requests.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      requests[idx].status = status;
      await prefs.setStringList(
          _requestsKey, requests.map((r) => jsonEncode(r.toJson())).toList());
    }
  }

  static List<RentalRequest> _demoRequests() => [
        RentalRequest(
          id: 'req001',
          propertyId: 'p1000000-0000-0000-0000-000000000001',
          propertyName: 'Green Hangout Place',
          renterName: 'Adaeze Okonkwo',
          renterEmail: 'adaeze@gmail.com',
          renterPhone: '+2348031234567',
          dateInfo: 'Check-in: 20 Jun 2026 | Check-out: 23 Jun 2026 (3 nights)',
          totalPrice: 255000,
          message:
              'Hi, I\'m visiting for a business trip. Is the place pet-friendly?',
          createdAt:
              DateTime.now().subtract(const Duration(hours: 2)),
          status: 'pending',
        ),
        RentalRequest(
          id: 'req002',
          propertyId: 'p1000000-0000-0000-0000-000000000006',
          propertyName: '4 Bedroom Detached House',
          renterName: 'Emeka Nwosu',
          renterEmail: 'emeka.nwosu@yahoo.com',
          renterPhone: '+2349055678901',
          dateInfo: 'Duration: 12 months',
          totalPrice: 4200000,
          message:
              'We are a family of 4. Is the boys quarters separate? When can we view?',
          createdAt:
              DateTime.now().subtract(const Duration(days: 1)),
          status: 'pending',
        ),
        RentalRequest(
          id: 'req003',
          propertyId: 'p1000000-0000-0000-0000-000000000002',
          propertyName: 'Elegant Apartment',
          renterName: 'Fatima Bello',
          renterEmail: 'fatima.b@outlook.com',
          renterPhone: '+2348098765432',
          dateInfo: 'Check-in: 1 Jul 2026 | Check-out: 5 Jul 2026 (4 nights)',
          totalPrice: 72000,
          message: '',
          createdAt:
              DateTime.now().subtract(const Duration(days: 3)),
          status: 'accepted',
        ),
      ];
}
