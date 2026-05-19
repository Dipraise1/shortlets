import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';
import 'property_details_screen.dart';
import '../models/property.dart';

// Notification types drive where tapping navigates
enum _NType { message, request, booking, review, system }

class _Notif {
  final String id;
  final _NType type;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  bool read;

  _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.read = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _notifications = [
    _Notif(
      id: 'n1',
      type: _NType.message,
      title: 'New message from LS Woltoh',
      body: 'The property viewing is scheduled for tomorrow at 10am.',
      time: '2m ago',
      icon: Icons.chat_bubble_rounded,
      iconColor: Colors.white,
      iconBg: Colors.black,
    ),
    _Notif(
      id: 'n2',
      type: _NType.request,
      title: 'New rental request',
      body: 'Adaeze Okonkwo sent a request for Green Hangout Place.',
      time: '1h ago',
      icon: Icons.description_rounded,
      iconColor: const Color(0xFFB38600),
      iconBg: const Color(0xFFFFF3CD),
    ),
    _Notif(
      id: 'n3',
      type: _NType.booking,
      title: 'Booking confirmed',
      body: 'Your booking for Elegant Apartment has been accepted.',
      time: '3h ago',
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF00C165),
      iconBg: const Color(0xFFE6F9EF),
      read: true,
    ),
    _Notif(
      id: 'n4',
      type: _NType.message,
      title: 'New message from Estate Agent',
      body: 'Hi! Is the Wuse 2 apartment still available for next weekend?',
      time: '5h ago',
      icon: Icons.chat_bubble_rounded,
      iconColor: Colors.white,
      iconBg: Colors.black,
    ),
    _Notif(
      id: 'n5',
      type: _NType.review,
      title: 'Someone reviewed a property',
      body: 'Modern Luxury Villa received a new 5★ review.',
      time: 'Yesterday',
      icon: Icons.star_rounded,
      iconColor: const Color(0xFFB38600),
      iconBg: const Color(0xFFFFF3CD),
      read: true,
    ),
    _Notif(
      id: 'n6',
      type: _NType.request,
      title: 'Request accepted',
      body: 'Your rental request for 4 Bedroom Detached House was accepted.',
      time: '2 days ago',
      icon: Icons.home_rounded,
      iconColor: const Color(0xFF00C165),
      iconBg: const Color(0xFFE6F9EF),
      read: true,
    ),
    _Notif(
      id: 'n7',
      type: _NType.system,
      title: 'Verification update',
      body: 'Your lister verification is under review. We\'ll notify you within 1–3 days.',
      time: '3 days ago',
      icon: Icons.verified_user_rounded,
      iconColor: Colors.grey[600]!,
      iconBg: Colors.grey[100]!,
      read: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.read).length;

  void _onTap(_Notif n) {
    setState(() => n.read = true);

    switch (n.type) {
      case _NType.message:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: ChatScreen.demoConversationId,
              agentName: n.title.replaceFirst('New message from ', ''),
              agentAvatar: 'https://i.pravatar.cc/150?img=12',
            ),
          ),
        );
        break;

      case _NType.request:
      case _NType.booking:
        // Navigate to a relevant property detail as demo
        final props = PropertyData.getAbujaProperties();
        if (props.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailsScreen(property: props.first),
            ),
          );
        }
        break;

      case _NType.review:
        final props = PropertyData.getAbujaProperties();
        if (props.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailsScreen(property: props.first),
            ),
          );
        }
        break;

      case _NType.system:
        // No navigation — just mark read
        break;
    }
  }

  void _markAllRead() => setState(() {
        for (final n in _notifications) {
          n.read = true;
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              elevation: 0,
              backgroundColor: const Color(0xFFF8F9FA),
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              toolbarHeight: 64,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6)
                              ],
                            ),
                            child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Notifications',
                            style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        if (_unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text('$_unreadCount',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    if (_unreadCount > 0)
                      GestureDetector(
                        onTap: _markAllRead,
                        child: Text('Mark all read',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    // Date group headers
                    final notif = _notifications[i];
                    final prevNotif =
                        i > 0 ? _notifications[i - 1] : null;
                    final group = _groupLabel(notif.time);
                    final prevGroup =
                        prevNotif != null ? _groupLabel(prevNotif.time) : '';
                    final showHeader = group != prevGroup;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: EdgeInsets.only(
                                left: 4,
                                top: i == 0 ? 4 : 20,
                                bottom: 10),
                            child: Text(group,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500])),
                          ),
                        _buildNotifCard(notif),
                      ],
                    );
                  },
                  childCount: _notifications.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _groupLabel(String time) {
    if (time.contains('m ago') || time.contains('h ago')) return 'Today';
    if (time == 'Yesterday') return 'Yesterday';
    return 'Earlier';
  }

  Widget _buildNotifCard(_Notif n) {
    return GestureDetector(
      onTap: () => _onTap(n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.read ? Colors.white : const Color(0xFFFAFAFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.read
                ? Colors.transparent
                : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: n.read ? 0.03 : 0.06),
                blurRadius: n.read ? 6 : 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: n.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(n.icon, size: 20, color: n.iconColor),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: n.read
                                ? FontWeight.w500
                                : FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(n.time,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Unread dot
            if (!n.read) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Colors.black, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
