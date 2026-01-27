import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get googleMapsKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}
