// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'कलासेतु';

  @override
  String get home => 'होम';

  @override
  String get explore => 'एक्सप्लोर करें';

  @override
  String get addNew => 'नया जोड़ें';

  @override
  String get learner => 'सीखें';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get artisanProfile => 'कारीगर प्रोफ़ाइल';

  @override
  String get accountInformation => 'खाता जानकारी';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get preferredLanguage => 'पसंदीदा भाषा';

  @override
  String get artisanUserId => 'कारीगर यूजर आईडी';

  @override
  String get memberSince => 'सदस्यता तिथि';

  @override
  String get totalProducts => 'कुल उत्पाद';

  @override
  String get b2bProposals => 'बी2बी प्रस्ताव';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get verifiedArtisan => 'सत्यापित कारीगर सदस्य';

  @override
  String get noListingsYet => 'अभी कोई उत्पाद नहीं है';

  @override
  String get tapAddNewToStart =>
      'अपना पहला उत्पाद जोड़ने के लिए नीचे \"+ नया जोड़ें\" पर टैप करें';

  @override
  String get sellOnAmazon => 'अमेज़न पर बेचें';

  @override
  String get sellB2B => 'बी2बी में बेचें';

  @override
  String sendProductTo(Object vendorName) {
    return '$vendorName को उत्पाद भेजें';
  }

  @override
  String get sahayakAI => 'सहायक एआई';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi — हिंदी';

  @override
  String get marathi => 'Marathi — मराठी';
}
