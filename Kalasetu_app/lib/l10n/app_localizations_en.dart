// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KalaSetu';

  @override
  String get home => 'Home';

  @override
  String get explore => 'Explore';

  @override
  String get addNew => 'Add New';

  @override
  String get learner => 'Learner';

  @override
  String get profile => 'Profile';

  @override
  String get artisanProfile => 'Artisan Profile';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get preferredLanguage => 'Preferred Language';

  @override
  String get artisanUserId => 'Artisan User ID';

  @override
  String get memberSince => 'Member Since';

  @override
  String get totalProducts => 'Total Products';

  @override
  String get b2bProposals => 'B2B Proposals';

  @override
  String get signOut => 'Sign Out';

  @override
  String get verifiedArtisan => 'Verified Artisan Member';

  @override
  String get noListingsYet => 'No listings yet';

  @override
  String get tapAddNewToStart =>
      'Tap \"+ Add New\" below to add your first product';

  @override
  String get sellOnAmazon => 'Sell on Amazon';

  @override
  String get sellB2B => 'Sell B2B';

  @override
  String sendProductTo(Object vendorName) {
    return 'Send Product to $vendorName';
  }

  @override
  String get sahayakAI => 'Sahayak AI';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi — हिंदी';

  @override
  String get marathi => 'Marathi — मराठी';
}
