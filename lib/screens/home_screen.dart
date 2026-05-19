import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property.dart';
import '../services/apartment_service.dart';
import '../services/auth_service.dart';
import 'property_details_screen.dart';
import 'see_all_screen.dart';
import '../widgets/pill_navigation_bar.dart';
import 'favorites_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import '../utils/price_formatter.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Property> _properties = [];
  String _selectedListingType = 'All';
  String? _selectedCity;
  bool _isLoading = true;
  String _userName = 'User';
  String _userPicture = 'https://i.pravatar.cc/150?img=1';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchProperties();
  }

  Future<void> _loadUserInfo() async {
    final name = await AuthService.getUserName();
    final picture = await AuthService.getUserPicture();
    if (mounted) setState(() { _userName = name; _userPicture = picture; });
  }

  Future<void> _fetchProperties({String? city}) async {
    setState(() { _isLoading = true; _selectedCity = city; });
    try {
      final results = await ApartmentService.fetchApartments(city: city);
      if (mounted) setState(() { _properties = results; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _properties = PropertyData.getAllProperties(); _isLoading = false; });
    }
  }

  List<Property> get _filteredProperties {
    switch (_selectedListingType) {
      case 'Shortlet':
        return _properties.where((p) => p.listingType == 'shortlet').toList();
      case 'For Rent':
        return _properties.where((p) => p.listingType == 'rent').toList();
      case 'Houses':
        return _properties.where((p) => p.propertyType == 'house').toList();
      default:
        return _properties;
    }
  }

  List<Property> get _featuredProperties =>
      _properties.where((p) => p.rating >= 4.7).take(6).toList();

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  void _goToSeeAll(String title, List<Property> props) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SeeAllScreen(title: title, properties: props)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Collapsing header — hides on scroll down, returns on scroll up
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: const Color(0xFFF8F9FA),
            toolbarHeight: 72,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildHeaderRow(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(62),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: _buildSearchBar(),
              ),
            ),
          ),

          // City + listing type filters
          SliverToBoxAdapter(child: _buildFilters()),

          // Featured section
          if (!_isLoading && _featuredProperties.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Featured',
                onSeeAll: () => _goToSeeAll('Featured Properties', _featuredProperties),
              ),
            ),
            SliverToBoxAdapter(child: _buildFeaturedCarousel()),
          ],

          // All properties section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              _selectedListingType == 'All' ? 'All Properties' : _selectedListingType,
              onSeeAll: () => _goToSeeAll(
                _selectedListingType == 'All' ? 'All Properties' : _selectedListingType,
                _filteredProperties,
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_filteredProperties.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPropertyCard(_filteredProperties[index]),
                  childCount: _filteredProperties.length,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: PillNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!, width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(_userPicture),
                onBackgroundImageError: (_, __) {},
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello,', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                Text(_userName, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 22),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeeAllScreen(
            title: 'Search Properties',
            properties: _properties,
            searchMode: true,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search properties on Rosera...',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(9)),
              child: Icon(Icons.tune_rounded, size: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // City chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildChip('All Nigeria', _selectedCity == null, onTap: () => _fetchProperties()),
              const SizedBox(width: 10),
              _buildChip('Abuja', _selectedCity == 'Abuja', onTap: () => _fetchProperties(city: 'Abuja')),
              const SizedBox(width: 10),
              _buildChip('Lagos', _selectedCity == 'Lagos', onTap: () => _fetchProperties(city: 'Lagos')),
              const SizedBox(width: 10),
              _buildChip('Port Harcourt', _selectedCity == 'Port Harcourt', onTap: () => _fetchProperties(city: 'Port Harcourt')),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Listing type tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildTypeTab('All', Icons.apps_rounded),
              const SizedBox(width: 10),
              _buildTypeTab('Shortlet', Icons.hotel_rounded),
              const SizedBox(width: 10),
              _buildTypeTab('For Rent', Icons.calendar_month_rounded),
              const SizedBox(width: 10),
              _buildTypeTab('Houses', Icons.house_rounded),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, IconData icon) {
    final isSelected = _selectedListingType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedListingType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          TextButton(
            onPressed: onSeeAll,
            child: Text('See all', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return SizedBox(
      height: 270,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24, right: 8, bottom: 12),
        itemCount: _featuredProperties.length,
        itemBuilder: (context, index) {
          final p = _featuredProperties[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: p))),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      p.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.home, size: 60, color: Colors.grey)),
                    ),
                    // Gradient
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                    // Type badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: p.listingType == 'rent' ? const Color(0xFF1A6B4A) : Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.listingType == 'rent' ? 'For Rent' : 'Shortlet',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                        child: const Icon(Icons.favorite_border_rounded, size: 16, color: Colors.black87),
                      ),
                    ),
                    // Info overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              p.name,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 11, color: Colors.white70),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    p.location,
                                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  p.listingType == 'rent'
                                      ? PriceFormatter.formatNairaPerMonth(p.price)
                                      : PriceFormatter.formatNairaPerNight(p.price),
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text('${p.rating}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No properties found', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _fetchProperties,
            child: Text('Retry', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    property.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 220,
                      color: Colors.grey[200],
                      child: const Icon(Icons.home, size: 60, color: Colors.grey),
                    ),
                  ),
                  // Type badge
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: property.listingType == 'rent' ? const Color(0xFF1A6B4A) : Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            property.propertyType == 'house' ? Icons.house_rounded : Icons.apartment_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            property.listingType == 'rent' ? 'For Rent' : 'Shortlet',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                      ),
                      child: const Icon(Icons.favorite_border_rounded, size: 18, color: Colors.black87),
                    ),
                  ),
                  // Rating badge
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${property.rating}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 15, color: Colors.grey[600]),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            property.location,
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          property.listingType == 'rent'
                              ? PriceFormatter.formatNairaPerMonth(property.price)
                              : PriceFormatter.formatNairaPerNight(property.price),
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Row(
                          children: [
                            Icon(Icons.bed_rounded, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${property.bedrooms}', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700])),
                            const SizedBox(width: 12),
                            Icon(Icons.bathtub_rounded, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${property.bathrooms}', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700])),
                          ],
                        ),
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
}
