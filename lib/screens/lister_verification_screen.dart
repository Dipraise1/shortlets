import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/lister_service.dart';
import 'lister_dashboard_screen.dart';

class ListerVerificationScreen extends StatefulWidget {
  const ListerVerificationScreen({super.key});

  @override
  State<ListerVerificationScreen> createState() =>
      _ListerVerificationScreenState();
}

class _ListerVerificationScreenState
    extends State<ListerVerificationScreen> {
  int _step = 0; // 0-3
  final _picker = ImagePicker();
  bool _submitting = false;

  // Step 0 — Personal Details
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _state = '';

  // Step 1 — Identity
  final _ninCtrl = TextEditingController();
  String? _idDocPath;

  // Step 2 — Property Claim
  final _propAddressCtrl = TextEditingController();
  final _propCityCtrl = TextEditingController();
  String _propState = '';
  String _role = 'owner'; // owner | agent | caretaker

  // Step 3 — Proof of Ownership
  String? _proofDocPath;
  String _proofType = 'cof_o'; // cof_o | deed | utility | tenancy

  static const _nigerianStates = [
    'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa',
    'Benue', 'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti',
    'Enugu', 'FCT Abuja', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano',
    'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger',
    'Ogun', 'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto',
    'Taraba', 'Yobe', 'Zamfara',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ninCtrl.dispose();
    _propAddressCtrl.dispose();
    _propCityCtrl.dispose();
    super.dispose();
  }

  bool get _stepValid {
    switch (_step) {
      case 0:
        return _nameCtrl.text.trim().isNotEmpty &&
            _emailCtrl.text.trim().isNotEmpty &&
            _phoneCtrl.text.trim().length >= 11 &&
            _state.isNotEmpty;
      case 1:
        return _ninCtrl.text.trim().length == 11 && _idDocPath != null;
      case 2:
        return _propAddressCtrl.text.trim().isNotEmpty &&
            _propCityCtrl.text.trim().isNotEmpty &&
            _propState.isNotEmpty;
      case 3:
        return _proofDocPath != null;
      default:
        return false;
    }
  }

  Future<void> _pickDoc({bool isIdDoc = true}) async {
    final img = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (img != null) {
      setState(() {
        if (isIdDoc) {
          _idDocPath = img.path;
        } else {
          _proofDocPath = img.path;
        }
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await ListerService.submitVerification({
      'fullName': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'state': _state,
      'nin': _ninCtrl.text.trim(),
      'idDocPath': _idDocPath ?? '',
      'propertyAddress': _propAddressCtrl.text.trim(),
      'propertyCity': _propCityCtrl.text.trim(),
      'propertyState': _propState,
      'role': _role,
      'proofType': _proofType,
      'proofDocPath': _proofDocPath ?? '',
    });
    if (mounted) setState(() => _submitting = false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const ListerDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Colors.black),
                onPressed: () => setState(() => _step--),
              )
            : IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 22, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text('Lister Verification',
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _buildProgressBar(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: _buildStep(),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 3 : 0),
            decoration: BoxDecoration(
              color: i <= _step ? Colors.black : Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildPersonalDetails();
      case 1:
        return _buildIdentityStep();
      case 2:
        return _buildPropertyClaim();
      case 3:
        return _buildProofOfOwnership();
      default:
        return const SizedBox();
    }
  }

  // ── Step 0: Personal Details ──────────────────────────────────────────────

  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Personal Details', 'Tell us about yourself', '1/4'),
        const SizedBox(height: 28),
        _label('Full Name'),
        const SizedBox(height: 8),
        _field(_nameCtrl, 'As it appears on your ID'),
        const SizedBox(height: 16),
        _label('Email Address'),
        const SizedBox(height: 8),
        _field(_emailCtrl, 'your@email.com',
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _label('Phone Number'),
        const SizedBox(height: 8),
        _field(_phoneCtrl, '08012345678',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))
            ]),
        const SizedBox(height: 16),
        _label('State of Residence'),
        const SizedBox(height: 8),
        _stateDropdown(_state, (v) => setState(() => _state = v)),
      ],
    );
  }

  // ── Step 1: Identity ──────────────────────────────────────────────────────

  Widget _buildIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Identity Verification',
            'We need to confirm who you are', '2/4'),
        const SizedBox(height: 28),
        _label('NIN (National Identification Number)'),
        const SizedBox(height: 8),
        _field(_ninCtrl, '12345678901',
            keyboardType: TextInputType.number,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        const SizedBox(height: 16),
        _label('Government-Issued ID Photo'),
        const SizedBox(height: 4),
        Text('Voter\'s card, driver\'s licence, passport, or NIN slip',
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 10),
        _docUploader(_idDocPath, 'Upload ID Photo',
            () => _pickDoc(isIdDoc: true)),
      ],
    );
  }

  // ── Step 2: Property Claim ────────────────────────────────────────────────

  Widget _buildPropertyClaim() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Property Details',
            'Tell us about the property you manage', '3/4'),
        const SizedBox(height: 28),
        _label('Your Role'),
        const SizedBox(height: 10),
        _roleSelector(),
        const SizedBox(height: 16),
        _label('Property Address'),
        const SizedBox(height: 8),
        _field(_propAddressCtrl, 'e.g. 12 Wuse 2, Plot 345'),
        const SizedBox(height: 16),
        _label('City'),
        const SizedBox(height: 8),
        _field(_propCityCtrl, 'e.g. Abuja'),
        const SizedBox(height: 16),
        _label('State'),
        const SizedBox(height: 8),
        _stateDropdown(
            _propState, (v) => setState(() => _propState = v)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD966)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: Color(0xFFB38600)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Our team may physically visit the property to confirm your claim before approval.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF7A5800)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 3: Proof of Ownership ────────────────────────────────────────────

  Widget _buildProofOfOwnership() {
    const types = {
      'cof_o': 'Certificate of Occupancy (C of O)',
      'deed': 'Deed of Assignment',
      'tenancy': 'Tenancy / Management Agreement',
      'utility': 'Utility Bill (property address)',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Proof of Ownership',
            'Upload a document showing you control this property', '4/4'),
        const SizedBox(height: 28),
        _label('Document Type'),
        const SizedBox(height: 10),
        ...types.entries.map((e) => _radioTile(
              e.value,
              e.key == _proofType,
              () => setState(() => _proofType = e.key),
            )),
        const SizedBox(height: 16),
        _label('Upload Document Photo'),
        const SizedBox(height: 4),
        Text('Take a clear photo — all text must be legible',
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 10),
        _docUploader(_proofDocPath, 'Upload Document',
            () => _pickDoc(isIdDoc: false)),
      ],
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final isLast = _step == 3;
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _stepValid && !_submitting
              ? () {
                  if (isLast) {
                    _submit();
                  } else {
                    setState(() => _step++);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[200],
            disabledForegroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(
                  isLast ? 'Submit for Verification' : 'Continue',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────

  Widget _stepTitle(String title, String subtitle, String step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('Step $step',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600])),
        ),
        const SizedBox(height: 10),
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.grey[500])),
      ],
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87));

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
          border: InputBorder.none,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _stateDropdown(String current, void Function(String) onChanged) {
    final selected = current.isNotEmpty;
    return GestureDetector(
      onTap: () => _showStatePicker(current, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey[200]!,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected ? current : 'Select state',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: selected ? Colors.black : Colors.grey[400],
                  fontWeight:
                      selected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: selected ? Colors.black : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatePicker(
      String current, void Function(String) onChanged) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StatePickerSheet(
        states: _nigerianStates,
        selected: current,
        onSelect: (v) {
          onChanged(v);
          setState(() {});
        },
      ),
    );
  }

  Widget _roleSelector() {
    final roles = {
      'owner': ('Property Owner', Icons.home_rounded),
      'agent': ('Registered Agent', Icons.badge_rounded),
      'caretaker': ('Caretaker / Manager', Icons.manage_accounts_rounded),
    };
    return Row(
      children: roles.entries.map((e) {
        final selected = _role == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _role = e.key),
            child: Container(
              margin: EdgeInsets.only(
                  right: e.key != 'caretaker' ? 8 : 0),
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected
                        ? Colors.black
                        : Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(e.value.$2,
                      size: 20,
                      color: selected ? Colors.white : Colors.grey[600]),
                  const SizedBox(height: 5),
                  Text(
                    e.value.$1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _radioTile(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? Colors.black : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? Colors.black : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 18,
              color: selected ? Colors.white : Colors.grey[400],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selected ? Colors.white : Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docUploader(
      String? path, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: path != null ? null : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: path != null ? Colors.black : Colors.grey[300]!,
            width: path != null ? 2 : 1.5,
            style: path != null
                ? BorderStyle.solid
                : BorderStyle.solid,
          ),
        ),
        child: path != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(path), fit: BoxFit.cover),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Change',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file_rounded,
                      size: 32, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600])),
                  const SizedBox(height: 3),
                  Text('Tap to choose from gallery',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[400])),
                ],
              ),
      ),
    );
  }
}

// ── State Picker Bottom Sheet ─────────────────────────────────────────────────

class _StatePickerSheet extends StatefulWidget {
  final List<String> states;
  final String selected;
  final void Function(String) onSelect;

  const _StatePickerSheet({
    required this.states,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends State<_StatePickerSheet> {
  final _searchCtrl = TextEditingController();
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.states;
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? widget.states
            : widget.states
                .where((s) => s.toLowerCase().contains(q))
                .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select State',
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search state...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 18, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No results',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey[400])),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                        20, 4, 20, bottomPad + 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final state = _filtered[i];
                      final isSelected = state == widget.selected;
                      return GestureDetector(
                        onTap: () {
                          widget.onSelect(state);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black
                                : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  state,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_rounded,
                                    size: 16, color: Colors.white),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
