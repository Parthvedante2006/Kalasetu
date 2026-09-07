import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/listing_service.dart';
import '../services/api_service.dart';
import 'capture_screen.dart';
import 'product_detail_screen.dart';
import 'b2b/vendor_list_screen.dart';
import 'learner_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _loading = true);
    try {
      final rows = await ListingService.getMyListings();
      if (mounted) setState(() { _listings = rows; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  void _startAddNewProductFlow() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CaptureScreen()),
    );
    _loadListings();
  }

  void _openChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatbotScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tab 0: Home / My Listings
          _HomeListingsTab(
            listings: _listings,
            loading: _loading,
            onRefresh: _loadListings,
            onSignOut: _signOut,
          ),
          // Tab 1: Explore B2B (Entry Point B)
          VendorListScreen(
            listingId: null,
            productTitle: null,
            price: null,
          ),
          // Tab 2: Learner Hub
          const LearnerScreen(),
          // Tab 3: Artisan Profile
          const ProfileScreen(),
        ],
      ),

      // ── New Floating AI Chatbot Assistant Button ──────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'sahayak_ai_fab',
        backgroundColor: AppColors.turmeric,
        elevation: 6,
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Sahayak AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        onPressed: _openChatbot,
      ),

      // ── Prominent Bottom Navigation Bar with Raised Center Add Button ─────
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.handloomCream,
              border: Border(
                top: BorderSide(
                  color: AppColors.indigo.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warmCharcoal.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Tab 0: Home
                    _NavItem(
                      icon: Icons.grid_view_rounded,
                      label: 'Home',
                      isSelected: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),

                    // Tab 1: Explore B2B
                    _NavItem(
                      icon: Icons.storefront_rounded,
                      label: 'Explore',
                      isSelected: _currentIndex == 1,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),

                    // Placeholder spacing for raised center button
                    const SizedBox(width: 48),

                    // Tab 2: Learner Hub
                    _NavItem(
                      icon: Icons.school_rounded,
                      label: 'Learner',
                      isSelected: _currentIndex == 2,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),

                    // Tab 3: Profile
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      isSelected: _currentIndex == 3,
                      onTap: () => setState(() => _currentIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Elevated Primary "Add New" Action Button ─────────────────────
          Positioned(
            top: -18,
            child: GestureDetector(
              onTap: _startAddNewProductFlow,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.terracotta, AppColors.turmeric],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.terracotta.withValues(alpha: 0.45),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.handloomCream, width: 3),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Add New',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.terracotta,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.indigo;
    final inactiveColor = AppColors.warmCharcoal.withValues(alpha: 0.55);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
          color: AppColors.indigo.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab 0: Home / My Listings Screen View ───────────────────────────────────
class _HomeListingsTab extends StatelessWidget {
  final List<Map<String, dynamic>> listings;
  final bool loading;
  final Future<void> Function() onRefresh;
  final VoidCallback onSignOut;

  const _HomeListingsTab({
    required this.listings,
    required this.loading,
    required this.onRefresh,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalasetu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: onSignOut,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : listings.isEmpty
            ? _emptyState(context)
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: listings.length,
          itemBuilder: (ctx, i) => _ListingCard(
            listing: listings[i],
            onRefreshNeeded: onRefresh,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inventory_2_outlined, size: 72, color: AppColors.turmeric.withValues(alpha: 0.6)),
      const SizedBox(height: 16),
      Text('No listings yet', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text('Tap "+ Add New" below to add your first product',
          style: Theme.of(context).textTheme.bodyLarge),
    ]),
  );
}

class _ListingCard extends StatefulWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onRefreshNeeded;

  const _ListingCard({
    required this.listing,
    required this.onRefreshNeeded,
  });

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    final path = widget.listing['image_path'] as String?;
    if (path == null) return;
    try {
      final bytes = await ApiService.fetchImage(path);
      if (mounted) setState(() => _imageBytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title    = widget.listing['title'] as String? ?? 'Untitled';
    final category = widget.listing['category'] as String? ?? '';
    final status   = widget.listing['status'] as String? ?? 'published';
    final price    = (widget.listing['price'] as num?)?.toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(listing: widget.listing),
            ),
          );
          if (result == true) {
            widget.onRefreshNeeded();
          }
        },
        child: Row(children: [
          SizedBox(
            width: 100,
            height: 100,
            child: _imageBytes != null
                ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                : Container(
              color: AppColors.handloomCream,
              child: Icon(Icons.image_rounded, color: AppColors.indigo.withValues(alpha: 0.3)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (category.isNotEmpty) ...[
                        Text(category, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: status == 'published'
                              ? Colors.green.withValues(alpha: 0.15)
                              : AppColors.turmeric.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: status == 'published' ? Colors.green[700] : AppColors.turmeric,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (price != null && price > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          const SizedBox(width: 12),
        ]),
      ),
    );
  }
}