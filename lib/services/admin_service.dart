import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'lister_service.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'renter' | 'lister' | 'admin'
  final String status; // 'active' | 'suspended'
  final DateTime joinedAt;
  final int bookingsCount;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.bookingsCount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'status': status,
        'joinedAt': joinedAt.toIso8601String(),
        'bookingsCount': bookingsCount,
      };

  factory AdminUser.fromJson(Map<String, dynamic> j) => AdminUser(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        role: j['role'] ?? 'renter',
        status: j['status'] ?? 'active',
        joinedAt: DateTime.parse(j['joinedAt']),
        bookingsCount: j['bookingsCount'] ?? 0,
      );

  AdminUser copyWith({String? status}) => AdminUser(
        id: id,
        name: name,
        email: email,
        role: role,
        status: status ?? this.status,
        joinedAt: joinedAt,
        bookingsCount: bookingsCount,
      );
}

class VerificationSubmission {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String businessName;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime submittedAt;

  const VerificationSubmission({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.status,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'businessName': businessName,
        'status': status,
        'submittedAt': submittedAt.toIso8601String(),
      };

  factory VerificationSubmission.fromJson(Map<String, dynamic> j) =>
      VerificationSubmission(
        id: j['id'],
        fullName: j['fullName'],
        email: j['email'],
        phone: j['phone'],
        businessName: j['businessName'] ?? '',
        status: j['status'] ?? 'pending',
        submittedAt: DateTime.parse(j['submittedAt']),
      );

  VerificationSubmission copyWith({String? status}) => VerificationSubmission(
        id: id,
        fullName: fullName,
        email: email,
        phone: phone,
        businessName: businessName,
        status: status ?? this.status,
        submittedAt: submittedAt,
      );
}

class AdminStats {
  final int totalProperties;
  final int activeProperties;
  final int totalUsers;
  final int totalListers;
  final int pendingVerifications;
  final int totalRequests;
  final int pendingRequests;
  final double totalRevenue;

  const AdminStats({
    required this.totalProperties,
    required this.activeProperties,
    required this.totalUsers,
    required this.totalListers,
    required this.pendingVerifications,
    required this.totalRequests,
    required this.pendingRequests,
    required this.totalRevenue,
  });
}

class AdminService {
  static const _usersKey = 'admin_users';
  static const _verificationsKey = 'admin_verifications';

  // ── Stats ─────────────────────────────────────────────────────────────────

  static Future<AdminStats> getStats() async {
    final props = await ListerService.getProperties();
    final requests = await ListerService.getRequests();
    final users = await getUsers();
    final verifications = await getVerifications();

    final totalRevenue = requests
        .where((r) => r.status == 'accepted')
        .fold(0.0, (sum, r) => sum + r.totalPrice);

    return AdminStats(
      totalProperties: props.length,
      activeProperties: props.where((p) => p.isActive).length,
      totalUsers: users.length,
      totalListers: users.where((u) => u.role == 'lister').length,
      pendingVerifications:
          verifications.where((v) => v.status == 'pending').length,
      totalRequests: requests.length,
      pendingRequests: requests.where((r) => r.status == 'pending').length,
      totalRevenue: totalRevenue,
    );
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  static Future<List<AdminUser>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_usersKey);
    if (raw != null && raw.isNotEmpty) {
      return raw.map((s) => AdminUser.fromJson(jsonDecode(s))).toList();
    }
    return _demoUsers();
  }

  static Future<void> updateUserStatus(String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    final idx = users.indexWhere((u) => u.id == id);
    if (idx >= 0) {
      users[idx] = users[idx].copyWith(status: status);
      await prefs.setStringList(
          _usersKey, users.map((u) => jsonEncode(u.toJson())).toList());
    }
  }

  // ── Verifications ─────────────────────────────────────────────────────────

