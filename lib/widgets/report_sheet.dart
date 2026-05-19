import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportSheet extends StatefulWidget {
  final String propertyId;
  final String propertyName;

  const ReportSheet({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  static Future<void> show({
    required BuildContext context,
    required String propertyId,
    required String propertyName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportSheet(
        propertyId: propertyId,
        propertyName: propertyName,
      ),
    );
  }

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  static const _reasons = [
    'Misleading information',
    'Suspected fraud or scam',
    'Incorrect location',
    'Property no longer available',
    'Inappropriate or offensive content',
    'Duplicate listing',
    'Other',
  ];

  String? _selected;
  final _detailController = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selected == null) return;
    setState(() => _loading = true);

    // TODO: send to Supabase `reports` table when backend is live
    // await SupabaseService.submitReport(
    //   propertyId: widget.propertyId,
    //   reason: _selected!,
    //   details: _detailController.text.trim(),
    // );
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) setState(() { _loading = false; _submitted = true; });
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      // Shift sheet up when keyboard is open
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 28),
        child: _submitted ? _buildDone() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
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
        const SizedBox(height: 20),

        Text('Report Listing',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 4),
        Text(
          widget.propertyName,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 20),

        Text('What\'s the issue?',
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 12),

        ..._reasons.map((reason) => _buildReasonTile(reason)),

        const SizedBox(height: 16),

        // Optional details box
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _detailController,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add more details (optional)',
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selected == null || _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[200],
              disabledForegroundColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text('Submit Report',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonTile(String reason) {
    final selected = _selected == reason;
    return GestureDetector(
      onTap: () => setState(() => _selected = reason),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? Colors.black : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDone() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(height: 32),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                color: Colors.black, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Report Submitted',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 8),
          Text(
            'Thanks for letting us know.\nWe\'ll review this listing shortly.',
            textAlign: TextAlign.center,
            style:
                GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
