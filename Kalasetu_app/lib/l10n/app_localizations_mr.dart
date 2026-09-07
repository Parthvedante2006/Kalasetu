// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'कलासेतू';

  @override
  String get home => 'मुख्यपृष्ठ';

  @override
  String get explore => 'एक्सप्लोर करा';

  @override
  String get addNew => 'नवीन जोडा';

  @override
  String get learner => 'शिका';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get artisanProfile => 'कारागीर प्रोफाइल';

  @override
  String get accountInformation => 'खाते माहिती';

  @override
  String get fullName => 'पूर्ण नाव';

  @override
  String get emailAddress => 'ईमेल पत्ता';

  @override
  String get preferredLanguage => 'पसंतीची भाषा';

  @override
  String get artisanUserId => 'कारागीर युझर आयडी';

  @override
  String get memberSince => 'सदस्यता तारीख';

  @override
  String get totalProducts => 'एकूण उत्पादने';

  @override
  String get b2bProposals => 'बी२बी प्रस्ताव';

  @override
  String get signOut => 'साइन आउट करा';

  @override
  String get verifiedArtisan => 'सत्यापित कारागीर सदस्य';

  @override
  String get noListingsYet => 'अद्याप कोणतीही उत्पादने नाहीत';

  @override
  String get tapAddNewToStart =>
      'तुमचे पहिले उत्पादन जोडण्यासाठी खालील \"+ नवीन जोडा\" वर टॅप करा';

  @override
  String get sellOnAmazon => 'ॲमेझॉनवर विका';

  @override
  String get sellB2B => 'बी२बी मध्ये विका';

  @override
  String sendProductTo(Object vendorName) {
    return '$vendorName ला उत्पादन पाठवा';
  }

  @override
  String get sahayakAI => 'सहाय्यक एआय';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi — हिंदी';

  @override
  String get marathi => 'Marathi — मराठी';
}
