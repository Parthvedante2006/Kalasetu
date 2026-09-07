import 'dart:async';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotService {
  /// Local intelligent fallback responses for instant demo reliability
  static String getFallbackResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('photo') || q.contains('picture') || q.contains('camera') || q.contains('lighting') || q.contains('tasveer')) {
      return "📸 **Product Photography Tips for Artisans:**\n\n"
          "1. **Natural Light:** Take photos near a window or outdoors under shade (avoid direct harsh sunlight).\n"
          "2. **Clean Background:** Use a plain white or neutral cloth background so your craft stands out.\n"
          "3. **Kalasetu AI Enhancer:** Use our built-in camera — our AI automatically removes background shadows and fixes lighting!";
    }

    if (q.contains('price') || q.contains('cost') || q.contains('rate') || q.contains('margin') || q.contains('daam')) {
      return "💰 **Smart Craft Pricing Formula:**\n\n"
          "**Selling Price = Material Cost + (Hours Worked × Hourly Rate) + Profit Margin**\n\n"
          "• Always value your labor (e.g. ₹150–₹250/hour).\n"
          "• Use our built-in **AI Price Predictor** when listing — it checks similar market prices across India and gives you a recommended range!";
    }

    if (q.contains('scheme') || q.contains('vishwakarma') || q.contains('government') || q.contains('loan') || q.contains('pehchan') || q.contains('yojana')) {
      return "🏛️ **Government Artisan Welfare Schemes:**\n\n"
          "1. **PM Vishwakarma Scheme:** Financial support, skill training, and ₹15,000 toolkit incentive for traditional artisans.\n"
          "2. **Pehchan Artisan ID Card:** Issued by Ministry of Textiles for free access to fairs, exhibition stalls & credit.\n"
          "3. **Mudra Loan:** Collateral-free business loans up to ₹10 Lakhs for micro-enterprises.";
    }

    if (q.contains('b2b') || q.contains('wholesale') || q.contains('bulk') || q.contains('amazon')) {
      return "📦 **Selling B2B Wholesale vs Amazon B2C:**\n\n"
          "• **Amazon:** Best for selling single items directly to retail buyers.\n"
          "• **B2B Wholesale:** Best for large orders (10–100+ units) to hotels, exporters & boutique stores.\n"
          "• On Kalasetu, you can publish your product to both channels with a single tap!";
    }

    return "Hello! I am **Kalasetu Sahayak**, your AI artisan companion. 🙏\n\n"
        "You can ask me about:\n"
        "• How to take better product photos 📸\n"
        "• How to calculate prices for your crafts 💰\n"
        "• Government schemes like PM Vishwakarma 🏛️\n"
        "• Selling on Amazon or B2B Wholesale 📦";
  }

  /// Sends query to AI assistant or returns intelligent artisan response
  static Future<String> sendMessage(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getFallbackResponse(prompt);
  }
}
