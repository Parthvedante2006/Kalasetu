import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/listing_service.dart';
import '../widgets/publish_flow.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> listing;

  const ProductDetailScreen({super.key, required this.listing});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Uint8List? _imageBytes;
  bool _imageLoading = true;
  bool _deleting = false;
  bool _publishing = false;

  late Map<String, dynamic> _listingData;

  @override
  void initState() {
    super.initState();
    _listingData = Map<String, dynamic>.from(widget.listing);
    _loadImage();
  }

  Future<void> _loadImage() async {
    final imagePath = _listingData['image_path'] as String?;
    if (imagePath == null) {
      if (mounted) setState(() => _imageLoading = false);
      return;
    }

    try {
      final bytes = await ApiService.fetchImage(imagePath);
      if (mounted) setState(() { _imageBytes = bytes; _imageLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _imageLoading = false);
    }
  }

  Future<void> _handlePublishFlow() async {
    final title = _listingData['title'] as String? ?? 'Product';
    final price = (_listingData['price'] as num?)?.toDouble() ?? 0.0;
    final id = _listingData['id'] as String;

    await PublishFlow.startPublishFlow(
      context: context,
      productTitle: title,
      price: price,
      onConfirmed: (channel, selectedVendor) async {
        setState(() => _publishing = true);
        try {
          final channelStr = channel == PublishChannel.amazon ? 'amazon' : 'b2b';
          await ListingService.publishListing(
            id,
            channel: channelStr,
            vendorId: selectedVendor?.id,
          );
          if (mounted) {
            setState(() {
              _listingData['status'] = 'published';
              _listingData['channel'] = channelStr;
              if (selectedVendor != null) {
                _listingData['vendor_id'] = selectedVendor.id;
              }
            });
          }
        } finally {
          if (mounted) setState(() => _publishing = false);
        }
      },
    );
  }

  void _openEditDialog() {
    final titleCtrl = TextEditingController(text: _listingData['title'] as String? ?? '');
    final priceVal  = (_listingData['price'] as num?)?.toDouble() ?? 0.0;
    final priceCtrl = TextEditingController(text: priceVal > 0 ? priceVal.toStringAsFixed(0) : '');
    final descEnCtrl = TextEditingController(text: _listingData['description_en'] as String? ?? '');
    final descHiCtrl = TextEditingController(text: _listingData['description_hi'] as String? ?? '');
    final catCtrl = TextEditingController(text: _listingData['category'] as String? ?? '');
    final matCtrl = TextEditingController(text: _listingData['material'] as String? ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Product', style: Theme.of(ctx).textTheme.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Selling Price (₹)',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descEnCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description (English)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descHiCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'विवरण (Hindi)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: catCtrl,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: matCtrl,
                        decoration: const InputDecoration(labelText: 'Material', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.turmeric),
                  onPressed: () async {
                    final newPrice = double.tryParse(priceCtrl.text.trim()) ?? priceVal;
                    final updatedFields = {
                      'title': titleCtrl.text.trim(),
                      'price': newPrice,
                      'description_en': descEnCtrl.text.trim(),
                      'description_hi': descHiCtrl.text.trim(),
                      'category': catCtrl.text.trim(),
                      'material': matCtrl.text.trim(),
                    };

                    final id = _listingData['id'] as String;
                    await ListingService.updateListing(id, updatedFields);

                    if (mounted) {
                      setState(() {
                        _listingData.addAll(updatedFields);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product updated!'), backgroundColor: Colors.green),
                      );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteListing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('Are you sure you want to delete this listing? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      final id = _listingData['id'] as String;
      await ListingService.deleteListing(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing deleted'), backgroundColor: Colors.orange),
      );
      Navigator.pop(context, true); // return true to refresh home screen
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title    = _listingData['title'] as String? ?? 'Untitled';
    final descEn   = _listingData['description_en'] as String? ?? '';
    final descHi   = _listingData['description_hi'] as String? ?? '';
    final category = _listingData['category'] as String? ?? '';
    final material = _listingData['material'] as String? ?? '';
    final status   = _listingData['status'] as String? ?? 'draft';
    final channel  = _listingData['channel'] as String? ?? 'amazon';

    final price    = (_listingData['price'] as num?)?.toDouble();
    final priceMin = (_listingData['price_min'] as num?)?.toDouble();
    final priceMax = (_listingData['price_max'] as num?)?.toDouble();

    final specsRaw = _listingData['specifications'];
    final Map<String, dynamic> specs = (specsRaw is Map<String, dynamic>)
        ? specsRaw
        : (specsRaw is Map)
            ? Map<String, dynamic>.from(specsRaw)
            : {};

    final isAmazon = channel == 'amazon';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit product',
            onPressed: _openEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            tooltip: 'Delete product',
            onPressed: _deleting ? null : _deleteListing,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Studio image
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.indigo.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.indigo.withValues(alpha: 0.07),
                    blurRadius: 16, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _imageLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                        : const Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            // Title & Channel Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'published'
                            ? Colors.green.withValues(alpha: 0.15)
                            : AppColors.turmeric.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold,
                          color: status == 'published' ? Colors.green[700] : AppColors.turmeric,
                        ),
                      ),
                    ),
                    if (status == 'published') ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isAmazon ? const Color(0xFFFF9900) : AppColors.indigo).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: (isAmazon ? const Color(0xFFFF9900) : AppColors.indigo).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          isAmazon ? 'AMAZON' : 'B2B',
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w900,
                            color: isAmazon ? const Color(0xFFFF9900) : AppColors.indigo,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Chips
            Row(children: [
              if (category.isNotEmpty) _Chip(label: category, icon: Icons.category_rounded),
              if (category.isNotEmpty && material.isNotEmpty) const SizedBox(width: 8),
              if (material.isNotEmpty) _Chip(label: material, icon: Icons.texture_rounded),
            ]),

            const SizedBox(height: 20),

            // Price Card
            if (price != null && price > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.turmeric.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.turmeric.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selling Price', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.terracotta),
                    ),
                    if (priceMin != null && priceMax != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Market Range: ₹${priceMin.toStringAsFixed(0)} – ₹${priceMax.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.indigo.withValues(alpha: 0.8)),
                      ),
                    ],
                  ],
                ),
              ),

            if (descEn.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionHeader('Description (English)'),
              const SizedBox(height: 6),
              Text(descEn, style: Theme.of(context).textTheme.bodyLarge),
            ],

            if (descHi.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader('विवरण (हिंदी)'),
              const SizedBox(height: 6),
              Text(descHi, style: Theme.of(context).textTheme.bodyLarge),
            ],

            if (specs.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionHeader('Specifications'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.indigo.withValues(alpha: 0.10)),
                ),
                child: Column(
                  children: specs.entries.map((e) {
                    final isLast = e.key == specs.keys.last;
                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_titleCase(e.key),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            Flexible(child: Text(e.value.toString(),
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      if (!isLast) Divider(height: 1,
                          color: AppColors.indigo.withValues(alpha: 0.08),
                          indent: 16, endIndent: 16),
                    ]);
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Action Buttons (Edit + Publish to Channel)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Product'),
                    onPressed: _openEditDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: _publishing
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.rocket_launch_rounded),
                    label: Text(status == 'published' ? 'Re-Publish Channel' : 'Publish Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAmazon && status == 'published'
                          ? const Color(0xFFFF9900)
                          : AppColors.turmeric,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _publishing ? null : _handlePublishFlow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _titleCase(String s) => s.replaceAll('_', ' ').split(' ').map((w) {
    if (w.isEmpty) return w;
    return w[0].toUpperCase() + w.substring(1);
  }).join(' ');
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext ctx) => Text(text,
      style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600, color: AppColors.indigo));
}

class _Chip extends StatelessWidget {
  final String label; final IconData icon;
  const _Chip({required this.label, required this.icon});
  @override
  Widget build(BuildContext ctx) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.indigo.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.indigo),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
          color: AppColors.indigo, fontWeight: FontWeight.w600)),
    ]),
  );
}
