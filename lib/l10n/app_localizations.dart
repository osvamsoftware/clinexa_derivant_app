import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
    Locale('es'),
  ];

  /// Error message when a field is left empty.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing health'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Clinexapp connects referring physicians with clinical research teams, securely and transparently.'**
  String get welcomeDescription;

  /// No description provided for @loginHello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get loginHello;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeTitle;

  /// No description provided for @emailOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Email or Mobile Number'**
  String get emailOrMobile;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPasswordOld.
  ///
  /// In en, this message translates to:
  /// **'Forget Password'**
  String get forgotPasswordOld;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get dontHaveAccount;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signup;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email, like name@example.com.'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number: 6 to 12 digits, no spaces.'**
  String get invalidPhone;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordMin;

  /// No description provided for @passwordMax.
  ///
  /// In en, this message translates to:
  /// **'Use 128 characters or fewer.'**
  String get passwordMax;

  /// No description provided for @passwordComplexity.
  ///
  /// In en, this message translates to:
  /// **'Combine uppercase, lowercase and numbers.'**
  String get passwordComplexity;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get passwordMismatch;

  /// No description provided for @invalidName.
  ///
  /// In en, this message translates to:
  /// **'Invalid name'**
  String get invalidName;

  /// No description provided for @invalidLastName.
  ///
  /// In en, this message translates to:
  /// **'Invalid last name'**
  String get invalidLastName;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCode;

  /// No description provided for @invalidMemberId.
  ///
  /// In en, this message translates to:
  /// **'Member ID must be 8 digits'**
  String get invalidMemberId;

  /// No description provided for @invalidDni.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number with more than 6 digits.'**
  String get invalidDni;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorOccurred;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get ok;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @registerDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor Registration'**
  String get registerDoctor;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @medicalLicense.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get medicalLicense;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @specialtyExample.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get specialtyExample;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @biography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biography;

  /// No description provided for @biographyHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your experience...'**
  String get biographyHint;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @streetExample.
  ///
  /// In en, this message translates to:
  /// **'Street 123'**
  String get streetExample;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @searchSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get searchSpecialty;

  /// No description provided for @register_step1_title.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get register_step1_title;

  /// No description provided for @register_firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get register_firstName;

  /// No description provided for @register_lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get register_lastName;

  /// No description provided for @register_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get register_email;

  /// No description provided for @register_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get register_password;

  /// No description provided for @register_next.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get register_next;

  /// No description provided for @register_basicInfo_description.
  ///
  /// In en, this message translates to:
  /// **'Enter your basic information to continue.'**
  String get register_basicInfo_description;

  /// No description provided for @register_header.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to start referring patients to clinical trials.'**
  String get register_header;

  /// No description provided for @specialty_required.
  ///
  /// In en, this message translates to:
  /// **'Add at least one specialty.'**
  String get specialty_required;

  /// No description provided for @register_successMessage.
  ///
  /// In en, this message translates to:
  /// **'You can now log in with your email and password.'**
  String get register_successMessage;

  /// No description provided for @error400.
  ///
  /// In en, this message translates to:
  /// **'Bad request (400)'**
  String get error400;

  /// No description provided for @error401.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized (401)'**
  String get error401;

  /// No description provided for @error403.
  ///
  /// In en, this message translates to:
  /// **'Access denied (403)'**
  String get error403;

  /// No description provided for @error404.
  ///
  /// In en, this message translates to:
  /// **'Resource not found (404)'**
  String get error404;

  /// No description provided for @error408.
  ///
  /// In en, this message translates to:
  /// **'Request timed out (408)'**
  String get error408;

  /// No description provided for @error500.
  ///
  /// In en, this message translates to:
  /// **'Server error (500)'**
  String get error500;

  /// No description provided for @error503.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable (503)'**
  String get error503;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknown;

  /// No description provided for @errorGenericMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t process your request. Please try again.'**
  String get errorGenericMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @patientList.
  ///
  /// In en, this message translates to:
  /// **'Patient List'**
  String get patientList;

  /// No description provided for @protocolsList.
  ///
  /// In en, this message translates to:
  /// **'Protocols List'**
  String get protocolsList;

  /// No description provided for @filterProtocols.
  ///
  /// In en, this message translates to:
  /// **'Filter protocols'**
  String get filterProtocols;

  /// No description provided for @selectSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Select specialty'**
  String get selectSpecialty;

  /// No description provided for @errorLoadingSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Error loading specialties'**
  String get errorLoadingSpecialties;

  /// No description provided for @pathology.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get pathology;

  /// No description provided for @selectPathology.
  ///
  /// In en, this message translates to:
  /// **'Select pathology'**
  String get selectPathology;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get searchByName;

  /// No description provided for @noProtocolsFound.
  ///
  /// In en, this message translates to:
  /// **'No protocols found'**
  String get noProtocolsFound;

  /// No description provided for @loadingSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Loading specialties...'**
  String get loadingSpecialties;

  /// No description provided for @loadingPathologies.
  ///
  /// In en, this message translates to:
  /// **'Loading pathologies...'**
  String get loadingPathologies;

  /// No description provided for @protocolDetails.
  ///
  /// In en, this message translates to:
  /// **'Check criteria'**
  String get protocolDetails;

  /// No description provided for @patientCriteria.
  ///
  /// In en, this message translates to:
  /// **'Patient Requirements (Criteria)'**
  String get patientCriteria;

  /// No description provided for @addToMyList.
  ///
  /// In en, this message translates to:
  /// **'Add to my protocol list'**
  String get addToMyList;

  /// No description provided for @removeFromMyList.
  ///
  /// In en, this message translates to:
  /// **'Remove from my protocol list'**
  String get removeFromMyList;

  /// No description provided for @protocolAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Protocol added successfully'**
  String get protocolAddedSuccessfully;

  /// No description provided for @protocolRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Protocol removed successfully'**
  String get protocolRemovedSuccessfully;

  /// No description provided for @errorLoadingProtocols.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the protocols. Pull down to try again.'**
  String get errorLoadingProtocols;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @protocolSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a protocol and check that your patient meets the criteria.'**
  String get protocolSelectionSubtitle;

  /// No description provided for @continue_text.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_text;

  /// No description provided for @protocolCriteriaVerificationInfo.
  ///
  /// In en, this message translates to:
  /// **'Check the criteria your patient meets. All of them are required to refer the patient.'**
  String get protocolCriteriaVerificationInfo;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcomeBack;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search patients...'**
  String get homeSearchHint;

  /// No description provided for @homeSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get homeSearchResults;

  /// No description provided for @homePathology.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get homePathology;

  /// No description provided for @homeSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get homeSpecialty;

  /// No description provided for @exampleMigraine.
  ///
  /// In en, this message translates to:
  /// **'Chronic Migraine'**
  String get exampleMigraine;

  /// No description provided for @exampleHypertension.
  ///
  /// In en, this message translates to:
  /// **'Hypertension'**
  String get exampleHypertension;

  /// No description provided for @exampleArrhythmia.
  ///
  /// In en, this message translates to:
  /// **'Arrhythmia'**
  String get exampleArrhythmia;

  /// No description provided for @exampleNeurology.
  ///
  /// In en, this message translates to:
  /// **'Neurology'**
  String get exampleNeurology;

  /// No description provided for @exampleCardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get exampleCardiology;

  /// No description provided for @searchPatient.
  ///
  /// In en, this message translates to:
  /// **'Search Patient'**
  String get searchPatient;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// No description provided for @navProtocols.
  ///
  /// In en, this message translates to:
  /// **'Protocols'**
  String get navProtocols;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @viewMyProtocols.
  ///
  /// In en, this message translates to:
  /// **'My protocols'**
  String get viewMyProtocols;

  /// No description provided for @registerPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient details'**
  String get registerPatient;

  /// No description provided for @dni.
  ///
  /// In en, this message translates to:
  /// **'DNI'**
  String get dni;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDate;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personalInfo;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactInfo;

  /// No description provided for @medicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Medical information'**
  String get medicalInfo;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @criteriaNotMet.
  ///
  /// In en, this message translates to:
  /// **'Some criteria are unchecked'**
  String get criteriaNotMet;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get showAll;

  /// No description provided for @allCriteriaFor.
  ///
  /// In en, this message translates to:
  /// **'All Criteria for {name}'**
  String allCriteriaFor(Object name);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @stepXofY.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepXofY(Object step, Object total);

  /// No description provided for @nextRegister.
  ///
  /// In en, this message translates to:
  /// **'Continue to patient details'**
  String get nextRegister;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get nextStep;

  /// No description provided for @searchSpecialtyHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Cardiology'**
  String get searchSpecialtyHint;

  /// No description provided for @searchPathologyHint.
  ///
  /// In en, this message translates to:
  /// **'Search pathology...'**
  String get searchPathologyHint;

  /// No description provided for @notAllCriteriaMet.
  ///
  /// In en, this message translates to:
  /// **'To continue, confirm every criterion in this step. If your patient doesn\'t meet one, they can\'t be referred to this protocol.'**
  String get notAllCriteriaMet;

  /// No description provided for @myPatients.
  ///
  /// In en, this message translates to:
  /// **'My patients'**
  String get myPatients;

  /// No description provided for @noPatientsFound.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have patients yet'**
  String get noPatientsFound;

  /// No description provided for @patientCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The patient was registered.'**
  String get patientCreatedSuccessfully;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @payForFullData.
  ///
  /// In en, this message translates to:
  /// **'Protected detail'**
  String get payForFullData;

  /// No description provided for @hiddenField.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hiddenField;

  /// No description provided for @orderStatusAssigned.
  ///
  /// In en, this message translates to:
  /// **'In evaluation'**
  String get orderStatusAssigned;

  /// No description provided for @orderStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get orderStatusAccepted;

  /// No description provided for @orderStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get orderStatusRejected;

  /// No description provided for @patientDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient record'**
  String get patientDetails;

  /// No description provided for @partialData.
  ///
  /// In en, this message translates to:
  /// **'Partial data'**
  String get partialData;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocol;

  /// No description provided for @provinceState.
  ///
  /// In en, this message translates to:
  /// **'Province or state'**
  String get provinceState;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Clinexapp'**
  String get appName;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Your session isn\'t active. Please log in again.'**
  String get userNotAuthenticated;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address...'**
  String get searchAddress;

  /// No description provided for @searchAddressPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type and pick a suggestion'**
  String get searchAddressPrompt;

  /// No description provided for @paymentProcessedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Payment processed successfully'**
  String get paymentProcessedSuccessfully;

  /// No description provided for @paymentIntentNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Payment intent ID or client secret not available'**
  String get paymentIntentNotAvailable;

  /// No description provided for @errorSearchingAddresses.
  ///
  /// In en, this message translates to:
  /// **'Error searching addresses'**
  String get errorSearchingAddresses;

  /// No description provided for @addressDetailsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Address details not found'**
  String get addressDetailsNotFound;

  /// No description provided for @errorGettingDetails.
  ///
  /// In en, this message translates to:
  /// **'Error getting details'**
  String get errorGettingDetails;

  /// No description provided for @selectValidAddress.
  ///
  /// In en, this message translates to:
  /// **'Choose an address from the suggestions.'**
  String get selectValidAddress;

  /// No description provided for @errorVerifyingUserStatus.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify your account. Please log in again.'**
  String get errorVerifyingUserStatus;

  /// No description provided for @noRefreshTokenFound.
  ///
  /// In en, this message translates to:
  /// **'No refresh token found'**
  String get noRefreshTokenFound;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get noAddress;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCode;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @markAsInactive.
  ///
  /// In en, this message translates to:
  /// **'Mark as inactive'**
  String get markAsInactive;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm action'**
  String get confirmAction;

  /// No description provided for @confirmMarkAsInactive.
  ///
  /// In en, this message translates to:
  /// **'The patient will no longer be available for protocols. You can reactivate them anytime.'**
  String get confirmMarkAsInactive;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @noOrderLinked.
  ///
  /// In en, this message translates to:
  /// **'No order yet'**
  String get noOrderLinked;

  /// No description provided for @activeOrder.
  ///
  /// In en, this message translates to:
  /// **'Active order'**
  String get activeOrder;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @professionalFees.
  ///
  /// In en, this message translates to:
  /// **'Professional fees for evaluating the patient'**
  String get professionalFees;

  /// No description provided for @whatsappVerificationNoticeDetailed.
  ///
  /// In en, this message translates to:
  /// **'Let the patient know they need an internet connection and access to their WhatsApp to receive it.'**
  String get whatsappVerificationNoticeDetailed;

  /// No description provided for @noPatientsPromotion.
  ///
  /// In en, this message translates to:
  /// **'Refer your first patient to a research protocol from Home.'**
  String get noPatientsPromotion;

  /// No description provided for @markAsActive.
  ///
  /// In en, this message translates to:
  /// **'Mark as active'**
  String get markAsActive;

  /// No description provided for @confirmMarkAsActive.
  ///
  /// In en, this message translates to:
  /// **'The patient will be available for protocols again.'**
  String get confirmMarkAsActive;

  /// No description provided for @licenseType.
  ///
  /// In en, this message translates to:
  /// **'License type'**
  String get licenseType;

  /// No description provided for @provincialLicense.
  ///
  /// In en, this message translates to:
  /// **'Provincial license'**
  String get provincialLicense;

  /// No description provided for @nationalLicense.
  ///
  /// In en, this message translates to:
  /// **'National license'**
  String get nationalLicense;

  /// No description provided for @phone2.
  ///
  /// In en, this message translates to:
  /// **'Additional phone'**
  String get phone2;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot my password'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email and we\'ll send you a link to create a new password.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendInstructions.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendInstructions;

  /// No description provided for @recoveryEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We sent you a link to reset your password. If you don\'t see it, check your spam folder.'**
  String get recoveryEmailSent;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat the new password'**
  String get confirmNewPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'You can now log in with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @notificationScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationScreenTitle;

  /// No description provided for @noNotificationsFound.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications'**
  String get noNotificationsFound;

  /// No description provided for @notificationMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'Notification marked as read'**
  String get notificationMarkedAsRead;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @cantFindProtocol.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find your protocol? '**
  String get cantFindProtocol;

  /// No description provided for @contactUsHere.
  ///
  /// In en, this message translates to:
  /// **'Contact us here'**
  String get contactUsHere;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Request a new protocol'**
  String get contactTitle;

  /// No description provided for @contactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactSubtitle;

  /// No description provided for @contactDescription.
  ///
  /// In en, this message translates to:
  /// **'Message the Clinexapp management team on WhatsApp to request adding or changing a protocol.'**
  String get contactDescription;

  /// No description provided for @contactSchedule.
  ///
  /// In en, this message translates to:
  /// **'Opening hours: 08:00 to 18:00'**
  String get contactSchedule;

  /// No description provided for @contactButton.
  ///
  /// In en, this message translates to:
  /// **'Message on WhatsApp'**
  String get contactButton;

  /// No description provided for @contactMessage.
  ///
  /// In en, this message translates to:
  /// **'I am doctor {name}, license {license}, user ID {id}. I\'d like to request a new protocol in the app.'**
  String contactMessage(String name, String license, String id);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personalInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @specialties.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialties;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'We saved your changes.'**
  String get profileUpdatedSuccess;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t log you in. Check your details and try again.'**
  String get errorLoginFailed;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the server. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem. Try again in a few minutes.'**
  String get errorServer;

  /// No description provided for @errorServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The service is unavailable right now. Try again later.'**
  String get errorServiceUnavailable;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Some details aren\'t valid. Check them and try again.'**
  String get errorValidation;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you\'re looking for.'**
  String get errorNotFound;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do this.'**
  String get errorForbidden;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Patient signature'**
  String get signature;

  /// No description provided for @errorLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the signature'**
  String get errorLoadingImage;

  /// No description provided for @paymentBonusPending.
  ///
  /// In en, this message translates to:
  /// **'You have not yet received any bonus for this patient, please wait for one of our agents to contact you.'**
  String get paymentBonusPending;

  /// No description provided for @paymentBonusCompleted.
  ///
  /// In en, this message translates to:
  /// **'You received a bonus for this patient. Continue making diagnoses and evaluations to accumulate bonuses for your services.'**
  String get paymentBonusCompleted;

  /// No description provided for @paymentMovementNotFound.
  ///
  /// In en, this message translates to:
  /// **'No payment movements found for this user, please contact support.'**
  String get paymentMovementNotFound;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @searchPatientsInvite.
  ///
  /// In en, this message translates to:
  /// **'Search Patients'**
  String get searchPatientsInvite;

  /// No description provided for @pathologiesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 condition} other{{count} conditions}}'**
  String pathologiesCount(int count);

  /// No description provided for @errorRoleReceptor.
  ///
  /// In en, this message translates to:
  /// **'This email is registered as a receptor. Please try creating an account with a new email.'**
  String get errorRoleReceptor;

  /// No description provided for @wrongRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in the wrong app'**
  String get wrongRoleTitle;

  /// No description provided for @wrongRoleMessageDerivante.
  ///
  /// In en, this message translates to:
  /// **'This app is for referring physicians, but your account belongs to a researcher. Download Clinexapp Investigador or log in with a referring physician account.'**
  String get wrongRoleMessageDerivante;

  /// No description provided for @wrongRoleExitButton.
  ///
  /// In en, this message translates to:
  /// **'Back to log in'**
  String get wrongRoleExitButton;

  /// No description provided for @notif_patient_rejected_title.
  ///
  /// In en, this message translates to:
  /// **'Patient rejected'**
  String get notif_patient_rejected_title;

  /// No description provided for @notif_patient_rejected_body.
  ///
  /// In en, this message translates to:
  /// **'{patient_name} was not accepted. Note: {notes}'**
  String notif_patient_rejected_body(String patient_name, String notes);

  /// No description provided for @notif_prospect_patient_title.
  ///
  /// In en, this message translates to:
  /// **'New prospect'**
  String get notif_prospect_patient_title;

  /// No description provided for @notif_prospect_patient_body.
  ///
  /// In en, this message translates to:
  /// **'A new patient was registered as a prospect in one of your protocols.'**
  String notif_prospect_patient_body(String patient_name);

  /// No description provided for @notif_patient_assigned_title.
  ///
  /// In en, this message translates to:
  /// **'Patient referred'**
  String get notif_patient_assigned_title;

  /// No description provided for @notif_patient_assigned_body.
  ///
  /// In en, this message translates to:
  /// **'Your patient {patient_name} was referred and will be evaluated for the study.'**
  String notif_patient_assigned_body(String patient_name);

  /// No description provided for @notif_patient_taken_title.
  ///
  /// In en, this message translates to:
  /// **'Patient in evaluation'**
  String get notif_patient_taken_title;

  /// No description provided for @notif_patient_taken_body.
  ///
  /// In en, this message translates to:
  /// **'A researcher took your patient {patient_name} for evaluation.'**
  String notif_patient_taken_body(String patient_name);

  /// No description provided for @notif_patient_accepted_title.
  ///
  /// In en, this message translates to:
  /// **'Patient accepted'**
  String get notif_patient_accepted_title;

  /// No description provided for @notif_patient_accepted_body.
  ///
  /// In en, this message translates to:
  /// **'{patient_name} was accepted for evaluation and possible participation in the study.'**
  String notif_patient_accepted_body(String patient_name);

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Refer patients to clinical trials'**
  String get welcomeHeadline;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in with your referring physician account.'**
  String get loginSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @passwordHelper.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, with uppercase, lowercase and numbers.'**
  String get passwordHelper;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover your password'**
  String get forgotPasswordTitle;

  /// No description provided for @recoveryEmailSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get recoveryEmailSentTitle;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to log in'**
  String get backToLogin;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a password you haven\'t used before.'**
  String get resetPasswordDescription;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePassword;

  /// No description provided for @passwordResetSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordResetSuccessTitle;

  /// No description provided for @registerStepProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional details'**
  String get registerStepProfessional;

  /// No description provided for @registerStepTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get registerStepTerms;

  /// No description provided for @registerProfessionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your license and specialties define which protocols you see.'**
  String get registerProfessionalSubtitle;

  /// No description provided for @registerTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read and accept the terms to create your account.'**
  String get registerTermsSubtitle;

  /// No description provided for @termsAcceptLabel.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the Clinexapp terms and conditions and the commitment I make by creating this account.'**
  String get termsAcceptLabel;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions of use'**
  String get termsTitle;

  /// No description provided for @registerSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready'**
  String get registerSuccessTitle;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get selectOption;

  /// No description provided for @selectProvince.
  ///
  /// In en, this message translates to:
  /// **'Select a province'**
  String get selectProvince;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeItem;

  /// No description provided for @sessionCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting your account ready'**
  String get sessionCheckTitle;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get successTitle;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfile;

  /// No description provided for @homeProtocolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available protocols'**
  String get homeProtocolsTitle;

  /// No description provided for @searchByCategory.
  ///
  /// In en, this message translates to:
  /// **'By specialty'**
  String get searchByCategory;

  /// No description provided for @searchProtocolHint.
  ///
  /// In en, this message translates to:
  /// **'Search by protocol name'**
  String get searchProtocolHint;

  /// No description provided for @selectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectPlaceholder;

  /// No description provided for @criteriaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 criterion} other{{count} criteria}}'**
  String criteriaCount(int count);

  /// No description provided for @noProtocolsHint.
  ///
  /// In en, this message translates to:
  /// **'Try another specialty, condition or name.'**
  String get noProtocolsHint;

  /// No description provided for @patientsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No patients yet} =1{1 patient} other{{count} patients}}'**
  String patientsCount(int count);

  /// No description provided for @searchPatientsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchPatientsHint;

  /// No description provided for @allSpecialties.
  ///
  /// In en, this message translates to:
  /// **'All specialties'**
  String get allSpecialties;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noPatientsResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try another name or specialty.'**
  String get noPatientsResultsHint;

  /// No description provided for @referPatientAction.
  ///
  /// In en, this message translates to:
  /// **'See protocols'**
  String get referPatientAction;

  /// No description provided for @allCriteriaTitle.
  ///
  /// In en, this message translates to:
  /// **'All criteria'**
  String get allCriteriaTitle;

  /// No description provided for @criteriaStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Criteria'**
  String get criteriaStepLabel;

  /// No description provided for @criteriaChecklistLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm each criterion'**
  String get criteriaChecklistLabel;

  /// No description provided for @criteriaCheckedCount.
  ///
  /// In en, this message translates to:
  /// **'{checked} of {total}'**
  String criteriaCheckedCount(int checked, int total);

  /// No description provided for @referralStepPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient details'**
  String get referralStepPatient;

  /// No description provided for @referralStepSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get referralStepSignature;

  /// No description provided for @referralStepVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get referralStepVerification;

  /// No description provided for @patientRegistrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details of the patient you\'re referring. We\'ll only use them for this protocol.'**
  String get patientRegistrationSubtitle;

  /// No description provided for @continueToSignature.
  ///
  /// In en, this message translates to:
  /// **'Continue to signature'**
  String get continueToSignature;

  /// No description provided for @datePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get datePlaceholder;

  /// No description provided for @autoFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled automatically'**
  String get autoFilled;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'History, current treatment or other useful information'**
  String get notesHint;

  /// No description provided for @signatureHandOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Hand the device to the patient'**
  String get signatureHandOverTitle;

  /// No description provided for @signatureInstructions.
  ///
  /// In en, this message translates to:
  /// **'Ask them to sign in the box below. When they\'re done, tap Continue.'**
  String get signatureInstructions;

  /// No description provided for @signatureAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Signature area'**
  String get signatureAreaLabel;

  /// No description provided for @signaturePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Sign here with your finger or a stylus'**
  String get signaturePlaceholder;

  /// No description provided for @clearSignature.
  ///
  /// In en, this message translates to:
  /// **'Clear signature'**
  String get clearSignature;

  /// No description provided for @signatureRequired.
  ///
  /// In en, this message translates to:
  /// **'Ask the patient to sign to continue.'**
  String get signatureRequired;

  /// No description provided for @continueToVerification.
  ///
  /// In en, this message translates to:
  /// **'Continue to verification'**
  String get continueToVerification;

  /// No description provided for @whatsappVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp verification'**
  String get whatsappVerificationTitle;

  /// No description provided for @whatsappVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send the patient a WhatsApp code to confirm their number.'**
  String get whatsappVerificationSubtitle;

  /// No description provided for @patientWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Patient\'s WhatsApp'**
  String get patientWhatsapp;

  /// No description provided for @importantNotice.
  ///
  /// In en, this message translates to:
  /// **'Before sending the code'**
  String get importantNotice;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @verificationCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCodeTitle;

  /// No description provided for @verificationCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code the patient received.'**
  String get verificationCodeSubtitle;

  /// No description provided for @codeNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code?'**
  String get codeNotReceived;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String resendCodeIn(String time);

  /// No description provided for @verifyAndRegister.
  ///
  /// In en, this message translates to:
  /// **'Verify and refer patient'**
  String get verifyAndRegister;

  /// No description provided for @errorVerifyingCode.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify the code. Check it and try again.'**
  String get errorVerifyingCode;

  /// No description provided for @errorSavingPatient.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t register the patient. Please try again.'**
  String get errorSavingPatient;

  /// No description provided for @patientReferredTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient referred'**
  String get patientReferredTitle;

  /// No description provided for @patientReferredMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see them in My patients with their current status.'**
  String get patientReferredMessage;

  /// No description provided for @seeMyPatients.
  ///
  /// In en, this message translates to:
  /// **'See my patients'**
  String get seeMyPatients;

  /// No description provided for @partialDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Some details are hidden for privacy.'**
  String get partialDataMessage;

  /// No description provided for @noOrderLinkedMessage.
  ///
  /// In en, this message translates to:
  /// **'When a researcher takes your patient, you\'ll see the order status and your fees here.'**
  String get noOrderLinkedMessage;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
  String get rejectionReason;

  /// No description provided for @acceptanceNotes.
  ///
  /// In en, this message translates to:
  /// **'Acceptance notes'**
  String get acceptanceNotes;

  /// No description provided for @specialtiesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 specialty} other{{count} specialties}}'**
  String specialtiesCount(int count);

  /// No description provided for @markAsInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as inactive?'**
  String get markAsInactiveTitle;

  /// No description provided for @markAsActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as active?'**
  String get markAsActiveTitle;

  /// No description provided for @markAsInactiveHelper.
  ///
  /// In en, this message translates to:
  /// **'You can change this until a researcher takes the patient.'**
  String get markAsInactiveHelper;

  /// No description provided for @markAsActiveHelper.
  ///
  /// In en, this message translates to:
  /// **'You can change this until a researcher takes the patient.'**
  String get markAsActiveHelper;

  /// No description provided for @notificationDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationDetailTitle;

  /// No description provided for @notificationDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get notificationDetails;

  /// No description provided for @noNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'We\'ll let you know here when a researcher evaluates your patients.'**
  String get noNotificationsHint;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get unread;

  /// No description provided for @specialtiesProfileHint.
  ///
  /// In en, this message translates to:
  /// **'They define which protocols you see on Home.'**
  String get specialtiesProfileHint;

  /// No description provided for @profileUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedTitle;

  /// No description provided for @licenseBadge.
  ///
  /// In en, this message translates to:
  /// **'License {license}'**
  String licenseBadge(String license);

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of Clinexapp on this device.'**
  String get logoutSubtitle;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need your email and password to log back in.'**
  String get logoutConfirmMessage;

  /// No description provided for @contactChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Have at hand'**
  String get contactChecklistTitle;

  /// No description provided for @contactChecklist1.
  ///
  /// In en, this message translates to:
  /// **'The protocol name or code.'**
  String get contactChecklist1;

  /// No description provided for @contactChecklist2.
  ///
  /// In en, this message translates to:
  /// **'The research site running it.'**
  String get contactChecklist2;

  /// No description provided for @contactChecklist3.
  ///
  /// In en, this message translates to:
  /// **'What you want to add or change.'**
  String get contactChecklist3;

  /// No description provided for @whatsappOpenError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open WhatsApp. Make sure it\'s installed and try again.'**
  String get whatsappOpenError;

  /// No description provided for @patientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientLabel;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String resultsCount(int count);
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
