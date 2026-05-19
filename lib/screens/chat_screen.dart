import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../utils/price_formatter.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String agentName;
  final String agentAvatar;
  final String? propertyName;
  final String? initialMessage; // pre-send on open (from rental request)

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.agentName,
    required this.agentAvatar,
    this.propertyName,
    this.initialMessage,
  });

  static const String demoConversationId = 'demo';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  RealtimeChannel? _channel;
  bool _loading = true;
  bool get _isDemo =>
      widget.conversationId == ChatScreen.demoConversationId;

  @override
  void initState() {
    super.initState();
    _isDemo ? _loadDemoMessages() : _loadMessages();
  }

  void _loadDemoMessages() {
    setState(() {
      _messages.addAll([
        {
          'id': '1',
          'content': 'Hello! I\'m interested in this property.',
          'sender_id': 'user',
          'created_at': DateTime.now()
              .subtract(const Duration(minutes: 5))
              .toIso8601String(),
          'is_mine': true,
          'type': 'text',
        },
        {
          'id': '2',
          'content':
              'Hi there! Yes, the property is still available. When would you like to schedule a viewing?',
          'sender_id': 'agent',
          'created_at': DateTime.now()
              .subtract(const Duration(minutes: 3))
              .toIso8601String(),
          'is_mine': false,
          'type': 'text',
        },
      ]);
      _loading = false;
    });
    // Auto-send initial message (rental request summary)
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addMessage(widget.initialMessage!, isMine: true);
        _scrollToBottom();
      });
    } else {
      _scrollToBottom();
    }
  }

  Future<void> _loadMessages() async {
    final msgs =
        await SupabaseService.fetchMessages(widget.conversationId);
    final myId = SupabaseService.currentUser?.id ?? '';
    if (mounted) {
      setState(() {
        _messages.addAll(msgs.map((m) => {
              ...m,
              'is_mine': m['sender_id'] == myId,
              'type': 'text',
            }));
        _loading = false;
      });
      if (widget.initialMessage != null) {
        await SupabaseService.sendMessage(
          conversationId: widget.conversationId,
          content: widget.initialMessage!,
        );
      }
      _scrollToBottom();
      _subscribeRealtime();
      await SupabaseService.markMessagesRead(widget.conversationId);
    }
  }

  void _subscribeRealtime() {
    final myId = SupabaseService.currentUser?.id ?? '';
    _channel = SupabaseService.subscribeToMessages(
      conversationId: widget.conversationId,
      onInsert: (msg) {
        if (mounted) {
          setState(() => _messages.add({
                ...msg,
                'is_mine': msg['sender_id'] == myId,
                'type': 'text',
              }));
          _scrollToBottom();
        }
      },
    );
  }

  void _addMessage(String content,
      {bool isMine = true, String type = 'text', Map<String, dynamic>? extra}) {
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'sender_id': isMine ? 'user' : 'agent',
        'created_at': DateTime.now().toIso8601String(),
        'is_mine': isMine,
        'type': type,
        if (extra != null) ...extra,
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    if (_isDemo) {
      _addMessage(text, isMine: true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        _addMessage(
            'Thanks for your message! We\'ll get back to you shortly.',
            isMine: false);
      }
    } else {
      await SupabaseService.sendMessage(
        conversationId: widget.conversationId,
        content: text,
      );
    }
  }

  void _showPaymentRequestSheet() {
    final amountCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    final accountCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
              24, 12, 24, MediaQuery.of(ctx).padding.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Request Payment',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 4),
              Text('Renter will see your payment details in chat',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey[500])),
              const SizedBox(height: 20),
              _sheetField(amountCtrl, 'Amount (₦)', TextInputType.number),
              const SizedBox(height: 10),
              _sheetField(bankCtrl, 'Bank name', TextInputType.text),
              const SizedBox(height: 10),
              _sheetField(accountCtrl, 'Account number',
                  TextInputType.number),
              const SizedBox(height: 10),
              _sheetField(
                  nameCtrl, 'Account name', TextInputType.text),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountCtrl.text.replaceAll(',', ''));
                    if (amount == null || amount <= 0) return;
                    if (bankCtrl.text.trim().isEmpty ||
                        accountCtrl.text.trim().isEmpty ||
                        nameCtrl.text.trim().isEmpty) return;

                    final content =
                        'PAYMENT_REQUEST:${amount.toStringAsFixed(0)}|${bankCtrl.text.trim()}|${accountCtrl.text.trim()}|${nameCtrl.text.trim()}';
                    Navigator.pop(ctx);
                    _addMessage(content,
                        isMine: false, type: 'payment_request');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text('Send Payment Request',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
      TextEditingController ctrl, String hint, TextInputType type) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(widget.agentAvatar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.agentName,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    if (widget.propertyName != null)
                      Text(widget.propertyName!,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey[500]),
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          // Payment request button for lister side
          actions: [
            IconButton(
              tooltip: 'Request Payment',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    size: 18, color: Colors.black),
              ),
              onPressed: _showPaymentRequestSheet,
            ),
            const SizedBox(width: 8),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2))
                  : _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: _messages.length,
                          itemBuilder: (ctx, i) =>
                              _buildBubble(_messages[i], i),
                        ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text('Start the conversation',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text('Send a message to ${widget.agentName}',
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg, int index) {
    final type = msg['type'] ?? 'text';
    if (type == 'payment_request') return _buildPaymentCard(msg);

    final isMine = msg['is_mine'] == true;
    final prevMine =
        index > 0 && _messages[index - 1]['is_mine'] == true;
    final showAvatar = !isMine && (index == 0 || prevMine);

    return Padding(
      padding: EdgeInsets.only(bottom: 4, top: showAvatar ? 12 : 0),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(widget.agentAvatar),
              )
            else
              const SizedBox(width: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.72),
              decoration: BoxDecoration(
                color: isMine ? Colors.black : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMine ? 18 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Text(
                msg['content'] ?? '',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isMine ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> msg) {
    final raw = (msg['content'] as String).replaceFirst('PAYMENT_REQUEST:', '');
    final parts = raw.split('|');
    final amount = double.tryParse(parts[0]) ?? 0;
    final bank = parts.length > 1 ? parts[1] : '';
    final account = parts.length > 2 ? parts[2] : '';
    final accountName = parts.length > 3 ? parts[3] : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.82,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  Text('Payment Request',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 14),
              Text(PriceFormatter.formatNaira(amount),
                  style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 14),
              _payRow('Bank', bank),
              const SizedBox(height: 6),
              _payRow('Account', account),
              const SizedBox(height: 6),
              _payRow('Name', accountName),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: account));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Account number copied',
                          style:
                              GoogleFonts.inter(fontSize: 13)),
                      backgroundColor: Colors.black,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.copy_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text('Copy Account Number',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _payRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: Colors.grey[500])),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
