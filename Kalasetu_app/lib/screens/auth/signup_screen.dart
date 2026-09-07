import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _language = 'en';
  bool _loading = false;
  String? _error;

  final _languages = const [
    ('en', 'English'),
    ('hi', 'Hindi — हिंदी'),
    ('mr', 'Marathi — मराठी'),
  ];

  Future<void> _signup() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (name.isEmpty) { setState(() => _error = 'Please enter your name'); return; }
    if (email.isEmpty) { setState(() => _error = 'Please enter your email'); return; }
    if (pass.length < 6) { setState(() => _error = 'Password must be at least 6 characters'); return; }

    setState(() { _loading = true; _error = null; });
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: pass,
        data: {'full_name': name, 'preferred_language': _language},
      );

      final userId = res.user?.id;
      final hasSession = res.session != null; // false when email confirmation required

      if (userId != null && hasSession) {
        // Email confirmation is OFF — user is signed in immediately.
        // Update the profile row that the DB trigger created.
        await Supabase.instance.client.from('profiles').update({
          'full_name': name,
          'preferred_language': _language,
        }).eq('id', userId);
        // AuthGateScreen will detect the session and navigate to HomeScreen.
      } else if (userId != null && !hasSession) {
        // Email confirmation is ON — show friendly message.
        if (mounted) {
          setState(() { _loading = false; });
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Check your email'),
              content: Text(
                'We sent a confirmation link to $email.\n\n'
                'After confirming, sign in with your password.',
              ),
              actions: [
                TextButton(
                  onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                  child: const Text('Go to Sign In'),
                ),
              ],
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      backgroundColor: AppColors.handloomCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password (min 6 chars)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              Text('Preferred Language', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              // ignore: deprecated_member_use
              ..._languages.map((lang) => RadioListTile<String>(
                value: lang.$1,
                groupValue: _language, // ignore: deprecated_member_use
                title: Text(lang.$2),
                onChanged: (v) => setState(() => _language = v!), // ignore: deprecated_member_use
                activeColor: AppColors.turmeric,
                contentPadding: EdgeInsets.zero,
              )),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _signup,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
