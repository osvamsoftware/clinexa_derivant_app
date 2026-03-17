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
  /// **'Sharing Health'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'A digital platform designed to connect researchers or teams from medical research centers with referring physicians in a secure and transparent manner, facilitating patient access to clinical research protocols.'**
  String get welcomeDescription;

  /// No description provided for @loginHello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get loginHello;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
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
  /// **'Log In'**
  String get login;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin;

  /// No description provided for @passwordMax.
  ///
  /// In en, this message translates to:
  /// **'Password must be less than 20 characters'**
  String get passwordMax;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
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
  /// **'Please enter a valid number with more than 6 digits.'**
  String get invalidDni;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorOccurred;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
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
  /// **'Medical License Number'**
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
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @searchSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Search specialty'**
  String get searchSpecialty;

  /// No description provided for @register_step1_title.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get register_step1_title;

  /// No description provided for @register_firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get register_firstName;

  /// No description provided for @register_lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
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
  /// **'Next'**
  String get register_next;

  /// No description provided for @register_basicInfo_description.
  ///
  /// In en, this message translates to:
  /// **'Enter your basic information to continue.'**
  String get register_basicInfo_description;

  /// No description provided for @register_header.
  ///
  /// In en, this message translates to:
  /// **'Create your medical account and join our network of specialists. Enter your personal, medical, and location information, choose your specialties, and complete your profile to start receiving requests from clinics and institutions safely and efficiently.'**
  String get register_header;

  /// No description provided for @specialty_required.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one of your specialties.'**
  String get specialty_required;

  /// No description provided for @register_successMessage.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. You can now log in!'**
  String get register_successMessage;

  /// No description provided for @error400.
  ///
  /// In en, this message translates to:
  /// **'Bad Request (400)'**
  String get error400;

  /// No description provided for @error401.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized (401)'**
  String get error401;

  /// No description provided for @error403.
  ///
  /// In en, this message translates to:
  /// **'Access Denied (403)'**
  String get error403;

  /// No description provided for @error404.
  ///
  /// In en, this message translates to:
  /// **'Resource Not Found (404)'**
  String get error404;

  /// No description provided for @error408.
  ///
  /// In en, this message translates to:
  /// **'Request Timeout (408)'**
  String get error408;

  /// No description provided for @error500.
  ///
  /// In en, this message translates to:
  /// **'Internal Server Error (500)'**
  String get error500;

  /// No description provided for @error503.
  ///
  /// In en, this message translates to:
  /// **'Service Unavailable (503)'**
  String get error503;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get errorUnknown;

  /// No description provided for @errorGenericMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while processing your request. Please try again.'**
  String get errorGenericMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
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
  /// **'Pathology'**
  String get pathology;

  /// No description provided for @selectPathology.
  ///
  /// In en, this message translates to:
  /// **'Select pathology'**
  String get selectPathology;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
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
  /// **'Protocol Details'**
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
  /// **'Error loading protocols'**
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
  /// **'Select the protocol to which you want to add the patient and make sure it meets all the acceptance criteria.'**
  String get protocolSelectionSubtitle;

  /// No description provided for @continue_text.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_text;

  /// No description provided for @protocolCriteriaVerificationInfo.
  ///
  /// In en, this message translates to:
  /// **'We will guide you through a quick verification to ensure the patient meets all necessary criteria for this protocol.'**
  String get protocolCriteriaVerificationInfo;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Hi, WelcomeBack'**
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
  /// **'Pathology'**
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
  /// **'Register Patient'**
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
  /// **'Birth Date'**
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
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @medicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
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
  /// **'Criteria not met'**
  String get criteriaNotMet;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
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
  /// **'Next / Register'**
  String get nextRegister;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @searchSpecialtyHint.
  ///
  /// In en, this message translates to:
  /// **'Search specialty...'**
  String get searchSpecialtyHint;

  /// No description provided for @searchPathologyHint.
  ///
  /// In en, this message translates to:
  /// **'Search pathology...'**
  String get searchPathologyHint;

  /// No description provided for @notAllCriteriaMet.
  ///
  /// In en, this message translates to:
  /// **'Not all criteria met for this protocol.'**
  String get notAllCriteriaMet;

  /// No description provided for @myPatients.
  ///
  /// In en, this message translates to:
  /// **'My Patients'**
  String get myPatients;

  /// No description provided for @noPatientsFound.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFound;

  /// No description provided for @patientCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Patient created successfully'**
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
  /// **'Pay to see full data'**
  String get payForFullData;

  /// No description provided for @hiddenField.
  ///
  /// In en, this message translates to:
  /// **'Hidden field'**
  String get hiddenField;

  /// No description provided for @rejectPatient.
  ///
  /// In en, this message translates to:
  /// **'Reject Patient'**
  String get rejectPatient;

  /// No description provided for @acceptAndPayFinal.
  ///
  /// In en, this message translates to:
  /// **'Accept and Pay 90%'**
  String get acceptAndPayFinal;

  /// No description provided for @attachProof.
  ///
  /// In en, this message translates to:
  /// **'Attach proof (optional)'**
  String get attachProof;

  /// No description provided for @paymentInitialSuccess.
  ///
  /// In en, this message translates to:
  /// **'Initial payment processed. You can now see the patient\'s full data.'**
  String get paymentInitialSuccess;

  /// No description provided for @paymentFinalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Final payment processed. Patient accepted in treatment.'**
  String get paymentFinalSuccess;

  /// No description provided for @orderRejected.
  ///
  /// In en, this message translates to:
  /// **'Patient rejected successfully'**
  String get orderRejected;

  /// No description provided for @orderStatusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
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
  /// **'Patient Details'**
  String get patientDetails;

  /// No description provided for @patientEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Patient Evaluation'**
  String get patientEvaluation;

  /// No description provided for @fullData.
  ///
  /// In en, this message translates to:
  /// **'Full Data'**
  String get fullData;

  /// No description provided for @partialData.
  ///
  /// In en, this message translates to:
  /// **'Partial Data'**
  String get partialData;

  /// No description provided for @confirmReject.
  ///
  /// In en, this message translates to:
  /// **'Confirm rejection?'**
  String get confirmReject;

  /// No description provided for @confirmRejectMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this patient? This action cannot be undone.'**
  String get confirmRejectMessage;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @acceptPatient.
  ///
  /// In en, this message translates to:
  /// **'Accept Patient'**
  String get acceptPatient;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @attachDocuments.
  ///
  /// In en, this message translates to:
  /// **'Attach documents'**
  String get attachDocuments;

  /// No description provided for @noDocumentsAttached.
  ///
  /// In en, this message translates to:
  /// **'No documents attached'**
  String get noDocumentsAttached;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocol;

  /// No description provided for @provinceState.
  ///
  /// In en, this message translates to:
  /// **'Province/State'**
  String get provinceState;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Clinexa'**
  String get appName;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address...'**
  String get searchAddress;

  /// No description provided for @errorSelectingFiles.
  ///
  /// In en, this message translates to:
  /// **'Error selecting files'**
  String get errorSelectingFiles;

  /// No description provided for @orderCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully'**
  String get orderCreatedSuccessfully;

  /// No description provided for @fullDataAvailableAfterPayment.
  ///
  /// In en, this message translates to:
  /// **'Full patient data is available after initial payment'**
  String get fullDataAvailableAfterPayment;

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
  /// **'Select a valid address'**
  String get selectValidAddress;

  /// No description provided for @errorVerifyingUserStatus.
  ///
  /// In en, this message translates to:
  /// **'Error verifying user status'**
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
  /// **'Postal Code'**
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
  /// **'Mark as Inactive'**
  String get markAsInactive;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get confirmAction;

  /// No description provided for @confirmMarkAsInactive.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this patient as inactive? This action can be reversed later.'**
  String get confirmMarkAsInactive;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @noOrderLinked.
  ///
  /// In en, this message translates to:
  /// **'No order linked'**
  String get noOrderLinked;

  /// No description provided for @markAsActive.
  ///
  /// In en, this message translates to:
  /// **'Mark as Active'**
  String get markAsActive;

  /// No description provided for @confirmMarkAsActive.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this patient as active?'**
  String get confirmMarkAsActive;

  /// No description provided for @licenseType.
  ///
  /// In en, this message translates to:
  /// **'License Type'**
  String get licenseType;

  /// No description provided for @provincialLicense.
  ///
  /// In en, this message translates to:
  /// **'Provincial License'**
  String get provincialLicense;

  /// No description provided for @nationalLicense.
  ///
  /// In en, this message translates to:
  /// **'National License'**
  String get nationalLicense;

  /// No description provided for @phone2.
  ///
  /// In en, this message translates to:
  /// **'Phone 2'**
  String get phone2;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you instructions to reset your password.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendInstructions.
  ///
  /// In en, this message translates to:
  /// **'Send Instructions'**
  String get sendInstructions;

  /// No description provided for @recoveryEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password recovery email sent. Please check your inbox.'**
  String get recoveryEmailSent;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. You can now log in with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @notificationScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationScreenTitle;

  /// No description provided for @noNotificationsFound.
  ///
  /// In en, this message translates to:
  /// **'No notifications found'**
  String get noNotificationsFound;

  /// No description provided for @notificationMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'Notification marked as read'**
  String get notificationMarkedAsRead;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
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
  /// **'Protocol Connection'**
  String get contactTitle;

  /// No description provided for @contactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactSubtitle;

  /// No description provided for @contactDescription.
  ///
  /// In en, this message translates to:
  /// **'You are about to contact the management department. Please make sure you have the protocols you want to add or modify at hand.'**
  String get contactDescription;

  /// No description provided for @contactSchedule.
  ///
  /// In en, this message translates to:
  /// **'Business hours: 08:00 - 18:00'**
  String get contactSchedule;

  /// No description provided for @contactButton.
  ///
  /// In en, this message translates to:
  /// **'Contact now'**
  String get contactButton;

  /// No description provided for @contactMessage.
  ///
  /// In en, this message translates to:
  /// **'I am doctor {name} with license {license} and user ID {id}, I would like to request the registration of a new protocol in the app'**
  String contactMessage(Object id, Object license, Object name);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @specialties.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialties;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get errorLoginFailed;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please check your email and password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please check your internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The service is currently unavailable.'**
  String get errorServiceUnavailable;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'The provided data is not valid.'**
  String get errorValidation;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found.'**
  String get errorNotFound;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errorForbidden;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred. Please try again.'**
  String get errorGeneric;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Patient Signature'**
  String get signature;

  /// No description provided for @errorLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error loading signature image'**
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
