import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/listing_service.dart';
import '../widgets/publish_flow.dart';

class ListingPreviewScreen extends StatefulWidget {
  final String serverImagePath;           // "userId/uuid.jpg"
  final Map<String, dynamic> listingData; // from voice catalog + price predictor

  const ListingPreviewScreen({
    super.key,
    required this.serverImagePath,
    required this.listingData,
  });

  @override
  State<ListingPreviewScreen> createState() => _ListingPreviewScreenState();
}

class _ListingPreviewScreenState extends State<ListingPreviewScreen> {
  Uint8List? _imageBytes;
  bool _imageLoading = true;
  bool _publishing = false;

  // Editable fields state
  late String _title;
  late String _descEn;
  late String _descHi;
  late String _category;
  late String _material;
  late double _price;
  double? _priceMin;
  double? _priceMax;
  late double _baseCost;
  late double _marketRate;
  late String _advice;
  late Map<String, dynamic> _specs;

  @override
  void initState() {
    super.initState();
    _title = widget.listingData['title'] as String? ?? '';
    _descEn = widget.listingData['description_en'] as String? ?? '';
    _descHi = widget.listingData['description_hi'] as String? ?? '';
    _category = widget.listingData['category'] as String? ?? '';
    _material = widget.listingData['material'] as String? ?? '';

    _price = (widget.listingData['price'] as num?)?.toDouble() ?? 0.0;
    _priceMin = (widget.listingData['price_min'] as num?)?.toDouble();
    _priceMax = (widget.listingData['price_max'] as num?)?.toDouble();
    _baseCost = (widget.listingData['base_cost'] as num?)?.toDouble() ?? 0.0;
    _marketRate = (widget.listingData['market_rate'] as num?)?.toDouble() ?? 0.0;
    _advice = widget.listingData['advice'] as String? ?? '';
    _specs = (widget.listingData['specifications'] as Map<String, dynamic>?) ?? {};

    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await ApiService.fetchImage(widget.serverImagePath);
      if (mounted) setState(() { _imageBytes = bytes; _imageLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _imageLoading = false);
    }
  }

  Future<void> _handlePublish() async {
    await PublishFlow.startPublishFlow(
      context: context,
      productTitle: _title,
      price: _price,
      onConfirmed: (channel, selectedVendor) async {
        setState(() => _publishing = true);
        try {
          final updatedData = {
            ...widget.listingData,
            'title': _title,
            'description_en': _descEn,
            'description_hi': _descHi,
            'category': _category,
            'material': _material,
            'price': _price,
            'price_min': _priceMin,
            'price_max': _priceMax,
            'specifications': _specs,
          };

          final id = await ListingService.createListing(
            imagePath: widget.serverImagePath,
            listingData: updatedData,
          );

          final channelStr = channel == PublishChannel.amazon ? 'amazon' : 'b2b';
          await ListingService.publishListing(
            id,
            channel: channelStr,
            vendorId: selectedVendor?.id,
          );
        } finally {
          if (mounted) setState(() => _publishing = false);
        }
      },
    );

    if (mounted) {
      Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  void _openEditDialog() {
    final titleCtrl = TextEditingController(text: _title);
    final priceCtrl = TextEditingController(text: _price.toStringAsFixed(0));
    final descEnCtrl = TextEditingController(text: _descEn);
    final descHiCtrl = TextEditingController(text: _descHi);
    final catCtrl = TextEditingController(text: _category);
    final matCtrl = TextEditingController(text: _material);

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
                    Text('Edit Product Listing', style: Theme.of(ctx).textTheme.headlineSmall),
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
                  onPressed: () {
                    final newPrice = double.tryParse(priceCtrl.text.trim()) ?? _price;
                    setState(() {
                      _title = titleCtrl.text.trim();
                      _price = newPrice;
                      _descEn = descEnCtrl.text.trim();
                      _descHi = descHiCtrl.text.trim();
                      _category = catCtrl.text.trim();
                      _material = matCtrl.text.trim();
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Listing',
            onPressed: _openEditDialog,
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
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.indigo.withValues(alpha: 0.12)),
                boxShadow: [BoxShadow(
                  color: AppColors.indigo.withValues(alpha: 0.07),
                  blurRadius: 16, offset: const Offset(0, 4),
                )],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _imageLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                        : const Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            // Title & Chips
            Text(_title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Row(children: [
              if (_category.isNotEmpty) _Chip(label: _category, icon: Icons.category_rounded),
              if (_category.isNotEmpty && _material.isNotEmpty) const SizedBox(width: 8),
              if (_material.isNotEmpty) _Chip(label: _material, icon: Icons.texture_rounded),
            ]),

            const SizedBox(height: 20),

            // ── AI Price Recommendation Card ─────────────────────────────
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: AppColors.turmeric, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'AI Price Recommendation',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.indigo,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit Price',
                        onPressed: _openEditDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${_price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.terracotta,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Suggested Selling Price',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (_priceMin != null && _priceMax != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Recommended Range: ₹${_priceMin!.toStringAsFixed(0)} – ₹${_priceMax!.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.indigo.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CostMetric('Base Cost (Mat + Labor)', '₹${_baseCost.toStringAsFixed(0)}'),
                      _CostMetric('Market Average', '₹${_marketRate.toStringAsFixed(0)}'),
                    ],
                  ),
                  if (_advice.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: AppColors.turmeric, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _advice,
                              style: TextStyle(fontSize: 12, color: Colors.grey[800], height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            _SectionHeader('Description (English)'),
            const SizedBox(height: 6),
            Text(_descEn, style: Theme.of(context).textTheme.bodyLarge),

            const SizedBox(height: 16),
            _SectionHeader('विवरण (हिंदी)'),
            const SizedBox(height: 6),
            Text(_descHi, style: Theme.of(context).textTheme.bodyLarge),

            if (_specs.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader('Specifications'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.indigo.withValues(alpha: 0.10)),
                ),
                child: Column(
                  children: _specs.entries.map((e) {
                    final isLast = e.key == _specs.keys.last;
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

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Listing'),
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
                    label: Text(_publishing ? 'Publishing…' : 'Publish Product'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.turmeric),
                    onPressed: _publishing ? null : _handlePublish,
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

class _CostMetric extends StatelessWidget {
  final String label;
  final String value;
  const _CostMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.indigo)),
      ],
    );
  }
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
