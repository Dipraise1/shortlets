import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/lister_service.dart';

class ListerProfileScreen extends StatefulWidget {
  final Map<String, String> profile;
  const ListerProfileScreen({super.key, required this.profile});

  @override
  State<ListerProfileScreen> createState() => _ListerProfileScreenState();
}

class _ListerProfileScreenState extends State<ListerProfileScreen> {
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    ListerService.getVerificationStatus()
        .then((s) => mounted ? setState(() => _status = s) : null);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Profile',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(
                      p['avatar'] ?? 'https://i.pravatar.cc/150?img=12'),
                ),
                const SizedBox(height: 14),
                Text(
                  p['name'] ?? 'Lister',
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 6),
                _verificationBadge(_status),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                _infoRow(Icons.email_outlined, 'Email',
                    p['email'] ?? '—'),
                _divider(),
                _infoRow(Icons.phone_outlined, 'Phone',
                    p['phone'] ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_status == 'pending')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD966)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 18, color: Color(0xFFB38600)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Verification Under Review',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7A5800))),
                        const SizedBox(height: 3),
                        Text(
                          'We are reviewing your documents and may visit the property. This typically takes 1–3 business days.',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF7A5800)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (_status == 'verified')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F9EF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF00C165).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded,
                      size: 18, color: Color(0xFF00C165)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your account is fully verified. You can list properties and receive bookings.',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF006B35)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _verificationBadge(String status) {
    final config = {
      'pending': (
        'Under Review',
        const Color(0xFFF59E0B),
        const Color(0xFFFFF8E6)
      ),
      'verified': (
        'Verified',
        const Color(0xFF00C165),
        const Color(0xFFE6F9EF)
      ),
      'unverified': (
        'Unverified',
        Colors.grey,
        const Color(0xFFF2F2F2)
      ),
    }[status] ?? ('Unverified', Colors.grey, const Color(0xFFF2F2F2));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: config.$3,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'verified'
                ? Icons.verified_rounded
                : Icons.schedule_rounded,
            size: 13,
            color: config.$2,
          ),
          const SizedBox(width: 5),
          Text(config.$1,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: config.$2)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey[500])),
          const Spacer(),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1, indent: 16, endIndent: 16, color: Colors.grey[100]);
}
