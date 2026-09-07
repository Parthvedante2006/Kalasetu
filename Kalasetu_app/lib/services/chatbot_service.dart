import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? responseLanguage;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.responseLanguage,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotService {
  /// Calls POST /chatbot/chat on the FastAPI backend with message, language, and chat history.
  /// Returns a [ChatMessage] constructed directly from the backend endpoint JSON response.
  static Future<ChatMessage> sendMessage(
    String prompt, {
    String responseLanguage = 'en',
    List<ChatMessage>? chatHistory,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/chatbot/chat');

    // Build chat history payload for Groq LLM context
    final List<Map<String, String>> historyPayload = [];
    if (chatHistory != null) {
      final recent = chatHistory.where((m) => m.text.isNotEmpty).take(10);
      for (final msg in recent) {
        historyPayload.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }
    }

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': prompt,
              'response_language': responseLanguage,
              'history': historyPayload,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = data['reply'] as String? ?? 'No content returned from server.';
        final lang = data['response_language'] as String? ?? responseLanguage;
        final isErr = data['is_error'] as bool? ?? false;

        return ChatMessage(
          text: reply,
          isUser: false,
          responseLanguage: lang,
          isError: isErr,
        );
      } else {
        return ChatMessage(
          text: 'HTTP Error ${response.statusCode}: ${response.body}',
          isUser: false,
          isError: true,
        );
      }
    } on SocketException catch (e) {
      return ChatMessage(
        text: 'Network Error: Cannot connect to backend endpoint (${e.message})',
        isUser: false,
        isError: true,
      );
    } on TimeoutException {
      return ChatMessage(
        text: 'Timeout Error: Backend endpoint did not respond within 30 seconds.',
        isUser: false,
        isError: true,
      );
    } catch (e) {
      return ChatMessage(
        text: 'Unexpected Error: ${e.toString()}',
        isUser: false,
        isError: true,
      );
    }
  }
}
