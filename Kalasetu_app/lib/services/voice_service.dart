import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class VoiceService {
  /// Sends [audioPath] (.m4a) to the backend /voice/catalog endpoint.
  /// Optionally pass [language] hint ("hi", "mr", "en") for Whisper.
  /// Returns the full parsed JSON map on success.
  /// Throws [ApiException] on network or server errors.
  static Future<Map<String, dynamic>> catalogFromVoice(
    String audioPath, {
    String? language,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/voice/catalog');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', audioPath),
    );
    if (language != null) {
      request.fields['language'] = language;
    }

    http.StreamedResponse response;
    try {
      response = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () =>
            throw ApiException('Voice request timed out. Is the backend running?'),
      );
    } on SocketException {
      throw ApiException('Cannot reach the backend. Check your IP/Wi-Fi connection.');
    }

    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(body) as Map<String, dynamic>;
    } else {
      throw ApiException('Voice catalog failed (${response.statusCode}): $body');
    }
  }
}
