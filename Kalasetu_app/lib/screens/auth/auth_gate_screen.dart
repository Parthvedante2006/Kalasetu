import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check initial session
    final initialSession = Supabase.instance.client.auth.currentSession;

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? initialSession;
        if (session != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
