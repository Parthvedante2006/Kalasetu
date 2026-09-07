import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/vendor_service.dart';
import '../../services/listing_service.dart';
import '../../services/api_service.dart';
import '../../widgets/publish_flow.dart';
import '../capture_screen.dart';

class VendorDetailScreen extends StatefulWidget {
  final VendorModel vendor;
  final String? listingId;
  final String? productTitle;
  final double? price;

  const VendorDetailScreen({
    super.key,
    required this.vendor,
    this.listingId,
    this.productTitle,
    this.price,
  });

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  bool _submitting = false;

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'storefront':
        return Icons.storefront_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      default:
        return Icons.business_rounded;
    }
  }

  Future<void> _handleSendProduct() async {
    // ── Entry Point A: Product already selected ──────────────────────────────────
    if (widget.listingId != null) {
      Navigator.pop(context, {
        'vendor': widget.vendor,
        'listingId': widget.listingId,
        'productTitle': widget.productTitle ?? 'Product',
        'price': widget.price ?? 0.0,
      });
      return;
    }

    // ── Entry Point B: No product pre-selected (From Explore) ─────────────────
    final selectedProduct = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _SelectProductSheet(vendorName: widget.vendor.name),
    );

    if (selectedProduct == null || !mounted) return;

    final selectedListingId = selectedProduct['id'] as String;
    final selectedTitle     = selectedProduct['title'] as String? ?? 'Product';
    final selectedPrice     = (selectedProduct['price'] as num?)?.toDouble() ?? 0.0;

    setState(() => _submitting = true);
    try {
      // 1. Submit proposal to vendor in Supabase vendor_submissions table
      await ListingService.submitToVendor(
        listingId: selectedListingId,
        vendorId: widget.vendor.id,
      );

      if (!mounted) return;

      // 2. Play the exact same eye-catching success animation
      await PublishFlow.showSuccessAnimation(
        context: context,
        channel: PublishChannel.b2b,
        productTitle: selectedTitle,
        price: selectedPrice,
        vendor: widget.vendor,
      );

      if (!mounted) return;

      Navigator.pop(context, {
        'vendor': widget.vendor,
        'listingId': selectedListingId,
        'productTitle': selectedTitle,
        'price': selectedPrice,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vendor Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.indigo.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.indigo.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIconData(widget.vendor.logoIcon), color: AppColors.indigo, size: 36),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.vendor.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.vendor.companyType,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.terracotta),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(widget.vendor.location, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      const SizedBox(width: 14),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 2),
                      Text('${widget.vendor.rating}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _SectionHeader('About Vendor Sourcing'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Text(
                widget.vendor.description,
                style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 20),

            _SectionHeader('B2B Procurement Terms'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.indigo.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.indigo.withValues(alpha: 0.12)),
              ),
              child: Column(
                children: [
                  _TermRow('Minimum Order Quantity', widget.vendor.minOrderQty, Icons.format_list_numbered_rounded),
                  const Divider(height: 16),
                  _TermRow('Target Category', widget.vendor.category, Icons.category_rounded),
                  const Divider(height: 16),
                  _TermRow('Preferred Materials', widget.vendor.preferredMaterial, Icons.texture_rounded),
                  const Divider(height: 16),
                  _TermRow('Contact Procurement', widget.vendor.contactEmail, Icons.email_outlined),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Primary Action Button
            ElevatedButton.icon(
              icon: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label: Text(
                _submitting ? 'Sending Proposal…' : 'Send Product to ${widget.vendor.name}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _submitting ? null : _handleSendProduct,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Entry Point B: Product Selection Sheet ─────────────────────────────────
class _SelectProductSheet extends StatefulWidget {
  final String vendorName;
  const _SelectProductSheet({required this.vendorName});

  @override
  State<_SelectProductSheet> createState() => _SelectProductSheetState();
}

class _SelectProductSheetState extends State<_SelectProductSheet> {
  List<Map<String, dynamic>> _myListings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await ListingService.getMyListings();
      if (mounted) setState(() { _myListings = rows; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Select Product for ${widget.vendorName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context, null),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Choose one of your products to submit as a wholesale proposal:',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 16),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _myListings.isEmpty
                    ? _emptyState(context)
                    : ListView.builder(
                        itemCount: _myListings.length,
                        itemBuilder: (ctx, i) {
                          final item = _myListings[i];
                          return _ProductPickerTile(
                            listing: item,
                            onSelect: () => Navigator.pop(context, item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.turmeric.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          const Text('No products available yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          const Text('Create your first product listing to send to B2B buyers.',
              style: TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_a_photo_rounded),
            label: const Text('Add a Product'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context, null);
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CaptureScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _ProductPickerTile extends StatefulWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onSelect;

  const _ProductPickerTile({required this.listing, required this.onSelect});

  @override
  State<_ProductPickerTile> createState() => _ProductPickerTileState();
}

class _ProductPickerTileState extends State<_ProductPickerTile> {
  Uint8List? _imgBytes;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final path = widget.listing['image_path'] as String?;
    if (path == null) return;
    try {
      final bytes = await ApiService.fetchImage(path);
      if (mounted) setState(() => _imgBytes = bytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.listing['title'] as String? ?? 'Untitled';
    final price = (widget.listing['price'] as num?)?.toDouble();
    final cat   = widget.listing['category'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: widget.onSelect,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 50, height: 50,
            child: _imgBytes != null
                ? Image.memory(_imgBytes!, fit: BoxFit.cover)
                : Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(cat, style: const TextStyle(fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (price != null && price > 0)
              Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.terracotta, fontSize: 14)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.indigo),
          ],
        ),
      ),
    );
  }
}

class _TermRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TermRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.indigo),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext ctx) => Text(
        text,
        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.indigo,
            ),
      );
}
