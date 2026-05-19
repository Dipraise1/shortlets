import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property.dart';
import '../utils/price_formatter.dart';
import 'chat_screen.dart';

class RentalRequestScreen extends StatefulWidget {
  final Property property;

  const RentalRequestScreen({super.key, required this.property});

  @override
  State<RentalRequestScreen> createState() => _RentalRequestScreenState();
}

class _RentalRequestScreenState extends State<RentalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _months = 1;
  bool _submitting = false;

  bool get _isRent => widget.property.listingType == 'rent';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  double get _totalPrice {
    if (_isRent) return widget.property.price * _months;
    if (_checkIn == null || _checkOut == null) return 0;
    final nights = _checkOut!.difference(_checkIn!).inDays;
    return widget.property.price * nights;
  }

  int get _nights =>
      (_checkIn != null && _checkOut != null)
          ? _checkOut!.difference(_checkIn!).inDays
          : 0;

  Future<void> _pickDate(bool isCheckIn) async {
    final now = DateTime.now();
    final first = isCheckIn ? now : (_checkIn ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? (_checkIn ?? now) : (_checkOut ?? first.add(const Duration(days: 1))),
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (_checkOut != null && !_checkOut!.isAfter(picked)) {
          _checkOut = picked.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Select';
    return '${d.day} ${_monthName(d.month)} ${d.year}';
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  bool get _canSubmit {
    if (_nameCtrl.text.trim().isEmpty) return false;
    if (_emailCtrl.text.trim().isEmpty) return false;
    if (_phoneCtrl.text.trim().isEmpty) return false;
    if (_isRent) return true;
    return _checkIn != null && _checkOut != null && _nights > 0;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    final prop = widget.property;

    // Build the email body
    final dateInfo = _isRent
        ? 'Duration: $_months month${_months > 1 ? 's' : ''}'
        : 'Check-in: ${_formatDate(_checkIn)}\nCheck-out: ${_formatDate(_checkOut)} ($_nights night${_nights != 1 ? 's' : ''})';

    final emailBody = '''
New ${_isRent ? 'Rental' : 'Shortlet'} Request — ${prop.name}

PROPERTY DETAILS
Property: ${prop.name}
Location: ${prop.location}
Type: ${_isRent ? 'For Rent' : 'Shortlet'}
Price: ${_isRent ? PriceFormatter.formatNairaPerMonth(prop.price) : PriceFormatter.formatNairaPerNight(prop.price)}

REQUEST DETAILS
$dateInfo
${_isRent ? 'Monthly Rent' : 'Total'}: ${PriceFormatter.formatNaira(_totalPrice)}

RENTER DETAILS
Name: $name
Email: $email
Phone: $phone

MESSAGE FROM RENTER
${message.isNotEmpty ? message : '(no additional message)'}

---
This request was sent via Rosera.
    '''.trim();

    final subject = Uri.encodeComponent(
        '${_isRent ? 'Rental' : 'Shortlet'} Request — ${prop.name}');
    final body = Uri.encodeComponent(emailBody);
    final mailUri = Uri.parse('mailto:${prop.agent.email}?subject=$subject&body=$body');

    // Build the chat summary message
    final chatSummary = '📋 *${_isRent ? 'Rental' : 'Shortlet'} Request*\n'
        '• $dateInfo\n'
        '• Total: ${PriceFormatter.formatNaira(_totalPrice)}\n'
        '• Contact: $phone\n'
        '• Email: $email'
        '${message.isNotEmpty ? '\n\n"$message"' : ''}';

    setState(() => _submitting = false);

    if (!mounted) return;

    // Navigate to chat first with the pre-filled request summary
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: ChatScreen.demoConversationId,
          agentName: prop.agent.name,
          agentAvatar: prop.agent.imageUrl,
          propertyName: prop.name,
          initialMessage: chatSummary,
        ),
      ),
    );

    // Then open mail client
    if (await canLaunchUrl(mailUri)) {
      await launchUrl(mailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isRent ? 'Request to Rent' : 'Book Now',
          style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            _buildPropertyCard(),
            const SizedBox(height: 24),

            if (!_isRent) ...[
              _sectionLabel('Dates'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDateTile('Check-in', _checkIn, () => _pickDate(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateTile('Check-out', _checkOut, () => _pickDate(false))),
                ],
              ),
              if (_nights > 0) ...[
                const SizedBox(height: 10),
                _buildPriceSummary(),
              ],
              const SizedBox(height: 24),
            ] else ...[
              _sectionLabel('Duration'),
              const SizedBox(height: 12),
              _buildMonthsPicker(),
              const SizedBox(height: 10),
              _buildPriceSummary(),
              const SizedBox(height: 24),
            ],

            _sectionLabel('Your Details'),
            const SizedBox(height: 12),
            _buildField(_nameCtrl, 'Full name', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _buildField(_emailCtrl, 'Email address', Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildField(_phoneCtrl, 'Phone number', Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]),
            const SizedBox(height: 24),

            _sectionLabel('Message to Lister (optional)'),
            const SizedBox(height: 12),
            _buildMessageField(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPropertyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.property.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 64, height: 64, color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.property.name,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(widget.property.location,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 5),
                Text(
                  _isRent
                      ? PriceFormatter.formatNairaPerMonth(widget.property.price)
                      : PriceFormatter.formatNairaPerNight(widget.property.price),
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    final selected = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? Colors.black : Colors.grey[300]!,
              width: selected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.black : Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthsPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Months',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          Row(
            children: [
              IconButton(
                onPressed: _months > 1
                    ? () => setState(() => _months--)
                    : null,
                icon: Icon(Icons.remove_circle_outline_rounded,
                    color: _months > 1 ? Colors.black : Colors.grey[300]),
              ),
              SizedBox(
                width: 32,
                child: Text('$_months',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: _months < 24
                    ? () => setState(() => _months++)
                    : null,
                icon: Icon(Icons.add_circle_outline_rounded,
                    color: _months < 24 ? Colors.black : Colors.grey[300]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isRent
                ? '$_months month${_months > 1 ? 's' : ''} × ${PriceFormatter.formatNaira(widget.property.price)}'
                : '$_nights night${_nights != 1 ? 's' : ''} × ${PriceFormatter.formatNaira(widget.property.price)}',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
          ),
          Text(
            PriceFormatter.formatNaira(_totalPrice),
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87));
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
          prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _messageCtrl,
        maxLines: 4,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText:
              'Introduce yourself or ask any questions about the property...',
          hintStyle:
              GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final ready = _canSubmit;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_totalPrice > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.grey[600])),
                Text(PriceFormatter.formatNaira(_totalPrice),
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: ready && !_submitting ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[200],
                disabledForegroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRent ? 'Send Rental Request' : 'Send Booking Request',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.send_rounded, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Request is sent to the lister via email & chat',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
