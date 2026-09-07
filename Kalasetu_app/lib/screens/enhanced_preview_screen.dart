import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'record_screen.dart';

class EnhancedPreviewScreen extends StatefulWidget {
  final String imagePath; // local file path from camera

  const EnhancedPreviewScreen({super.key, required this.imagePath});

  @override
  State<EnhancedPreviewScreen> createState() => _EnhancedPreviewScreenState();
}

class _EnhancedPreviewScreenState extends State<EnhancedPreviewScreen> {
  bool _isLoading = true;
  Uint8List? _displayBytes;   // bytes for display only
  String? _serverImagePath;   // "userId/uuid.jpg" to pass downstream
  String? _error;

  @override
  void initState() {
    super.initState();
    _enhance();
  }

  Future<void> _enhance() async {
    setState(() { _isLoading = true; _error = null; _displayBytes = null; });
    try {
      // 1. Send to backend, get server path
      final serverPath = await ApiService.enhanceImage(widget.imagePath);
      // 2. Fetch bytes for preview display
      final bytes = await ApiService.fetchImage(serverPath);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _serverImagePath = serverPath;
        _displayBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e is ApiException ? e.message : e.toString();
      });
    }
  }

  void _goToRecord() {
    if (_serverImagePath == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordScreen(
          imagePath: widget.imagePath,
          serverImagePath: _serverImagePath!,
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
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Enhancing your photo…\nThis may take 15–30 seconds.',
                      textAlign: TextAlign.center),
                ]),
              )
            : _error != null
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.terracotta),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                        onPressed: _enhance,
                      ),
                    ]),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.indigo.withValues(alpha: 0.12)),
                            boxShadow: [BoxShadow(
                              color: AppColors.indigo.withValues(alpha: 0.08),
                              blurRadius: 16, offset: const Offset(0, 4),
                            )],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_displayBytes!, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Looking good! Re-enhance or continue.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
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
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                        onPressed: _goToRecord,
                      ),
                    ],
                  ),
      ),
    );
  }
}
