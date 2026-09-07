import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/vendor_service.dart';
import '../screens/b2b/vendor_list_screen.dart';

enum PublishChannel { amazon, b2b }

class PublishFlow {
  /// Opens channel selector -> (Amazon onboarding OR B2B vendor selection) -> plays success animation -> calls [onConfirmed]
  static Future<void> startPublishFlow({
    required BuildContext context,
    required String productTitle,
    required double price,
    required Future<void> Function(PublishChannel channel, VendorModel? selectedVendor) onConfirmed,
  }) async {
    // Step 1: Channel Selector
    final channel = await showModalBottomSheet<PublishChannel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _ChannelSelectorSheet(),
    );

    if (channel == null || !context.mounted) return;

    VendorModel? selectedVendor;

    if (channel == PublishChannel.amazon) {
      // Step 2a: Amazon Onboarding Questions
      final onboardingDone = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _OnboardingDialog(channel: channel),
      );

      if (onboardingDone != true || !context.mounted) return;
    } else {
      // Step 2b: B2B Vendor Selection Flow
      selectedVendor = await Navigator.push<VendorModel>(
        context,
        MaterialPageRoute(
          builder: (_) => VendorListScreen(
            productTitle: productTitle,
            price: price,
          ),
        ),
      );

      if (selectedVendor == null || !context.mounted) return;
    }

    // Step 3: Execute backend publish callback
    await onConfirmed(channel, selectedVendor);

    if (!context.mounted) return;

    // Step 4: Eye-Catching Success Animation Modal
    await showSuccessAnimation(
      context: context,
      channel: channel,
      productTitle: productTitle,
      price: price,
      vendor: selectedVendor,
    );
  }

  static Future<void> showSuccessAnimation({
    required BuildContext context,
    required PublishChannel channel,
    required String productTitle,
    required double price,
    VendorModel? vendor,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PublishSuccessModal(
        channel: channel,
        productTitle: productTitle,
        price: price,
        vendor: vendor,
      ),
    );
  }
}

// ── Step 1: Channel Selector Sheet ──────────────────────────────────────────
class _ChannelSelectorSheet extends StatelessWidget {
  const _ChannelSelectorSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose Sales Channel',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Select where you want to list your artisan product',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _ChannelCard(
            title: 'Sell on Amazon',
            subtitle: 'Reach millions of retail shoppers across India (B2C Marketplace)',
            icon: Icons.shopping_bag_rounded,
            badgeColor: const Color(0xFFFF9900),
            accentColor: const Color(0xFF232F3E),
            onTap: () => Navigator.pop(context, PublishChannel.amazon),
          ),
          const SizedBox(height: 14),
          _ChannelCard(
            title: 'Sell B2B (Wholesale)',
            subtitle: 'Connect & send proposals to verified buyers, hotels & exporters',
            icon: Icons.storefront_rounded,
            badgeColor: AppColors.indigo,
            accentColor: AppColors.turmeric,
            onTap: () => Navigator.pop(context, PublishChannel.b2b),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color badgeColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _ChannelCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: badgeColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: badgeColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 2: Channel Onboarding Questions Modal ──────────────────────────────
class _OnboardingDialog extends StatefulWidget {
  final PublishChannel channel;
  const _OnboardingDialog({required this.channel});

  @override
  State<_OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<_OnboardingDialog> {
  String _option1 = 'Yes';
  String _option2 = 'Easy Ship';
  String _option3 = '7 Days';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF9900)),
          SizedBox(width: 10),
          Text('Amazon Onboarding'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Answer a few quick questions to list on Amazon Marketplace:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            const _QuestionHeader('Do you have a GST Number?'),
            _ChoiceChips(
              options: const ['Yes', 'No (Artisan Exempt)'],
              selected: _option1,
              onSelected: (v) => setState(() => _option1 = v),
            ),
            const SizedBox(height: 12),
            const _QuestionHeader('Preferred Shipping Method'),
            _ChoiceChips(
              options: const ['Easy Ship', 'Self-Ship'],
              selected: _option2,
              onSelected: (v) => setState(() => _option2 = v),
            ),
            const SizedBox(height: 12),
            const _QuestionHeader('Return Policy Duration'),
            _ChoiceChips(
              options: const ['7 Days', '10 Days', 'No Returns'],
              selected: _option3,
              onSelected: (v) => setState(() => _option3 = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.rocket_launch_rounded, size: 18),
          label: const Text('Launch Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9900),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  final String text;
  const _QuestionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      );
}

class _ChoiceChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ChoiceChips({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSel = opt == selected;
        return ChoiceChip(
          label: Text(opt, style: TextStyle(fontSize: 12, color: isSel ? Colors.white : Colors.black87)),
          selected: isSel,
          selectedColor: AppColors.turmeric,
          onSelected: (_) => onSelected(opt),
        );
      }).toList(),
    );
  }
}

// ── Step 3: Eye-Catching Success Animation Screen Modal ─────────────────────
class _PublishSuccessModal extends StatefulWidget {
  final PublishChannel channel;
  final String productTitle;
  final double price;
  final VendorModel? vendor;

  const _PublishSuccessModal({
    required this.channel,
    required this.productTitle,
    required this.price,
    this.vendor,
  });

  @override
  State<_PublishSuccessModal> createState() => _PublishSuccessModalState();
}

class _PublishSuccessModalState extends State<_PublishSuccessModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _checkAnim;
  late Animation<double> _badgeAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    );

    _checkAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutBack),
    );

    _badgeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.bounceOut),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAmazon = widget.channel == PublishChannel.amazon;
    final badgeColor = isAmazon ? const Color(0xFFFF9900) : AppColors.indigo;

    final badgeLabel = isAmazon
        ? 'LIVE ON AMAZON'
        : 'SENT TO ${widget.vendor?.name.toUpperCase() ?? "B2B BUYER"}';

    final messageText = isAmazon
        ? '${widget.productTitle} has been published to Amazon Marketplace at ₹${widget.price.toStringAsFixed(0)}.'
        : 'Your product proposal for ${widget.productTitle} (₹${widget.price.toStringAsFixed(0)}) has been sent directly to ${widget.vendor?.name ?? "the vendor"}.';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Confetti Particles Visual Effect
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glowing circle burst
                      Transform.scale(
                        scale: _scaleAnim.value,
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: badgeColor.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      // Animated checkmark circle
                      Transform.scale(
                        scale: _checkAnim.value,
                        child: Container(
                          width: 76, height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isAmazon
                                  ? [const Color(0xFFFF9900), const Color(0xFFFF8000)]
                                  : [AppColors.indigo, AppColors.turmeric],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: badgeColor.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                        ),
                      ),
                      // Decorative sparkles around checkmark
                      ...List.generate(6, (i) {
                        final angle = i * (pi / 3);
                        final distance = 55.0 * _scaleAnim.value;
                        return Transform.translate(
                          offset: Offset(cos(angle) * distance, sin(angle) * distance),
                          child: Opacity(
                            opacity: _fadeAnim.value,
                            child: Icon(Icons.star_rounded, color: AppColors.turmeric, size: 16),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Channel / Vendor Badge drop-in
                Transform.scale(
                  scale: _badgeAnim.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isAmazon ? Icons.shopping_bag_rounded : Icons.storefront_rounded,
                            size: 16, color: badgeColor),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: badgeColor,
                              letterSpacing: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Text(
                        isAmazon ? 'Your product is now Live!' : 'Proposal Sent Successfully!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.indigo,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        messageText,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.done_all_rounded),
                        label: const Text('Great, Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: badgeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
