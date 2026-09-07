import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'record_screen.dart';

class EnhancedPreviewScreen extends StatefulWidget {
  final String imagePath;

  const EnhancedPreviewScreen({super.key, required this.imagePath});

  @override
  State<EnhancedPreviewScreen> createState() => _EnhancedPreviewScreenState();
}

class _EnhancedPreviewScreenState extends State<EnhancedPreviewScreen> {
  bool _isLoading = true;
  Uint8List? _enhancedBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _enhance();
  }

  Future<void> _enhance() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _enhancedBytes = null;
    });

    try {
      final bytes = await ApiService.enhanceImage(widget.imagePath);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _enhancedBytes = bytes;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    }
  }

  void _goToRecord() {
    if (_enhancedBytes == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordScreen(
          imagePath: widget.imagePath,
          enhancedImageBytes: _enhancedBytes!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enhanced Photo')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Enhancing your photo…\nThis may take 10–30 seconds.',
                        textAlign: TextAlign.center),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 64, color: AppColors.terracotta),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          onPressed: _enhance,
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.indigo.withValues(alpha: 0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.indigo.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                _enhancedBytes!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Looking good! Re-shoot anytime.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Re-enhance'),
                        onPressed: _enhance,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.mic_rounded),
                        label: const Text('Next: Record Description'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                        ),
                        onPressed: _goToRecord,
                      ),
                    ],
                  ),
      ),
    );
  }
}
