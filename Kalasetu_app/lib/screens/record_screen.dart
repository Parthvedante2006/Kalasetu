import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';
import 'processing_screen.dart';

class RecordScreen extends StatefulWidget {
  final String imagePath;
  final Uint8List enhancedImageBytes;

  const RecordScreen({
    super.key,
    required this.imagePath,
    required this.enhancedImageBytes,
  });

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasRecording = false;
  String? _audioPath;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) return;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/product_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _hasRecording = false;
      _audioPath = path;
      _startTime = DateTime.now();
      _elapsed = Duration.zero;
    });

    _tickTimer();
  }

  void _tickTimer() async {
    while (_isRecording) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted || !_isRecording) break;
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _hasRecording = path != null;
      _audioPath = path ?? _audioPath;
    });
  }

  void _proceedToProcessing() {
    if (_audioPath == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          imagePath: widget.imagePath,
          audioPath: _audioPath!,
          enhancedImageBytes: widget.enhancedImageBytes,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Describe Your Product')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRecording ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                      size: 96,
                      color: _isRecording ? AppColors.terracotta : AppColors.turmeric,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isRecording
                          ? 'Recording... ${_formatDuration(_elapsed)}'
                          : _hasRecording
                          ? 'Recording ready (${_formatDuration(_elapsed)})'
                          : 'Speak about your product\nin your own language',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? AppColors.terracotta : AppColors.turmeric,
                ),
                child: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isRecording ? 'Tap to stop' : 'Tap to record',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            if (_hasRecording && !_isRecording)
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Next: Review Listing'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                onPressed: _proceedToProcessing,
              ),
          ],
        ),
      ),
    );
  }
}