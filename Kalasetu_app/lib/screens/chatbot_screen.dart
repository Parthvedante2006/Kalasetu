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
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Namaste! 🙏 I am **Kalasetu Sahayak**, your personal AI companion for craft selling, photography, and pricing advice. How can I help you today?",
      isUser: false,
    ),
  ];
  bool _thinking = false;

  void _send(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    _inputCtrl.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _thinking = true;
    });

    final reply = await ChatbotService.sendMessage(text);

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false));
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
            Column(
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
                    const Text('Online • Artisan Assistant', style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Preset Quick Suggestion Chips
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
                    onTap: () => _send('How to sell wholesale B2B?'),
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
                  Text('Sahayak is thinking…', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                        hintText: 'Ask Sahayak AI (English / हिंदी)…',
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppColors.turmeric.withValues(alpha: 0.2),
              radius: 16,
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.turmeric, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.indigo : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 2),
                  bottomRight: Radius.circular(isUser ? 2 : 16),
                ),
                boxShadow: [
                  if (!isUser)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isUser ? Colors.white : Colors.black87,
                ),
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
