import 'package:clinexa_derivant_app/core/config/app_config.dart';

/// La URL del backend viene de `API_BASE_URL` en el archivo `.env`.
/// Antes se elegía comentando y descomentando líneas, con el riesgo de
/// publicar una build apuntando al entorno equivocado.
Future<Api> createApiInstance() async {
  final baseUrl = AppConfig.apiBaseUrl;
  return Api(
    baseUrl: baseUrl,
    socketUrl: '$baseUrl/',
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

  // ELIMINADO: GET /verification/code/{phone}
  // Devolvía el código de verificación de cualquier teléfono sin
  // autenticación, lo que anulaba la verificación telefónica.

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
