import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_gate_screen.dart';
import 'services/locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey, // ignore: deprecated_member_use
  );

  // Restore saved preferred language on app startup if session exists
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('preferred_language')
          .eq('id', currentUser.id)
          .maybeSingle();
      if (profile != null && profile['preferred_language'] != null) {
        localeController.setLocale(profile['preferred_language'] as String);
      }
    } catch (_) {}
  }

  runApp(const KalasetuApp());
}

class KalasetuApp extends StatelessWidget {
  const KalasetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Kalasetu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AuthGateScreen(),
        );
      },
    );
  }
}