  static Future<List<VerificationSubmission>> getVerifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_verificationsKey);
    if (raw != null && raw.isNotEmpty) {
      return raw
          .map((s) => VerificationSubmission.fromJson(jsonDecode(s)))
          .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    }
    return _demoVerifications();
  }

  static Future<void> updateVerificationStatus(
      String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getVerifications();
    final idx = list.indexWhere((v) => v.id == id);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(status: status);
      await prefs.setStringList(_verificationsKey,
          list.map((v) => jsonEncode(v.toJson())).toList());
    }
  }

  // ── Properties / Requests (delegates to ListerService) ───────────────────

  static Future<List<ListerProperty>> getAllProperties() =>
      ListerService.getProperties();

  static Future<List<RentalRequest>> getAllRequests() =>
      ListerService.getRequests();

  // ── Demo data ─────────────────────────────────────────────────────────────

  static List<AdminUser> _demoUsers() => [
        AdminUser(
          id: 'u001',
          name: 'Adaeze Okonkwo',
          email: 'adaeze@gmail.com',
          role: 'renter',
          status: 'active',
          joinedAt: DateTime.now().subtract(const Duration(days: 45)),
          bookingsCount: 3,
        ),
        AdminUser(
          id: 'u002',
          name: 'Emeka Nwosu',
          email: 'emeka.nwosu@yahoo.com',
          role: 'renter',
          status: 'active',
          joinedAt: DateTime.now().subtract(const Duration(days: 120)),
          bookingsCount: 7,
        ),
        AdminUser(
          id: 'u003',
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          role: 'lister',
          status: 'active',
          joinedAt: DateTime.now().subtract(const Duration(days: 200)),
          bookingsCount: 0,
        ),
        AdminUser(
          id: 'u004',
          name: 'Fatima Bello',
          email: 'fatima.b@outlook.com',
          role: 'renter',
          status: 'active',
          joinedAt: DateTime.now().subtract(const Duration(days: 30)),
          bookingsCount: 1,
        ),
        AdminUser(
          id: 'u005',
          name: 'Tunde Bakare',
          email: 'tunde.bakare@gmail.com',
          role: 'lister',
          status: 'active',
          joinedAt: DateTime.now().subtract(const Duration(days: 90)),
          bookingsCount: 0,
        ),
        AdminUser(
          id: 'u006',
          name: 'Ngozi Adeyemi',
          email: 'ngozi.adeyemi@gmail.com',
          role: 'renter',
          status: 'suspended',
          joinedAt: DateTime.now().subtract(const Duration(days: 60)),
          bookingsCount: 2,
        ),
        AdminUser(
          id: 'u007',
          name: 'Chukwuma Nwosu',
          email: 'chukwuma@gmail.com',
          role: 'renter',
          status: 'active',
          joinedAt: DateTime.now().subtract(const Duration(days: 15)),
          bookingsCount: 0,
        ),
        AdminUser(
          id: 'u008',
          name: 'Boma Dike',
          email: 'boma.dike@email.com',
          role: 'lister',
          status: 'active',
          joinedAt: DateTime.now().subtract(const Duration(days: 75)),
          bookingsCount: 0,
        ),
      ];

  static List<VerificationSubmission> _demoVerifications() => [
        VerificationSubmission(
          id: 'v001',
          fullName: 'Amaka Obi',
          email: 'amaka.obi@gmail.com',
          phone: '+2348012345678',
          businessName: 'Obi Properties Ltd',
          status: 'pending',
          submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        VerificationSubmission(
          id: 'v002',
          fullName: 'Segun Adeleke',
          email: 'segun.adeleke@yahoo.com',
          phone: '+2349055678901',
          businessName: 'Adeleke Real Estate',
          status: 'pending',
          submittedAt: DateTime.now().subtract(const Duration(hours: 20)),
        ),
        VerificationSubmission(
          id: 'v003',
          fullName: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          phone: '+2348012345678',
          businessName: 'Woltoh Properties',
          status: 'approved',
          submittedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        VerificationSubmission(
          id: 'v004',
          fullName: 'Eze Chisom',
          email: 'chisom.eze@email.com',
          phone: '+2348098765432',
          businessName: '',
          status: 'rejected',
          submittedAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ];
}
