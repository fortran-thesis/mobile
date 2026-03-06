// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get caseHistory => 'Case History';

  @override
  String get flagHistory => 'Flag History';

  @override
  String get language => 'Language';

  @override
  String get languagePageTitle => 'Language Settings';

  @override
  String get languagePageSubtitle => 'Choose your preferred language';

  @override
  String get english => 'English';

  @override
  String get filipino => 'Filipino';

  @override
  String get moldReport => 'Mold Report';

  @override
  String get moldReportSubtitle =>
      'This is the collection of your submitted mold report';

  @override
  String get submitMoldReport => 'Submit Mold Report';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get submitReportSubtitle =>
      'Fill out the details below to submit your mold report.';

  @override
  String get caseName => 'Case Name';

  @override
  String get enterCaseName => 'Enter case name';

  @override
  String get cropName => 'Crop Name';

  @override
  String get enterCropName => 'Enter crop name';

  @override
  String get location => 'Location (City/Province)';

  @override
  String get enterLocation => 'Enter location';

  @override
  String get dateFirstObserved => 'Date First Observed';

  @override
  String get enterDateFirstObserved => 'Enter date first observed';

  @override
  String get uploadPhoto => 'Upload Photo (Up to 5 photos)';

  @override
  String get problemDescription => 'Problem Description';

  @override
  String get enterProblemDescription => 'Enter problem description';

  @override
  String get useCamera => 'Use Camera';

  @override
  String get selectCropName => 'Select Crop Name';

  @override
  String get selectProblemDescription => 'Select Problem Description';

  @override
  String get othersLabel => 'Others/Iba pa';

  @override
  String get customCropInputHint => 'Type the crop name here';

  @override
  String get customProblemInputHint => 'Describe the problem here';

  @override
  String get goBackTitle => 'Are you sure you want to go back?';

  @override
  String get goBackSubtitle => 'Going back now will lose all your progress.';

  @override
  String get submitReportConfirmTitle =>
      'Are you sure you want to submit this report?';

  @override
  String get submitReportConfirmSubtitle =>
      'Once submitted, you will not be able to edit the report details.';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get caseNameRequired => 'Case name is required';

  @override
  String get cropNameRequired => 'Crop name is required';

  @override
  String get locationRequired => 'Location is required';

  @override
  String get dateFirstObservedRequired => 'Date first observed is required';

  @override
  String get problemDescriptionRequired => 'Problem description is required';

  @override
  String get faq => 'FAQ';

  @override
  String get faqSubtitle => 'Got a question? Find quick answers here.';

  @override
  String get searchFaq => 'Search FAQ';

  @override
  String get wikiMold => 'WikiMold';

  @override
  String get wikiMoldSubtitle => 'Your go-to mold encyclopedia.';

  @override
  String get searchWikiMold => 'Search WikiMold';

  @override
  String get noArticlesFound => 'No articles match your search.';

  @override
  String get statusPending =>
      'Your report has been sent in and is now waiting to be checked.';

  @override
  String get statusInProgress =>
      'We\'re checking your report now. You\'ll see the results when it\'s ready.';

  @override
  String get statusRejected =>
      'Sorry, your report was rejected and can\'t be processed.';
}
