import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ListingPreviewScreen extends StatelessWidget {
  final Uint8List enhancedImageBytes;
  final Map<String, dynamic> listingData;

  const ListingPreviewScreen({
    super.key,
    required this.enhancedImageBytes,
    required this.listingData,
  });

  @override
  Widget build(BuildContext context) {
    final title = listingData['title'] as String? ?? '';
    final descEn = listingData['description_en'] as String? ?? '';
    final descHi = listingData['description_hi'] as String? ?? '';
    final category = listingData['category'] as String? ?? '';
    final material = listingData['material'] as String? ?? '';
    final specs = (listingData['specifications'] as Map<String, dynamic>?) ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Listing Preview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Studio image ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.indigo.withValues(alpha: 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.indigo.withValues(alpha: 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(enhancedImageBytes, fit: BoxFit.contain),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Title ────────────────────────────────────────────────────
            Text(title,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                _Chip(label: category, icon: Icons.category_rounded),
                const SizedBox(width: 8),
                _Chip(label: material, icon: Icons.texture_rounded),
              ],
            ),

            const SizedBox(height: 16),
            _SectionHeader('Description (English)'),
            const SizedBox(height: 6),
            Text(descEn, style: Theme.of(context).textTheme.bodyLarge),

            const SizedBox(height: 16),
            _SectionHeader('विवरण (हिंदी)'),
            const SizedBox(height: 6),
            Text(descHi, style: Theme.of(context).textTheme.bodyLarge),

            if (specs.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader('Specifications'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.indigo.withValues(alpha: 0.10)),
                ),
                child: Column(
                  children: specs.entries.map((e) {
                    final isLast = e.key == specs.keys.last;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _toTitleCase(e.key),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Flexible(
                                child: Text(
                                  e.value.toString(),
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            color: AppColors.indigo.withValues(alpha: 0.08),
                            indent: 16,
                            endIndent: 16,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 28),

            ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded),
              label: const Text('Publish Listing'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.turmeric),
              onPressed: () {
                // TODO: implement publish to backend/marketplace
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit Before Publishing'),
              onPressed: () {
                // TODO: implement inline editing
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _toTitleCase(String s) =>
      s.replaceAll('_', ' ').split(' ').map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      }).join(' ');
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.indigo,
            ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.indigo.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.indigo),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
}
