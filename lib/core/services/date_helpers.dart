import 'package:intl/intl.dart';

class TripHelpers {
  String getCity(String locationString) {
    final parts = locationString.split(',').map((e) => e.trim()).toList();
    if (parts.length < 3) {
      throw const FormatException('La cadena debe tener el formato "ciudad, estado, país"');
    }
    return parts[0]; // La ciudad está en la primera posición
  }

  String getState(String locationString) {
    final parts = locationString.split(',').map((e) => e.trim()).toList();

    if (parts.length < 3) {
      throw const FormatException('La cadena debe tener el formato "ciudad, estado, país"');
    }
    return parts[1]; // El estado está en la segunda posición
  }

  String getCountry(String locationString) {
    final parts = locationString.split(',').map((e) => e.trim()).toList();

    if (parts.length < 3) {
      throw const FormatException('La cadena debe tener el formato "ciudad, estado, país"');
    }
    return parts[2]; // El estado está en la segunda posición
  }

  String formatDate(DateTime date) {
    // Establecer el idioma (opcional si el sistema ya usa español)
    Intl.defaultLocale = 'es_ES';

    // Crear el formateador
    final DateFormat formatter = DateFormat('d \'de\' MMMM \'de\' y');

    // Formatear la fecha
    return formatter.format(date);
  }
}

final TripHelpers tripHelpers = TripHelpers();
