import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../theme/app_theme.dart';
import 'enhanced_preview_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  String? _croppedImagePath;
  bool _isProcessing = false;

  Future<void> _captureAndCrop() async {
    setState(() => _isProcessing = true);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (pickedFile == null) {
      setState(() => _isProcessing = false);
      return;
    }

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Product Photo',
          toolbarColor: AppColors.indigo,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.turmeric,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Product Photo',
        ),
      ],
    );

    setState(() {
      _croppedImagePath = croppedFile?.path;
      _isProcessing = false;
    });
  }

  void _proceedToRecord() {
    if (_croppedImagePath == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnhancedPreviewScreen(imagePath: _croppedImagePath!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Photo')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.indigo.withValues(alpha: 0.15)),
                ),
                child: _isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : _croppedImagePath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(_croppedImagePath!), fit: BoxFit.contain),
                )
                    : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_rounded, size: 64, color: AppColors.terracotta),
                      const SizedBox(height: 12),
                      Text(
                        'Take a photo of your product',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(_croppedImagePath == null ? Icons.camera_alt_rounded : Icons.refresh_rounded),
              label: Text(_croppedImagePath == null ? 'Take Photo' : 'Retake Photo'),
              onPressed: _isProcessing ? null : _captureAndCrop,
            ),
            if (_croppedImagePath != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.mic_rounded),
                label: const Text('Next: Record Description'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                onPressed: _proceedToRecord,
              ),
            ],
          ],
        ),
      ),
    );
  }
}