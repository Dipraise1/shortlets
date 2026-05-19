import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/lister_service.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final ListerProperty? property; // null = add mode

  const AddEditPropertyScreen({super.key, this.property});

  @override
  State<AddEditPropertyScreen> createState() =>
      _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();

  String _listingType = 'shortlet';
  String _propertyType = 'apartment';
  int _bedrooms = 1;
  int _bathrooms = 1;
  List<String> _imagePaths = [];
  bool _saving = false;

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.property!;
      _nameCtrl.text = p.name;
      _locationCtrl.text = p.location;
      _cityCtrl.text = p.city;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _descCtrl.text = p.description;
      _listingType = p.listingType;
      _propertyType = p.propertyType;
      _bedrooms = p.bedrooms;
      _bathrooms = p.bathrooms;
      _imagePaths = List.from(p.imagePaths);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _cityCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        for (final img in picked) {
          if (!_imagePaths.contains(img.path)) {
            _imagePaths.add(img.path);
          }
        }
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final img = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 80);
    if (img != null && !_imagePaths.contains(img.path)) {
      setState(() => _imagePaths.add(img.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text('Choose from Library',
                  style: GoogleFonts.inter(fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text('Take Photo',
                  style: GoogleFonts.inter(fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  bool get _canSave =>
      _nameCtrl.text.trim().isNotEmpty &&
      _locationCtrl.text.trim().isNotEmpty &&
      _cityCtrl.text.trim().isNotEmpty &&
      (_priceCtrl.text.trim().isNotEmpty &&
          double.tryParse(_priceCtrl.text.replaceAll(',', '')) != null);

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final price =
        double.parse(_priceCtrl.text.replaceAll(',', ''));
    final prop = ListerProperty(
      id: _isEdit
          ? widget.property!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      price: price,
      listingType: _listingType,
      propertyType: _propertyType,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      description: _descCtrl.text.trim(),
      imagePaths: _imagePaths,
      isActive: _isEdit ? widget.property!.isActive : true,
      createdAt: _isEdit ? widget.property!.createdAt : DateTime.now(),
    );

    await ListerService.saveProperty(prop);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context, true);
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
          icon: const Icon(Icons.close_rounded,
              size: 22, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Listing' : 'Add New Listing',
          style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _canSave && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 2))
                : Text('Save',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _canSave ? Colors.black : Colors.grey)),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
        children: [
          // ── Photos ──────────────────────────────────────────────────
          _label('Photos'),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _addPhotoButton(),
                ..._imagePaths.asMap().entries.map((e) =>
                    _imageTile(e.value, e.key)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Type toggles ─────────────────────────────────────────────
          _label('Listing Type'),
          const SizedBox(height: 10),
          _segmented(
            options: const ['shortlet', 'rent'],
            labels: const ['Shortlet', 'For Rent'],
            selected: _listingType,
            onSelect: (v) => setState(() => _listingType = v),
          ),
          const SizedBox(height: 20),
          _label('Property Type'),
          const SizedBox(height: 10),
          _segmented(
            options: const ['apartment', 'house'],
            labels: const ['Apartment', 'House'],
            selected: _propertyType,
            onSelect: (v) => setState(() => _propertyType = v),
          ),
          const SizedBox(height: 24),

          // ── Details ──────────────────────────────────────────────────
          _label('Property Name'),
          const SizedBox(height: 10),
          _field(_nameCtrl, 'e.g. Green Hangout Place'),
          const SizedBox(height: 14),
          _label('Location / Address'),
          const SizedBox(height: 10),
          _field(_locationCtrl, 'e.g. Wuse 2, Abuja'),
          const SizedBox(height: 14),
          _label('City'),
          const SizedBox(height: 10),
          _field(_cityCtrl, 'e.g. Abuja'),
          const SizedBox(height: 14),
          _label(_listingType == 'rent'
              ? 'Monthly Rent (₦)'
              : 'Price per Night (₦)'),
          const SizedBox(height: 10),
          _field(_priceCtrl, '0',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: 24),

          // ── Bedrooms / Bathrooms ──────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Bedrooms'),
                    const SizedBox(height: 10),
                    _stepper(_bedrooms, 1, 10,
                        (v) => setState(() => _bedrooms = v)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Bathrooms'),
                    const SizedBox(height: 10),
                    _stepper(_bathrooms, 1, 10,
                        (v) => setState(() => _bathrooms = v)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Description ───────────────────────────────────────────────
          _label('Description'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _descCtrl,
              maxLines: 5,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Describe the property...',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addPhotoButton() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: 100,
        height: 110,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded,
                size: 28, color: Colors.grey[500]),
            const SizedBox(height: 6),
            Text('Add Photo',
                style: GoogleFonts.inter(
                    fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _imageTile(String path, int index) {
    final isNetwork = path.startsWith('http');
    return Stack(
      children: [
        Container(
          width: 100,
          height: 110,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: isNetwork
                ? Image.network(path,
                    width: 100, height: 110, fit: BoxFit.cover)
                : Image.file(File(path),
                    width: 100, height: 110, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 14,
          child: GestureDetector(
            onTap: () => setState(() => _imagePaths.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 12),
            ),
          ),
        ),
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
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _segmented({
    required List<String> options,
    required List<String> labels,
    required String selected,
    required void Function(String) onSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.asMap().entries.map((e) {
          final isSelected = e.value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(e.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  labels[e.key],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _stepper(int value, int min, int max, void Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed:
                value > min ? () => onChanged(value - 1) : null,
            icon: Icon(Icons.remove_rounded,
                color: value > min ? Colors.black : Colors.grey[300]),
            visualDensity: VisualDensity.compact,
          ),
          Text('$value',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            onPressed:
                value < max ? () => onChanged(value + 1) : null,
            icon: Icon(Icons.add_rounded,
                color: value < max ? Colors.black : Colors.grey[300]),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
