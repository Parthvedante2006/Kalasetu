import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/voice_service.dart';
import 'listing_preview_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final String audioPath;
  final Uint8List enhancedImageBytes;

  const ProcessingScreen({
    super.key,
    required this.imagePath,
    required this.audioPath,
    required this.enhancedImageBytes,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _statusText = 'Transcribing your description...';
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
      _statusText = 'Transcribing your description...';
    });

    try {
      // Step 1: Transcribe + generate listing via Groq
      final listingData = await VoiceService.catalogFromVoice(
        widget.audioPath,
        language: 'hi', // TODO: pass from user-selected language preference
      );

      if (!mounted) return;
      setState(() => _statusText = 'Building your listing...');
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ListingPreviewScreen(
            enhancedImageBytes: widget.enhancedImageBytes,
            listingData: listingData,
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.handloomCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _hasError ? _buildError(context) : _buildProgress(context),
        ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.turmeric,
            strokeWidth: 3,
          ),
          const SizedBox(height: 28),
          Text(
            _statusText,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This may take 10–20 seconds',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 64, color: AppColors.terracotta),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            onPressed: _runPipeline,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            child: const Text('Go Back'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
