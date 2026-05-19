import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property.dart';
import '../utils/price_formatter.dart';
import '../widgets/report_sheet.dart';
import '../services/favorites_service.dart';
import 'chat_screen.dart';
import 'rental_request_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    FavoritesService.isFavorite(widget.property.id).then((v) {
      if (mounted) setState(() => _isFavorited = v);
    });
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.toggle(widget.property.id);
    if (mounted) setState(() => _isFavorited = !_isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Scrollable content
            CustomScrollView(
              slivers: [
                // Hero image — extends behind status bar
                SliverAppBar(
                  expandedHeight: 380,
                  pinned: false,
                  floating: false,
                  snap: false,
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.property.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.home, size: 80, color: Colors.grey),
                          ),
                        ),
                        // Bottom gradient so content bleeds nicely
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.15),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Photo count badge
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.photo_library_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text('12 photos', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        // Type badge
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: widget.property.listingType == 'rent' ? const Color(0xFF1A6B4A) : Colors.black87,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.property.propertyType == 'house' ? Icons.house_rounded : Icons.apartment_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.property.listingType == 'rent' ? 'For Rent' : 'Shortlet',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content card — rounded top corners overlap the image
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -28),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + favorite
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.property.name,
                                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: _toggleFavorite,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                                    ),
                                    child: Icon(
                                      _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      size: 22,
                                      color: _isFavorited ? Colors.red : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Location + rating
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(widget.property.location, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700])),
                                ),
                                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.property.rating}',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  PriceFormatter.formatNaira(widget.property.price),
                                  style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    widget.property.listingType == 'rent' ? '/ month' : '/ night',
                                    style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Feature chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _featureChip(Icons.bed_rounded, '${widget.property.bedrooms} Beds'),
                                  const SizedBox(width: 10),
                                  _featureChip(Icons.bathtub_rounded, '${widget.property.bathrooms} Baths'),
                                  const SizedBox(width: 10),
                                  _featureChip(Icons.square_foot_rounded, widget.property.propertyArea),
                                  const SizedBox(width: 10),
                                  _featureChip(Icons.videocam_rounded, '${widget.property.cctv} CCTV'),
                                  const SizedBox(width: 10),
                                  _featureChip(Icons.local_parking_rounded, '${widget.property.parkingSpots} Parking'),
                                  const SizedBox(width: 10),
                                  _featureChip(Icons.calendar_today_rounded, 'Built ${widget.property.year}'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // About
                            Text('About this property', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 10),
                            Text(
                              widget.property.description,
                              style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[700], height: 1.6),
                            ),
                            const SizedBox(height: 28),

                            // Amenities
                            Text('Amenities', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _amenityChip(Icons.wifi_rounded, 'Free WiFi'),
                                _amenityChip(Icons.ac_unit_rounded, 'Air Conditioning'),
                                _amenityChip(Icons.local_laundry_service_rounded, 'Laundry'),
                                _amenityChip(Icons.kitchen_rounded, 'Kitchen'),
                                _amenityChip(Icons.pool_rounded, 'Swimming Pool'),
                                _amenityChip(Icons.security_rounded, '24/7 Security'),
                                _amenityChip(Icons.bolt_rounded, 'Generator'),
                                _amenityChip(Icons.water_drop_rounded, 'Running Water'),
                              ],
                            ),

                            // Report link
                            const SizedBox(height: 32),
                            Center(
                              child: GestureDetector(
                                onTap: () => ReportSheet.show(
                                  context: context,
                                  propertyId: widget.property.id,
                                  propertyName: widget.property.name,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.flag_outlined,
                                        size: 14, color: Colors.grey[500]),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Report this listing',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey[500],
                                          decoration:
                                              TextDecoration.underline,
                                          decorationColor:
                                              Colors.grey[400]),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Space for bottom bar
                            const SizedBox(height: 180),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating back + share buttons over the image
            Positioned(
              top: topPad + 8,
              left: 20,
              child: _floatingButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: topPad + 8,
              right: 20,
              child: _floatingButton(
                icon: Icons.share_rounded,
                onTap: () {},
              ),
            ),

            // Pinned bottom bar — agent + book button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, -4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Agent row
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(widget.property.agent.imageUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.property.agent.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
                                Text(widget.property.agent.email, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  conversationId:
                                      ChatScreen.demoConversationId,
                                  agentName: widget.property.agent.name,
                                  agentAvatar:
                                      widget.property.agent.imageUrl,
                                  propertyName: widget.property.name,
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(11)),
                              child: const Icon(Icons.message_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Book button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RentalRequestScreen(
                                property: widget.property),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.property.listingType == 'rent' ? 'Request to Rent' : 'Book Now',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
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

  Widget _floatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _amenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}
