import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property.dart';
import '../utils/price_formatter.dart';
import 'property_details_screen.dart';

class SeeAllScreen extends StatefulWidget {
  final String title;
  final List<Property> properties;
  final bool searchMode;

  const SeeAllScreen({
    super.key,
    required this.title,
    required this.properties,
    this.searchMode = false,
  });

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  String _filter = 'All';
  bool _isGrid = true;
  String _query = '';
  late final TextEditingController _searchCtrl;
  late final FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchFocus = FocusNode();
    if (widget.searchMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Property> get _filtered {
    List<Property> list;
    switch (_filter) {
      case 'Shortlet':
        list = widget.properties.where((p) => p.listingType == 'shortlet').toList();
        break;
      case 'For Rent':
        list = widget.properties.where((p) => p.listingType == 'rent').toList();
        break;
      case 'Houses':
        list = widget.properties.where((p) => p.propertyType == 'house').toList();
        break;
      case 'Apartments':
        list = widget.properties.where((p) => p.propertyType == 'apartment').toList();
        break;
      default:
        list = widget.properties;
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.location.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Collapsing header — hides on scroll, snaps back on scroll up
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              elevation: 0,
              backgroundColor: const Color(0xFFF8F9FA),
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              toolbarHeight: 60,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isGrid = !_isGrid),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                        ),
                        child: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(widget.searchMode ? 108 : 52),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.searchMode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: Colors.grey[500], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  focusNode: _searchFocus,
                                  onChanged: (v) => setState(() => _query = v),
                                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'Search by name or location...',
                                    hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              if (_query.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                  child: Icon(Icons.close_rounded, size: 18, color: Colors.grey[500]),
                                ),
                            ],
                          ),
                        ),
                      ),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          for (final f in ['All', 'Shortlet', 'For Rent', 'Houses', 'Apartments'])
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () => setState(() => _filter = f),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _filter == f ? Colors.black : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: _filter == f
                                        ? []
                                        : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                                  ),
                                  child: Text(
                                    f,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _filter == f ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Count label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  '${filtered.length} ${filtered.length == 1 ? 'property' : 'properties'}',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                ),
              ),
            ),

            // Empty state
            if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No properties found', style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[500])),
                    ],
                  ),
                ),
              )
            else if (_isGrid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildGridCard(filtered[index]),
                    childCount: filtered.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildListCard(filtered[index]),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(Property property) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    property.imageUrl,
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 130, color: Colors.grey[200], child: const Icon(Icons.home, color: Colors.grey)),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: property.listingType == 'rent' ? const Color(0xFF1A6B4A) : Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        property.listingType == 'rent' ? 'Rent' : 'Shortlet',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 11, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${property.rating}', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 11, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Expanded(child: Text(property.location, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      property.listingType == 'rent'
                          ? PriceFormatter.formatNairaPerMonth(property.price)
                          : PriceFormatter.formatNairaPerNight(property.price),
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bed_rounded, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text('${property.bedrooms}', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
                        const SizedBox(width: 8),
                        Icon(Icons.bathtub_rounded, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text('${property.bathrooms}', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(Property property) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
              child: Image.network(
                property.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 110, height: 110, color: Colors.grey[200], child: const Icon(Icons.home, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: property.listingType == 'rent' ? const Color(0xFF1A6B4A).withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        property.listingType == 'rent' ? 'For Rent' : 'Shortlet',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: property.listingType == 'rent' ? const Color(0xFF1A6B4A) : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(property.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(Icons.location_on_rounded, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Expanded(child: Text(property.location, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          property.listingType == 'rent'
                              ? PriceFormatter.formatNairaPerMonth(property.price)
                              : PriceFormatter.formatNairaPerNight(property.price),
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Row(children: [
                          const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${property.rating}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700])),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
