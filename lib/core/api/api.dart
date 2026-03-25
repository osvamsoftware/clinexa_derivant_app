import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Api> createApiInstance() async {
  // String baseUrl = "http://18.225.7.38:8000";

  // // Try to get URL from env first
  String baseUrl = dotenv.env['API_URL'] ?? '';
  String socketUrl = '';

  if (baseUrl.isNotEmpty) {
    // If URL doesn't end with /api, we might need to adjust or assume the env var is the full root
    socketUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
  } else {
    // Determine base URL based on platform and device type
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      if (!androidInfo.isPhysicalDevice) {
        // Android Emulator
        baseUrl = 'http://10.0.2.2:8000';
      } else {
        // Android Physical Device
        baseUrl = 'http://10.0.2.2:8000';
      }
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        // iOS Simulator
        baseUrl = 'http://localhost:8000';
      } else {
        // iOS Physical Device
        baseUrl = 'http://localhost:8000';
      }
    } else {
      // Fallback for other platforms
      baseUrl = 'http://10.0.2.2:8000';
    }
  }
  // baseUrl = 'https://api.clinexapp.com';
  // baseUrl = 'http://localhost:8000';
  // baseUrl = 'http://192.168.170.46:8000';
  socketUrl = '$baseUrl/';
  return Api(
    baseUrl: baseUrl,
    socketUrl: socketUrl,
    googleMapsBaseUrl: 'https://maps.googleapis.com/maps/api',
  );
}

class Api {
  final String googleMapsBaseUrl;
  final String baseUrl;
  final String socketUrl;

  //!--- DECLARE
  Api({
    required this.baseUrl,
    required this.googleMapsBaseUrl,
    required this.socketUrl,
  });

  //!--- GOOGLE MAPS
  String _constructMapsUrl(String path) => '$googleMapsBaseUrl$path';
  String _constructApiUrl(String path) => '$baseUrl$path';

  //--
  static const String _googleMapsDistanceMatrixUrl = '/distancematrix';
  String get googleMapsDistanceMatrixUrl =>
      _constructMapsUrl(_googleMapsDistanceMatrixUrl);

  //! -- AUTH
  // -- login
  static const String _login = '/login';
  String get login => _constructApiUrl(_login);
  // -- register
  static const String _register = '/register';
  String get register => _constructApiUrl(_register);
  // -- me
  static const String _me = '/me';
  String get me => _constructApiUrl(_me);
  // -- refresh
  static const String _refresh = '/refresh';
  String get refresh => _constructApiUrl(_refresh);
  //-- specialities
  static const String _specialties = '/specialties';
  String get specialties => _constructApiUrl(_specialties);

  static const String _locationCountries = '/location/countries';
  String get locationCountries => _constructApiUrl(_locationCountries);

  static const String _locationStates = '/location/states';
  String get locationStates => _constructApiUrl(_locationStates);

  static const String _locationCitiesByState = '/location/by-state';
  String get locationCitiesByState => _constructApiUrl(_locationCitiesByState);

  //user
  static const String _user = '/user';
  String get user => _constructApiUrl(_user);

  //protocols
  static const String _protocols = '/protocols';
  String get protocols => _constructApiUrl(_protocols);

  //user
  static const String _users = '/users';
  String get users => _constructApiUrl(_users);

  //patients
  static const String _patients = '/patients';
  String get patients => _constructApiUrl(_patients);

  //device token
  static const String _deviceToken = '/notifications/register-device';
  String get deviceToken => _constructApiUrl(_deviceToken);

  //google
  static const String _googleAutocomplete =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  String get googleAutocomplete => _googleAutocomplete;

  static const String _googlePlaceDetails =
      'https://maps.googleapis.com/maps/api/place/details/json';
  String get googlePlaceDetails => _googlePlaceDetails;

  //pathologies
  static const String _pathologies = '/pathologies';
  String get pathologies => _constructApiUrl(_pathologies);

  //orders
  static const String _orders = '/orders';
  String get orders => _constructApiUrl(_orders);

  //payments
  static const String _payments = '/payments';
  String get payments => _constructApiUrl(_payments);

  //auth
  static const String _passwordRecovery = '/password-recovery';
  String get passwordRecovery => _constructApiUrl(_passwordRecovery);

  //notifications
  static const String _notifications = '/notifications';
  String get notifications => _constructApiUrl(_notifications);

  String getUserNotifications(String userId) =>
      _constructApiUrl('/notifications/$userId');
  String markNotificationRead(String notificationId) =>
      _constructApiUrl('/notifications/$notificationId/read');

  //verification
  static const String _verificationSendCode = '/verification/send-code';
  String get verificationSendCode => _constructApiUrl(_verificationSendCode);

  static const String _verificationVerifyCode = '/verification/verify-code';
  String get verificationVerifyCode =>
      _constructApiUrl(_verificationVerifyCode);

  static const String _verificationGetCode = '/verification/code';
  String verificationGetCode(String phone) =>
      _constructApiUrl('$_verificationGetCode/$phone');

  //check email
  static const String _checkEmail = '/check-email';
  String get checkEmail => _constructApiUrl(_checkEmail);

  //payment movements
  static const String _paymentMovements = '/payment-movements';
  String get paymentMovements => _constructApiUrl(_paymentMovements);

  String getPaymentMovementsByOrder(String orderId) =>
      _constructApiUrl('/payment-movements/by-order/$orderId');
}

// final apiBase = Api(
//   //
//   // baseUrl: 'http://18.118.15.245:8000/api',
//   baseUrl: 'http://192.168.0.196:8000/api',
//   // baseUrl: 'http://10.0.2.2:80000.2.2:8000/api',
//   googleMapsBaseUrl: 'https://maps.googleapis.com/maps/api',
// );
