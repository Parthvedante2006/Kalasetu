import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  int _totalListings = 0;
  int _b2bSubmissions = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfileDetails();
  }

  Future<void> _loadProfileDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final db = Supabase.instance.client;

      // 1. Fetch profile row from DB
      final profileRow = await db
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      // 2. Fetch artisan statistics (total listings)
      final listingsRes = await db
          .from('listings')
          .select('id')
          .eq('user_id', currentUser.id);
      
      // 3. Fetch B2B submissions count
      final submissionsRes = await db
          .from('vendor_submissions')
          .select('id')
          .eq('user_id', currentUser.id);

      if (mounted) {
        setState(() {
          _profileData = profileRow ?? {};
          _totalListings = (listingsRes as List).length;
          _b2bSubmissions = (submissionsRes as List).length;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  String _getLanguageLabel(String? code) {
    switch (code?.toLowerCase()) {
      case 'hi':
        return 'Hindi — हिंदी';
      case 'mr':
        return 'Marathi — मराठी';
      case 'gu':
        return 'Gujarati — ગુજરાતી';
      case 'ta':
        return 'Tamil — தமிழ்';
      case 'en':
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'No email associated';
    final fullName = _profileData?['full_name'] as String? ?? user?.userMetadata?['full_name'] as String? ?? 'Artisan User';
    final langCode = _profileData?['preferred_language'] as String? ?? user?.userMetadata?['preferred_language'] as String? ?? 'en';
    final createdAtStr = user?.createdAt != null
        ? user!.createdAt.split('T')[0]
        : 'Recently';

    return Scaffold(
      backgroundColor: AppColors.handloomCream,
      appBar: AppBar(
        title: const Text('Artisan Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadProfileDetails,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfileDetails,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.turmeric))
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Artisan Hero Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.indigo, AppColors.indigo.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.indigo.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.turmeric,
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.turmeric.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Verified Artisan Member',
                              style: TextStyle(
                                color: AppColors.turmeric,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Statistics Overview Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.inventory_2_rounded,
                      value: _totalListings.toString(),
                      label: 'Total Products',
                      color: AppColors.terracotta,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.storefront_rounded,
                      value: _b2bSubmissions.toString(),
                      label: 'B2B Proposals',
                      color: AppColors.indigo,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Account Information',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.indigo,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 12),

              // Profile Details Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        value: fullName,
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.email_outlined,
                        label: 'Email Address',
                        value: email,
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.translate_rounded,
                        label: 'Preferred Language',
                        value: _getLanguageLabel(langCode),
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.badge_outlined,
                        label: 'Artisan User ID',
                        value: user?.id ?? 'Unknown',
                        isCompact: true,
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Member Since',
                        value: createdAtStr,
                      ),
                    ],
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'Error loading profile from DB: $_error',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Sign Out Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isCompact;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.indigo, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isCompact ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warmCharcoal,
                ),
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
