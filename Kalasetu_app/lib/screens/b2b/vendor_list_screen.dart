import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/vendor_service.dart';
import 'vendor_detail_screen.dart';

class VendorListScreen extends StatefulWidget {
  final String? listingId;
  final String? productTitle;
  final double? price;

  const VendorListScreen({
    super.key,
    this.listingId,
    this.productTitle,
    this.price,
  });

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  List<VendorModel> _vendors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    final list = await VendorService.getVendors();
    if (mounted) {
      setState(() {
        _vendors = list;
        _loading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B Buyer Directory'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.indigo.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.indigo.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.storefront_rounded, color: AppColors.indigo, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'B2B Wholesale Partners',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.indigo,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.listingId != null
                                  ? 'Select a buyer to submit "${widget.productTitle}"'
                                  : 'Explore verified buyers looking to source authentic artisan products.',
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Verified Buyers (${_vendors.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._vendors.map((vendor) => _VendorCard(
                      vendor: vendor,
                      iconData: _getIconData(vendor.logoIcon),
                      onTap: () async {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VendorDetailScreen(
                              vendor: vendor,
                              listingId: widget.listingId,
                              productTitle: widget.productTitle,
                              price: widget.price,
                            ),
                          ),
                        );

                        if (result != null && context.mounted) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context, result);
                          }
                        }
                      },
                    )),
              ],
            ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final VendorModel vendor;
  final IconData iconData;
  final VoidCallback onTap;

  const _VendorCard({
    required this.vendor,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.indigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: AppColors.indigo, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            vendor.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              vendor.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vendor.companyType,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.terracotta),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.category_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vendor.category,
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          vendor.location,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.turmeric.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'MOQ: ${vendor.minOrderQty}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.indigo),
                          ),
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
