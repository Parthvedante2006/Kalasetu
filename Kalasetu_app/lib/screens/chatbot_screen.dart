import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _thinking = false;
  String _selectedLanguage = 'en';

  final List<(String, String)> _languageOptions = const [
    ('en', 'English'),
    ('hi', 'Hindi — हिंदी'),
    ('mr', 'Marathi — मराठी'),
    ('gu', 'Gujarati — ગુજરાતી'),
    ('ta', 'Tamil — தமிழ்'),
  ];

  @override
  void initState() {
    super.initState();
    // Send initial query to backend endpoint to fetch live structured greeting
    _fetchInitialGreeting();
  }

  Future<void> _fetchInitialGreeting() async {
    setState(() => _thinking = true);
    final responseMsg = await ChatbotService.sendMessage(
      'Namaste! Please introduce yourself briefly and explain how you can help me on KalaSetu.',
      responseLanguage: _selectedLanguage,
    );
    if (mounted) {
      setState(() {
        _messages.add(responseMsg);
        _thinking = false;
      });
    }
  }

  void _send(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    _inputCtrl.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _thinking = true;
    });

    final responseMsg = await ChatbotService.sendMessage(
      text,
      responseLanguage: _selectedLanguage,
      chatHistory: _messages,
    );

    if (mounted) {
      setState(() {
        _messages.add(responseMsg);
        _thinking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.turmeric.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.turmeric, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kalasetu Sahayak AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      const Text('FastAPI Endpoint • Groq LLM', style: TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            // Language selector dropdown
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: AppColors.indigo,
                icon: const Icon(Icons.language_rounded, color: Colors.white, size: 20),
                items: _languageOptions.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang.$1,
                    child: Text(
                      lang.$1.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedLanguage = val);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Preset Quick Suggestion Chips (submits query directly to backend endpoint)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: AppColors.handloomCream,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickChip(
                    label: '📸 Photo Tips',
                    onTap: () => _send('How to take studio quality product photos?'),
                  ),
                  _QuickChip(
                    label: '💰 Pricing Guide',
                    onTap: () => _send('How should I price my handcrafted product?'),
                  ),
                  _QuickChip(
                    label: '🏛️ Govt Schemes',
                    onTap: () => _send('What government schemes are available for artisans?'),
                  ),
                  _QuickChip(
                    label: '📦 Sell B2B',
                    onTap: () => _send('How to sell wholesale B2B on KalaSetu?'),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          if (_thinking)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.turmeric),
                  ),
                  const SizedBox(width: 8),
                  Text('Fetching response from endpoint…', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      decoration: InputDecoration(
                        hintText: 'Ask Sahayak AI (${_selectedLanguage.toUpperCase()})…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.handloomCream,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.terracotta,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _send(_inputCtrl.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.indigo.withValues(alpha: 0.2)),
        onPressed: onTap,
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final hour = message.timestamp.hour > 12 ? message.timestamp.hour - 12 : (message.timestamp.hour == 0 ? 12 : message.timestamp.hour);
    final period = message.timestamp.hour >= 12 ? 'PM' : 'AM';
    final minute = message.timestamp.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: message.isError
                  ? Colors.red.withValues(alpha: 0.2)
                  : AppColors.turmeric.withValues(alpha: 0.2),
              radius: 16,
              child: Icon(
                message.isError ? Icons.warning_amber_rounded : Icons.smart_toy_rounded,
                color: message.isError ? Colors.red : AppColors.turmeric,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.indigo
                    : (message.isError ? Colors.red.shade50 : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 2),
                  bottomRight: Radius.circular(isUser ? 2 : 16),
                ),
                border: message.isError
                    ? Border.all(color: Colors.red.shade300)
                    : null,
                boxShadow: [
                  if (!isUser)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Structured text content parser
                  _StructuredText(
                    text: message.text,
                    isUser: isUser,
                    isError: message.isError,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isUser && message.responseLanguage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.indigo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            message.responseLanguage!.toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.indigo),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser ? Colors.white70 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.terracotta.withValues(alpha: 0.2),
              radius: 16,
              child: const Icon(Icons.person_rounded, color: AppColors.terracotta, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _StructuredText extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isError;

  const _StructuredText({
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return Text(
        text,
        style: const TextStyle(color: Colors.red, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
      );
    }

    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Check for bullet list item
      if (line.startsWith('* ') || line.startsWith('- ')) {
        final content = line.substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: isUser ? Colors.white : AppColors.terracotta, fontSize: 14)),
                Expanded(child: _buildRichLine(content, isUser)),
              ],
            ),
          ),
        );
      }
      // Check for numbered list item (e.g., "1. ", "2. ")
      else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        final match = RegExp(r'^(\d+\.)\s*(.*)$').firstMatch(line);
        final numPrefix = match?.group(1) ?? '';
        final content = match?.group(2) ?? '';
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$numPrefix ', style: TextStyle(fontWeight: FontWeight.bold, color: isUser ? Colors.white : AppColors.indigo, fontSize: 13)),
                Expanded(child: _buildRichLine(content, isUser)),
              ],
            ),
          ),
        );
      }
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildRichLine(line, isUser),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget _buildRichLine(String line, bool isUser) {
    final spans = <TextSpan>[];
    final parts = line.split('**');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      final isBold = i % 2 == 1;
      spans.add(
        TextSpan(
          text: parts[i],
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

