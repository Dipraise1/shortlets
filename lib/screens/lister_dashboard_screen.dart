import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/lister_service.dart';
import '../utils/price_formatter.dart';
import 'add_edit_property_screen.dart';
import 'chat_screen.dart';
import 'lister_profile_screen.dart';

class ListerDashboardScreen extends StatefulWidget {
  const ListerDashboardScreen({super.key});

  @override
  State<ListerDashboardScreen> createState() =>
      _ListerDashboardScreenState();
}

class _ListerDashboardScreenState extends State<ListerDashboardScreen> {
  int _tab = 0; // 0=Properties, 1=Requests, 2=Messages
  Map<String, String> _profile = {};
  List<ListerProperty> _properties = [];
  List<RentalRequest> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await ListerService.getProfile();
    final props = await ListerService.getProperties();
    final reqs = await ListerService.getRequests();
    if (mounted) {
      setState(() {
        _profile = profile;
        _properties = props;
        _requests = reqs;
        _loading = false;
      });
    }
  }

  int get _pendingCount =>
      _requests.where((r) => r.status == 'pending').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2))
                  : _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(
                _profile['avatar'] ?? 'https://i.pravatar.cc/150?img=12'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey[500])),
                Text(
                  _profile['name'] ?? 'Lister',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (_tab == 0)
                GestureDetector(
                  onTap: _addProperty,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text('Add',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ListerProfileScreen(
                          profile: _profile)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      size: 18, color: Colors.black),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.logout_rounded,
                      size: 18, color: Colors.red[400]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      ('Properties', Icons.home_work_rounded, null),
      ('Requests', Icons.description_outlined, _pendingCount),
      ('Messages', Icons.chat_bubble_outline_rounded, null),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final selected = _tab == e.key;
          final badge = e.value.$3;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = e.key),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.black
                      : const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(e.value.$2,
                        size: 16,
                        color: selected
                            ? Colors.white
                            : Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(e.value.$1,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : Colors.grey[600])),
                    if (badge != null && badge > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('$badge',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: selected
                                    ? Colors.black
                                    : Colors.white)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case 0:
        return _buildPropertiesTab();
      case 1:
        return _buildRequestsTab();
      case 2:
        return _buildMessagesTab();
      default:
        return const SizedBox();
    }
  }

  // ── Properties Tab ────────────────────────────────────────────────────────

  Widget _buildPropertiesTab() {
    if (_properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.grey[100], shape: BoxShape.circle),
              child: Icon(Icons.home_work_rounded,
                  size: 52, color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),
            Text('No listings yet',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Text('Tap "Add" above to list your first property',
                style: GoogleFonts.inter(
                    fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.black,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _properties.length,
        itemBuilder: (_, i) => _buildPropertyCard(_properties[i]),
      ),
    );
  }

  Widget _buildPropertyCard(ListerProperty p) {
    final hasImage = p.imagePaths.isNotEmpty;
    final isNetwork =
        hasImage && p.imagePaths.first.startsWith('http');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: hasImage
                ? (isNetwork
                    ? Image.network(p.imagePaths.first,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover)
                    : Image.file(File(p.imagePaths.first),
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover))
                : Container(
                    width: double.infinity,
                    height: 160,
                    color: Colors.grey[100],
                    child: Icon(Icons.home_rounded,
                        size: 48, color: Colors.grey[400]),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          const SizedBox(height: 3),
                          Text(p.location,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    // Active toggle
                    GestureDetector(
                      onTap: () async {
                        await ListerService.toggleActive(p.id);
                        _load();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: p.isActive
                              ? const Color(0xFFE6F9EF)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.isActive ? 'Active' : 'Paused',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: p.isActive
                                  ? const Color(0xFF00C165)
                                  : Colors.grey[500]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.listingType == 'rent'
                          ? PriceFormatter.formatNairaPerMonth(p.price)
                          : PriceFormatter.formatNairaPerNight(p.price),
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Row(
                      children: [
                        _iconBtn(Icons.edit_outlined, () => _editProperty(p)),
                        const SizedBox(width: 8),
                        _iconBtn(Icons.delete_outline_rounded,
                            () => _confirmDelete(p),
                            color: Colors.red[400]!),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _chip(p.listingType == 'rent' ? 'For Rent' : 'Shortlet'),
                    const SizedBox(width: 6),
                    _chip('${p.bedrooms} bed · ${p.bathrooms} bath'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap,
      {Color color = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700])),
    );
  }

  // ── Requests Tab ──────────────────────────────────────────────────────────

  Widget _buildRequestsTab() {
    if (_requests.isEmpty) {
      return Center(
        child: Text('No requests yet',
            style: GoogleFonts.inter(
                fontSize: 15, color: Colors.grey[500])),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _requests.length,
      itemBuilder: (_, i) => _buildRequestCard(_requests[i]),
    );
  }

  Widget _buildRequestCard(RentalRequest r) {
    final statusColor = {
      'pending': const Color(0xFFF59E0B),
      'accepted': const Color(0xFF00C165),
      'declined': Colors.red,
    }[r.status] ?? Colors.grey;

    final timeAgo = _ago(r.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(r.propertyName,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r.status[0].toUpperCase() + r.status.substring(1),
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Renter info
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                child: Text(
                  r.renterName.isNotEmpty ? r.renterName[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.renterName,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    Text(r.renterPhone,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Text(timeAgo,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reqRow(Icons.calendar_today_outlined, r.dateInfo),
                const SizedBox(height: 6),
                _reqRow(Icons.attach_money_rounded,
                    PriceFormatter.formatNaira(r.totalPrice)),
                if (r.renterEmail.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _reqRow(Icons.email_outlined, r.renterEmail),
                ],
                if (r.message.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _reqRow(Icons.chat_bubble_outline_rounded, r.message),
                ],
              ],
            ),
          ),
          if (r.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionBtn('Decline', Colors.grey[200]!,
                      Colors.black87, () async {
                    await ListerService.updateRequestStatus(
                        r.id, 'declined');
                    _load();
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionBtn('Accept', Colors.black, Colors.white,
                      () async {
                    await ListerService.updateRequestStatus(
                        r.id, 'accepted');
                    _load();
                  }),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    conversationId: ChatScreen.demoConversationId,
                    agentName: r.renterName,
                    agentAvatar:
                        'https://i.pravatar.cc/150?u=${r.renterEmail}',
                    propertyName: r.propertyName,
                  ),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 15, color: Colors.black),
              label: Text('Message Renter',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reqRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
      ),
    );
  }

  // ── Messages Tab ──────────────────────────────────────────────────────────

  Widget _buildMessagesTab() {
    // Build threads from accepted/pending requests
    final threads = _requests
        .where((r) => r.status != 'declined')
        .toList();
    if (threads.isEmpty) {
      return Center(
        child: Text('No messages yet',
            style: GoogleFonts.inter(
                fontSize: 15, color: Colors.grey[500])),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: threads.length,
      itemBuilder: (_, i) => _buildMessageThread(threads[i]),
    );
  }

  Widget _buildMessageThread(RentalRequest r) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: ChatScreen.demoConversationId,
            agentName: r.renterName,
            agentAvatar:
                'https://i.pravatar.cc/150?u=${r.renterEmail}',
            propertyName: r.propertyName,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=${r.renterEmail}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.renterName,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      Text(_ago(r.createdAt),
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(r.propertyName,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 3),
                  Text(
                    r.message.isNotEmpty
                        ? r.message
                        : r.dateInfo,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _ago(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Logout',
            style: GoogleFonts.inter(
                fontSize: 17, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?',
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.grey[600])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: Colors.grey[600]))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Logout',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ListerService.logout();
      Navigator.pop(context);
    }
  }

  Future<void> _addProperty() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => const AddEditPropertyScreen()),
    );
    if (result == true) _load();
  }

  Future<void> _editProperty(ListerProperty p) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditPropertyScreen(property: p)),
    );
    if (result == true) _load();
  }

  Future<void> _confirmDelete(ListerProperty p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Listing',
            style: GoogleFonts.inter(
                fontSize: 17, fontWeight: FontWeight.bold)),
        content: Text(
            'Remove "${p.name}" from your listings? This cannot be undone.',
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.grey[600])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: Colors.grey[600]))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ListerService.deleteProperty(p.id);
      _load();
    }
  }
}
