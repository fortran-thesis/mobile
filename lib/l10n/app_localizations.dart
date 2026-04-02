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

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest News'**
  String get latestNews;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @unrecognizedRole.
  ///
  /// In en, this message translates to:
  /// **'Unrecognized Role'**
  String get unrecognizedRole;

  /// No description provided for @statusLabelPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusLabelPending;

  /// No description provided for @statusLabelInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusLabelInProgress;

  /// No description provided for @statusLabelResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusLabelResolved;

  /// No description provided for @statusLabelRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusLabelRejected;

  /// No description provided for @statusLabelClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusLabelClosed;

  /// No description provided for @statusLabelLowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get statusLabelLowPriority;

  /// No description provided for @statusLabelMediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium Priority'**
  String get statusLabelMediumPriority;

  /// No description provided for @statusLabelHighPriority.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get statusLabelHighPriority;

  /// No description provided for @drawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Identify Mold With Moldify'**
  String get drawerTitle;

  /// No description provided for @termsOfAgreement.
  ///
  /// In en, this message translates to:
  /// **'Terms of Agreement'**
  String get termsOfAgreement;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @reportABug.
  ///
  /// In en, this message translates to:
  /// **'Report A Bug'**
  String get reportABug;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @caseStatusBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Case Status Breakdown'**
  String get caseStatusBreakdown;

  /// No description provided for @totalCasesReported.
  ///
  /// In en, this message translates to:
  /// **'Total Cases Reported'**
  String get totalCasesReported;

  /// No description provided for @boldAgainstMold.
  ///
  /// In en, this message translates to:
  /// **'Bold Against Mold'**
  String get boldAgainstMold;

  /// No description provided for @protectYourCrops.
  ///
  /// In en, this message translates to:
  /// **'Take action, and protect your growing crops.'**
  String get protectYourCrops;

  /// No description provided for @noArticlesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No articles available'**
  String get noArticlesAvailable;

  /// No description provided for @viewReportTitle.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get viewReportTitle;

  /// No description provided for @treatmentHistory.
  ///
  /// In en, this message translates to:
  /// **'Treatment History'**
  String get treatmentHistory;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @caseDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Case Details'**
  String get caseDetailsLabel;

  /// No description provided for @viewDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'View details reported by the farmer about the mold problem.'**
  String get viewDetailsDescription;

  /// No description provided for @submittedBy.
  ///
  /// In en, this message translates to:
  /// **'Submitted By:'**
  String get submittedBy;

  /// No description provided for @dateFirstObservedLabel.
  ///
  /// In en, this message translates to:
  /// **'Date First Observed:'**
  String get dateFirstObservedLabel;

  /// No description provided for @contactNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Number:'**
  String get contactNumberLabel;

  /// No description provided for @noInformationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No information available.'**
  String get noInformationAvailable;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes:'**
  String get additionalNotes;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @unknownCrop.
  ///
  /// In en, this message translates to:
  /// **'Unknown crop'**
  String get unknownCrop;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// No description provided for @closeCase.
  ///
  /// In en, this message translates to:
  /// **'Close Case'**
  String get closeCase;

  /// No description provided for @addFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Add Follow-up'**
  String get addFollowUp;

  /// No description provided for @confirmCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close this report?'**
  String get confirmCloseTitle;

  /// No description provided for @confirmCloseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Once closed, you will not be able to add follow-ups.'**
  String get confirmCloseSubtitle;

  /// No description provided for @reportClosed.
  ///
  /// In en, this message translates to:
  /// **'Report closed'**
  String get reportClosed;

  /// No description provided for @failedToCloseReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to close report: {error}'**
  String failedToCloseReport(String error);

  /// No description provided for @addFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Follow Up'**
  String get addFollowUpTitle;

  /// No description provided for @addFollowUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide additional details to help us assist you better.'**
  String get addFollowUpSubtitle;

  /// No description provided for @uploadPhotoLimit.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo (Up to 5 photos)'**
  String get uploadPhotoLimit;

  /// No description provided for @whatsStillHappening.
  ///
  /// In en, this message translates to:
  /// **'What’s Still Happening?'**
  String get whatsStillHappening;

  /// No description provided for @enterFollowUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description of the current problem...'**
  String get enterFollowUpDescription;

  /// No description provided for @confirmSubmitFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to submit this follow up?'**
  String get confirmSubmitFollowUpTitle;

  /// No description provided for @confirmSubmitFollowUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Once submitted, you will not be able to edit it.'**
  String get confirmSubmitFollowUpSubtitle;

  /// No description provided for @submitFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Submit Follow Up'**
  String get submitFollowUp;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @followUpSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Follow-up submitted successfully!'**
  String get followUpSubmitted;

  /// No description provided for @failedToSubmitFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit follow-up: {error}'**
  String failedToSubmitFollowUp(String error);

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit the fields to update your information.'**
  String get editProfileSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter Username'**
  String get enterUsername;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter First Name'**
  String get enterFirstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get enterLastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location(City/Province)'**
  String get locationLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @noChangesDetected.
  ///
  /// In en, this message translates to:
  /// **'No changes detected.'**
  String get noChangesDetected;

  /// No description provided for @confirmProfileUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update your profile?'**
  String get confirmProfileUpdateTitle;

  /// No description provided for @confirmProfileUpdateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your {fields}?'**
  String confirmProfileUpdateSubtitle(String fields);

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedToUpdateProfile(String error);

  /// No description provided for @authErrorPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated. Please log in again.'**
  String get authErrorPleaseLogin;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type a new password to update your account.'**
  String get changePasswordSubtitle;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @enterOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Old Password'**
  String get enterOldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter New Password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @enterConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Confirm New Password'**
  String get enterConfirmNewPassword;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordTooShort;

  /// No description provided for @passwordLowercaseRequired.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordLowercaseRequired;

  /// No description provided for @passwordUppercaseRequired.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordUppercaseRequired;

  /// No description provided for @passwordNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordNumberRequired;

  /// No description provided for @passwordSpecialCharRequired.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get passwordSpecialCharRequired;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password: {error}'**
  String failedToChangePassword(String error);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @articleDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Article data is unavailable.'**
  String get articleDataUnavailable;

  /// No description provided for @viewWikiMold.
  ///
  /// In en, this message translates to:
  /// **'View WikiMold'**
  String get viewWikiMold;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @errorLoadingArticles.
  ///
  /// In en, this message translates to:
  /// **'Error loading articles: {error}'**
  String errorLoadingArticles(String error);

  /// No description provided for @errorLoadingMoreArticles.
  ///
  /// In en, this message translates to:
  /// **'Error loading more articles: {error}'**
  String errorLoadingMoreArticles(String error);

  /// No description provided for @articleNotAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'This article is not available yet.'**
  String get articleNotAvailableYet;

  /// No description provided for @controlTreatmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'5 CONTROL TREATMENTS'**
  String get controlTreatmentsLabel;

  /// No description provided for @preventionTacticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prevention Tactics'**
  String get preventionTacticsTitle;

  /// No description provided for @preventionTacticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive mold control management strategies.'**
  String get preventionTacticsSubtitle;

  /// No description provided for @noPreventionTacticsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No prevention tactics available'**
  String get noPreventionTacticsAvailable;

  /// No description provided for @treatmentRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Treatment Recommendations'**
  String get treatmentRecommendations;

  /// No description provided for @informationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Information currently unavailable.'**
  String get informationUnavailable;

  /// No description provided for @observationDataPending.
  ///
  /// In en, this message translates to:
  /// **'Observation data pending...'**
  String get observationDataPending;

  /// No description provided for @scientificDataPending.
  ///
  /// In en, this message translates to:
  /// **'Scientific data pending review...'**
  String get scientificDataPending;

  /// No description provided for @errorReportIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Error: Report ID not found'**
  String get errorReportIdNotFound;

  /// No description provided for @photoUploadLimit.
  ///
  /// In en, this message translates to:
  /// **'You can only upload up to 5 photos.'**
  String get photoUploadLimit;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome To'**
  String get welcomeTo;

  /// No description provided for @welcomeAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A Mold Investigation System for Agriculture'**
  String get welcomeAppSubtitle;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Submit Mold Cases with '**
  String get onboarding1Title;

  /// No description provided for @onboarding1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Ease'**
  String get onboarding1Highlight;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Moldify is a digital system that enables farmers to submit suspected mold cases for structured expert investigation.'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Expert Review by '**
  String get onboarding2Title;

  /// No description provided for @onboarding2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Mycologists'**
  String get onboarding2Highlight;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Moldify supports expert assessment and informed agricultural decision. Got mold worries? Use Moldify and take action today.'**
  String get onboarding2Subtitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @continueToApp.
  ///
  /// In en, this message translates to:
  /// **'Continue To App'**
  String get continueToApp;

  /// No description provided for @chooseRole.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE ROLE'**
  String get chooseRole;

  /// No description provided for @chooseRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please select your role to proceed to login'**
  String get chooseRoleSubtitle;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @mycologist.
  ///
  /// In en, this message translates to:
  /// **'Mycologist'**
  String get mycologist;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get logIn;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter username and password.'**
  String get loginSubtitle;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @enterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPasswordHint;

  /// No description provided for @forgotUsername.
  ///
  /// In en, this message translates to:
  /// **'Forgot Username?'**
  String get forgotUsername;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// No description provided for @loginTermsText.
  ///
  /// In en, this message translates to:
  /// **'By proceeding you acknowledge that you have read, understood and agree to our '**
  String get loginTermsText;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signUp;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter details to create an account.'**
  String get signUpSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Email'**
  String get enterEmail;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @enterOccupation.
  ///
  /// In en, this message translates to:
  /// **'Enter occupation'**
  String get enterOccupation;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Confirm Password'**
  String get enterConfirmPassword;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @logInLink.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInLink;

  /// No description provided for @signUpTermsText.
  ///
  /// In en, this message translates to:
  /// **'I acknowledged that I have read, understood and agree to our '**
  String get signUpTermsText;
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
