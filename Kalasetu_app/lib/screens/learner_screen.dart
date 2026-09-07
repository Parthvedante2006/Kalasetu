import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LearnerScreen extends StatelessWidget {
  const LearnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artisan Academy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.indigo, AppColors.indigo.withValues(alpha: 0.85)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.turmeric,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('LEARNER HUB', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Master Digital Craft Sales',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Short guides on photography, pricing, digital cataloging & government artisan benefits.',
                        style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.school_rounded, color: AppColors.turmeric, size: 54),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Recommended Learning Modules',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          _ModuleCard(
            title: '📸 Studio Quality Product Photography',
            duration: '3 min read',
            category: 'PHOTOGRAPHY',
            color: Colors.blue,
            description: 'Learn how to position your camera, use natural window lighting, and clean background surfaces to highlight intricate craft details.',
            onTap: () => _showLessonDialog(
              context,
              'Studio Quality Product Photography',
              '1. Light from the Side/Front: Position your pottery or textiles near a well-lit window.\n\n'
                  '2. Plain Background: A neutral white or beige bedsheet works great as a studio backdrop.\n\n'
                  '3. Steady Hands: Keep your phone camera steady and tap to focus on hand-painted details.\n\n'
                  '4. Kalasetu AI Studio: Remember, our built-in image enhancer automatically removes unwanted room clutter and creates studio lighting for you!',
            ),
          ),
          const SizedBox(height: 14),

          _ModuleCard(
            title: '💰 Smart Craft Pricing & Profitability',
            duration: '4 min read',
            category: 'BUSINESS',
            color: Colors.amber[800]!,
            description: 'How to calculate your material expenses, value your craftsmanship hours, and set winning retail and wholesale prices.',
            onTap: () => _showLessonDialog(
              context,
              'Smart Craft Pricing & Profitability',
              '1. Calculate Base Cost:\n'
                  'Base Cost = Material Expenses + (Hours Worked × Hourly Labor Rate)\n\n'
                  '2. Add Profit Margin:\n'
                  'Add 20%–40% profit margin for retail buyers.\n\n'
                  '3. Wholesale Discount:\n'
                  'When selling B2B (10+ units), offer 15%–25% bulk discounts since your production efficiency increases!\n\n'
                  '4. AI Price Recommendation: Use Kalasetu AI Price Predictor in the app to get instant market benchmarks across India.',
            ),
          ),
          const SizedBox(height: 14),

          _ModuleCard(
            title: '🏛️ PM Vishwakarma & Government Schemes',
            duration: '5 min read',
            category: 'GOVT BENEFITS',
            color: const Color(0xFF0F9D58),
            description: 'Unlock ₹15,000 toolkit incentive, collateral-free Mudra credit up to ₹3 Lakhs, and official Pehchan Artisan ID Card benefits.',
            onTap: () => _showLessonDialog(
              context,
              'PM Vishwakarma & Government Schemes',
              '1. PM Vishwakarma Yojana:\n'
                  'Provides ₹15,000 e-voucher for modern tools, basic 5-day skill training with daily stipend, and 5% interest subsidized loans.\n\n'
                  '2. Pehchan Artisan Card:\n'
                  'Official digital identity card issued by the Development Commissioner (Handicrafts). Gives free access to Dilli Haat and national craft expos.\n\n'
                  '3. How to Apply:\n'
                  'Visit your local Common Service Centre (CSC) with your Aadhaar and bank details.',
            ),
          ),
          const SizedBox(height: 14),

          _ModuleCard(
            title: '📦 E-Commerce & B2B Wholesale Basics',
            duration: '3 min read',
            category: 'MARKETPLACE',
            color: Colors.purple,
            description: 'Understanding retail customer shipping vs bulk boutique orders, GST exemptions for traditional artisans, and return policies.',
            onTap: () => _showLessonDialog(
              context,
              'E-Commerce & B2B Wholesale Basics',
              '1. Retail (Amazon/B2C):\n'
                  'Sell single pieces to customers across India. Amazon handles pickup from your home.\n\n'
                  '2. B2B Wholesale:\n'
                  'Sell in bulk to boutiques, hotels & exporters. Higher volume, guaranteed payment, and lower marketing cost.\n\n'
                  '3. Dual Publishing:\n'
                  'Kalasetu lets you list your product on both Amazon retail and B2B wholesale portals with a single tap!',
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLessonDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String duration;
  final String category;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.duration,
    required this.category,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(duration, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}
