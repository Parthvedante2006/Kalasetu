import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  // ── Change this to your laptop's LAN IP when running on a real device. ──
  // Find it with: ipconfig (Windows) → "IPv4 Address" under your Wi-Fi adapter.
  // For the Android emulator talking to localhost use 'http://10.0.2.2:8000'.
  static const String baseUrl = 'http://10.150.176.203:8000';

  /// Sends [imagePath] to the backend as a multipart POST to /image/enhance.
  /// Returns the enhanced image bytes (JPEG) on success.
  /// Throws an [ApiException] on network or server errors.
  static Future<Uint8List> enhanceImage(String imagePath) async {
    final uri = Uri.parse('$baseUrl/image/enhance');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imagePath),
    );

    http.StreamedResponse response;
    try {
      response = await request.send().timeout(
        const Duration(seconds: 120), // rembg can be slow on first run
        onTimeout: () => throw ApiException('Request timed out. Is the backend running?'),
      );
    } on SocketException {
      throw ApiException('Cannot reach the backend. Check your IP/Wi-Fi connection.');
    }

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else if (response.statusCode == 413) {
      throw ApiException('Image is too large (max 20 MB).');
    } else {
      final body = await response.stream.bytesToString();
      throw ApiException('Server error ${response.statusCode}: $body');
    }
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
