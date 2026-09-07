import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PriceService {
  /// Calls POST /price/predict with the transcript, description, material cost, and hours.
  /// Returns the pricing breakdown & advice JSON.
  static Future<Map<String, dynamic>> predictPrice({
    required String transcribedText,
    required String description,
    required double materialCost,
    required double hours,
    String? category,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/price/predict');
    
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'transcribed_text': transcribedText,
              'description': description,
              'material_cost': materialCost,
              'hours': hours,
              'category': category,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return body;
      } else {
        throw ApiException(
            'Price prediction failed (${response.statusCode}): ${body['message'] ?? response.body}');
      }
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException('Cannot reach backend (${e.message}).\nCheck IP: ${ApiService.baseUrl}');
    } on TimeoutException {
      throw ApiException('Price calculation timed out.');
    } catch (e) {
      throw ApiException('Unexpected price error: $e');
    }
  }

  /// Tries to extract numerical material cost and hours from spoken text.
  /// Returns (materialCost, hours) if found, or nulls if missing.
  static (double?, double?) extractCostAndHours(String text) {
    double? cost;
    double? hours;

    // Match numbers near cost words (e.g., 500 rs, cost 500, kharcha 300, 200 rupees)
    final costRegex = RegExp(r'(?:rs\.?|rupees?|kharcha|cost|lagat|material|\u20b9)\s*(\d+(?:\.\d+)?)|(\d+(?:\.\d+)?)\s*(?:rs\.?|rupees?|kharcha|cost|lagat|material|\u20b9)', caseSensitive: false);
    final costMatch = costRegex.firstMatch(text);
    if (costMatch != null) {
      final valStr = costMatch.group(1) ?? costMatch.group(2);
      if (valStr != null) cost = double.tryParse(valStr);
    }

    // Match numbers near hour words (e.g., 4 hours, 3 ghanta, 2.5 hrs)
    final hourRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:hours?|hrs?|ghanta|ghante|time)|(?:hours?|hrs?|ghanta|ghante|time)\s*(\d+(?:\.\d+)?)', caseSensitive: false);
    final hourMatch = hourRegex.firstMatch(text);
    if (hourMatch != null) {
      final valStr = hourMatch.group(1) ?? hourMatch.group(2);
      if (valStr != null) hours = double.tryParse(valStr);
    }

    return (cost, hours);
  }
}
