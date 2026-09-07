import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  // Emulator: http://10.0.2.2:8000  |  Real device: your LAN IP
  static const String baseUrl = 'http://10.150.176.203:8000';

  static String? get _token =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  static Map<String, String> get _authHeaders {
    final t = _token;
    return t != null ? {'Authorization': 'Bearer $t'} : {};
  }

  // ── Image enhance ───────────────────────────────────────────────────────

  /// POST /image/enhance — returns server image path e.g. "userId/uuid.jpg"
  static Future<String> enhanceImage(String imagePath) async {
    final uri = Uri.parse('$baseUrl/image/enhance');
    final req = http.MultipartRequest('POST', uri)
      ..headers.addAll(_authHeaders)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    try {
      final res = await req.send().timeout(const Duration(seconds: 120));
      final body = await res.stream.bytesToString();
      if (res.statusCode == 200) {
        return (jsonDecode(body) as Map<String, dynamic>)['image_path'] as String;
      }
      if (res.statusCode == 401) throw ApiException('Not authenticated. Please sign in again.');
      if (res.statusCode == 413) throw ApiException('Image too large (max 20 MB).');
      throw ApiException('Server error ${res.statusCode}: $body');
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException('Cannot reach backend (${e.message}).\nCheck IP: $baseUrl');
    } on TimeoutException {
      throw ApiException('Timed out after 120 s.\nIs the backend running at $baseUrl?');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // ── Image fetch ─────────────────────────────────────────────────────────

  /// GET /image/view/{userId}/{filename} — returns JPEG bytes for Image.memory()
  static Future<Uint8List> fetchImage(String serverImagePath) async {
    final parts = serverImagePath.split('/');
    if (parts.length != 2) throw ApiException('Invalid image path: $serverImagePath');
    final uri = Uri.parse('$baseUrl/image/view/${parts[0]}/${parts[1]}');

    try {
      final res = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return res.bodyBytes;
      if (res.statusCode == 403) throw ApiException('Not authorized to view this image.');
      if (res.statusCode == 404) throw ApiException('Image not found on server.');
      throw ApiException('Fetch failed ${res.statusCode}');
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException('Cannot reach backend (${e.message}).');
    } on TimeoutException {
      throw ApiException('Image fetch timed out.');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}
