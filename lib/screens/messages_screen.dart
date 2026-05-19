import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../widgets/pill_navigation_bar.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  // Fallback static conversations when Supabase not connected
  final List<Map<String, dynamic>> _demoConversations = [
    {
      'id': ChatScreen.demoConversationId,
      'agents': {
        'name': 'LS Woltoh',
        'avatar_url': 'https://i.pravatar.cc/150?img=12',
      },
      'properties': {'name': 'Green Hangout Place'},
      'last_message': 'Hi, is the Wuse 2 apartment still available?',
      'last_message_at': DateTime.now()
          .subtract(const Duration(minutes: 2))
          .toIso8601String(),
      'unread': true,
    },
    {
      'id': 'demo2',
      'agents': {
        'name': 'Property Manager',
        'avatar_url': 'https://i.pravatar.cc/150?img=5',
      },
      'properties': {'name': 'Elegant Apartment'},
      'last_message':
          'Thank you for your inquiry. We\'ll get back to you soon.',
      'last_message_at': DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
      'unread': false,
    },
    {
      'id': 'demo3',
      'agents': {
        'name': 'Estate Agent',
        'avatar_url': 'https://i.pravatar.cc/150?img=8',
      },
      'properties': {'name': 'Modern Luxury Villa'},
      'last_message':
          'The property viewing is scheduled for tomorrow at 10am.',
      'last_message_at': DateTime.now()
          .subtract(const Duration(hours: 3))
          .toIso8601String(),
      'unread': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      final data = await SupabaseService.fetchConversations();
      if (mounted) {
        setState(() {
          _conversations = data;
          _loading = false;
        });
      }
    } else {
      setState(() {
        _conversations = List.from(_demoConversations);
        _loading = false;
      });
    }
  }

  int get _unreadCount =>
      _conversations.where((c) => c['unread'] == true).length;

  String _timeAgo(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _openChat(Map<String, dynamic> conv) {
    final isDemoId = conv['id'] == ChatScreen.demoConversationId ||
        (conv['id'] as String).startsWith('demo');
    final convId = isDemoId ? ChatScreen.demoConversationId : conv['id'] as String;
    final agent = conv['agents'] as Map<String, dynamic>? ?? {};
    final property = conv['properties'] as Map<String, dynamic>?;

    setState(() => conv['unread'] = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: convId,
          agentName: agent['name'] ?? 'Agent',
          agentAvatar: agent['avatar_url'] ??
              'https://i.pravatar.cc/150?img=1',
          propertyName: property?['name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Messages',
                            style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        if (_unreadCount > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text('$_unreadCount',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8)
                        ],
                      ),
                      child: const Icon(Icons.search_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            if (_loading)
              const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2)))
            else if (_conversations.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildConversationCard(_conversations[index]),
                    childCount: _conversations.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: PillNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.message_rounded,
                size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text('No Messages',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Your conversations will appear here',
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conv) {
    final bool unread = conv['unread'] == true;
    final agent = conv['agents'] as Map<String, dynamic>? ?? {};
    final property = conv['properties'] as Map<String, dynamic>?;

    return GestureDetector(
      onTap: () => _openChat(conv),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(
                    agent['avatar_url'] ??
                        'https://i.pravatar.cc/150?img=1',
                  ),
                ),
                if (unread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        agent['name'] ?? 'Agent',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: unread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: Colors.black),
                      ),
                      Text(
                          _timeAgo(conv['last_message_at'] as String?),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                  if (property != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      property['name'] ?? '',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500]),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    conv['last_message'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: unread
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: unread ? Colors.black87 : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Colors.black, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
