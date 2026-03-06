import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fil'),
  ];

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @caseHistory.
  ///
  /// In en, this message translates to:
  /// **'Case History'**
  String get caseHistory;

  /// No description provided for @flagHistory.
  ///
  /// In en, this message translates to:
  /// **'Flag History'**
  String get flagHistory;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languagePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languagePageTitle;

  /// No description provided for @languagePageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languagePageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @filipino.
  ///
  /// In en, this message translates to:
  /// **'Filipino'**
  String get filipino;

  /// No description provided for @moldReport.
  ///
  /// In en, this message translates to:
  /// **'Mold Report'**
  String get moldReport;

  /// No description provided for @moldReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is the collection of your submitted mold report'**
  String get moldReportSubtitle;

  /// No description provided for @submitMoldReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Mold Report'**
  String get submitMoldReport;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @submitReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill out the details below to submit your mold report.'**
  String get submitReportSubtitle;

  /// No description provided for @caseName.
  ///
  /// In en, this message translates to:
  /// **'Case Name'**
  String get caseName;

  /// No description provided for @enterCaseName.
  ///
  /// In en, this message translates to:
  /// **'Enter case name'**
  String get enterCaseName;

  /// No description provided for @cropName.
  ///
  /// In en, this message translates to:
  /// **'Crop Name'**
  String get cropName;

  /// No description provided for @enterCropName.
  ///
  /// In en, this message translates to:
  /// **'Enter crop name'**
  String get enterCropName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location (City/Province)'**
  String get location;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter location'**
  String get enterLocation;

  /// No description provided for @dateFirstObserved.
  ///
  /// In en, this message translates to:
  /// **'Date First Observed'**
  String get dateFirstObserved;

  /// No description provided for @enterDateFirstObserved.
  ///
  /// In en, this message translates to:
  /// **'Enter date first observed'**
  String get enterDateFirstObserved;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo (Up to 5 photos)'**
  String get uploadPhoto;

  /// No description provided for @problemDescription.
  ///
  /// In en, this message translates to:
  /// **'Problem Description'**
  String get problemDescription;

  /// No description provided for @enterProblemDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter problem description'**
  String get enterProblemDescription;

  /// No description provided for @useCamera.
  ///
  /// In en, this message translates to:
  /// **'Use Camera'**
  String get useCamera;

  /// No description provided for @selectCropName.
  ///
  /// In en, this message translates to:
  /// **'Select Crop Name'**
  String get selectCropName;

  /// No description provided for @selectProblemDescription.
  ///
  /// In en, this message translates to:
  /// **'Select Problem Description'**
  String get selectProblemDescription;

  /// No description provided for @othersLabel.
  ///
  /// In en, this message translates to:
  /// **'Others/Iba pa'**
  String get othersLabel;

  /// No description provided for @customCropInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type the crop name here'**
  String get customCropInputHint;

  /// No description provided for @customProblemInputHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem here'**
  String get customProblemInputHint;

  /// No description provided for @goBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go back?'**
  String get goBackTitle;

  /// No description provided for @goBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Going back now will lose all your progress.'**
  String get goBackSubtitle;

  /// No description provided for @submitReportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to submit this report?'**
  String get submitReportConfirmTitle;

  /// No description provided for @submitReportConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Once submitted, you will not be able to edit the report details.'**
  String get submitReportConfirmSubtitle;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @caseNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Case name is required'**
  String get caseNameRequired;

  /// No description provided for @cropNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Crop name is required'**
  String get cropNameRequired;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get locationRequired;

  /// No description provided for @dateFirstObservedRequired.
  ///
  /// In en, this message translates to:
  /// **'Date first observed is required'**
  String get dateFirstObservedRequired;

  /// No description provided for @problemDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Problem description is required'**
  String get problemDescriptionRequired;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @faqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Got a question? Find quick answers here.'**
  String get faqSubtitle;

  /// No description provided for @searchFaq.
  ///
  /// In en, this message translates to:
  /// **'Search FAQ'**
  String get searchFaq;

  /// No description provided for @wikiMold.
  ///
  /// In en, this message translates to:
  /// **'WikiMold'**
  String get wikiMold;

  /// No description provided for @wikiMoldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your go-to mold encyclopedia.'**
  String get wikiMoldSubtitle;

  /// No description provided for @searchWikiMold.
  ///
  /// In en, this message translates to:
  /// **'Search WikiMold'**
  String get searchWikiMold;

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No articles match your search.'**
  String get noArticlesFound;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Your report has been sent in and is now waiting to be checked.'**
  String get statusPending;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'We\'re checking your report now. You\'ll see the results when it\'s ready.'**
  String get statusInProgress;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Sorry, your report was rejected and can\'t be processed.'**
  String get statusRejected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
