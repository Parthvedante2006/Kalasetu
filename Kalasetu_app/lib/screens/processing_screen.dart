import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/voice_service.dart';
import '../services/price_service.dart';
import 'listing_preview_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final String serverImagePath; // "userId/uuid.jpg"
  final String audioPath;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
    required this.serverImagePath,
    required this.audioPath,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _status = 'Understanding your description…';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _runPipeline();
  }

  Future<void> _runPipeline() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _status = 'Understanding your description…';
    });

    try {
      // Step 1: Voice transcription + AI product cataloging
      final catalogData = await VoiceService.catalogFromVoice(
        widget.audioPath,
        language: 'hi',
      );

      final transcription = catalogData['transcription'] as String? ?? '';
      final descriptionEn = catalogData['description_en'] as String? ?? '';
      final category = catalogData['category'] as String?;

      // Step 2: Check for cost & hours in spoken description
      var (extractedCost, extractedHours) = PriceService.extractCostAndHours(transcription);

      double finalCost = extractedCost ?? 0.0;
      double finalHours = extractedHours ?? 0.0;

      // If cost or hours were missing, prompt the user for input
      if (finalCost <= 0 || finalHours <= 0) {
        if (!mounted) return;
        final inputResult = await _promptForCostAndHours(
          initialCost: finalCost > 0 ? finalCost : null,
          initialHours: finalHours > 0 ? finalHours : null,
        );

        if (inputResult == null) {
          // User cancelled prompt
          setState(() {
            _hasError = true;
            _errorMessage = 'Material cost & working hours are required for price prediction.';
          });
          return;
        }

        finalCost = inputResult.$1;
        finalHours = inputResult.$2;
      }

      if (!mounted) return;
      setState(() => _status = 'Calculating AI price recommendation…');

      // Step 3: Call Price Predictor API
      final priceResult = await PriceService.predictPrice(
        transcribedText: transcription,
        description: descriptionEn.isNotEmpty ? descriptionEn : transcription,
        materialCost: finalCost,
        hours: finalHours,
        category: category,
      );

      // Step 4: Merge catalog + price recommendation into listingData
      final Map<String, dynamic> fullListingData = {
        ...catalogData,
        'material_cost': finalCost,
        'hours': finalHours,
        'base_cost': priceResult['base_cost'] ?? (finalCost + finalHours * 150),
        'market_rate': priceResult['market_rate'] ?? 0.0,
        'price': (priceResult['optimal_price'] as num?)?.toDouble() ??
                 (priceResult['base_cost'] as num?)?.toDouble() ??
                 (finalCost + finalHours * 150),
        'price_min': (priceResult['min_price'] as num?)?.toDouble(),
        'price_max': (priceResult['max_price'] as num?)?.toDouble(),
        'advice': priceResult['advice'] as String? ?? '',
        'similar_products': priceResult['similar_products'] ?? [],
      };

      if (!mounted) return;
      setState(() => _status = 'Building your listing…');
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ListingPreviewScreen(
            serverImagePath: widget.serverImagePath,
            listingData: fullListingData,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// Dialog prompt to collect Material Cost and Working Hours if missing
  Future<(double, double)?> _promptForCostAndHours({
    double? initialCost,
    double? initialHours,
  }) async {
    final costCtrl = TextEditingController(
        text: initialCost != null && initialCost > 0 ? initialCost.toStringAsFixed(0) : '');
    final hoursCtrl = TextEditingController(
        text: initialHours != null && initialHours > 0 ? initialHours.toStringAsFixed(1) : '');
    String? dialogError;

    return showDialog<(double, double)>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.monetization_on_rounded, color: AppColors.turmeric),
                  const SizedBox(width: 8),
                  const Text('Production Cost Details'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We couldn\'t find cost details in your voice note. Please specify:',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Material Cost (₹)',
                      hintText: 'e.g. 350',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: hoursCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Time Spent (Hours)',
                      hintText: 'e.g. 4',
                      suffixText: 'hrs',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(dialogError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                  onPressed: () {
                    final c = double.tryParse(costCtrl.text.trim());
                    final h = double.tryParse(hoursCtrl.text.trim());

                    if (c == null || c <= 0) {
                      setDialogState(() => dialogError = 'Please enter valid material cost (₹)');
                      return;
                    }
                    if (h == null || h <= 0) {
                      setDialogState(() => dialogError = 'Please enter valid hours worked');
                      return;
                    }

                    Navigator.pop(context, (c, h));
                  },
                  child: const Text('Calculate Price'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.handloomCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _hasError ? _error(context) : _progress(context),
        ),
      ),
    );
  }

  Widget _progress(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: AppColors.turmeric, strokeWidth: 3),
          const SizedBox(height: 28),
          Text(_status, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('This may take 10–20 seconds',
              style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ]),
      );

  Widget _error(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, size: 64, color: AppColors.terracotta),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Something went wrong.',
              style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            onPressed: _runPipeline,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
        ]),
      );
}
