import 'package:flutter/material.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';

class ErrorHandler {
  /// Parsea un mensaje de error técnico y devuelve un mensaje amigable para el usuario
  static String getErrorMessage(BuildContext context, String errorMessage) {
    final s = S.of(context);
    final lowerError = errorMessage.toLowerCase();

    // Errores de autenticación
    if (lowerError.contains('401') || lowerError.contains('unauthorized')) {
      return s.errorUnauthorized;
    }

    if (lowerError.contains('400') && lowerError.contains('login')) {
      return s.errorLoginFailed;
    }

    if (lowerError.contains('400') && lowerError.contains('credentials')) {
      return s.errorInvalidCredentials;
    }

    // Errores de red
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return s.errorNetwork;
    }

    // Errores de servidor
    if (lowerError.contains('500') ||
        lowerError.contains('internal server') ||
        lowerError.contains('server error')) {
      return s.errorServer;
    }

    if (lowerError.contains('503') ||
        lowerError.contains('service unavailable')) {
      return s.errorServiceUnavailable;
    }

    // Errores de validación
    if (lowerError.contains('400') &&
        (lowerError.contains('validation') || lowerError.contains('invalid'))) {
      return s.errorValidation;
    }

    // Error no encontrado
    if (lowerError.contains('404') || lowerError.contains('not found')) {
      return s.errorNotFound;
    }

    // Errores de permisos
    if (lowerError.contains('403') || lowerError.contains('forbidden')) {
      return s.errorForbidden;
    }

    // Error genérico si no se encuentra un match específico
    return s.errorGeneric;
  }

  /// Obtiene un mensaje de error sin contexto (usando mensajes por defecto en español)
  static String getErrorMessageWithoutContext(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();

    // Errores de autenticación
    if (lowerError.contains('401') || lowerError.contains('unauthorized')) {
      return 'Su sesión ha expirado. Por favor, inicie sesión nuevamente.';
    }

    if (lowerError.contains('400') && lowerError.contains('login')) {
      return 'No se pudo iniciar sesión. Verifique sus credenciales.';
    }

    if (lowerError.contains('400') && lowerError.contains('credentials')) {
      return 'Credenciales inválidas. Verifique su email y contraseña.';
    }

    // Errores de red
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return 'Error de conexión. Verifique su conexión a internet.';
    }

    // Errores de servidor
    if (lowerError.contains('500') ||
        lowerError.contains('internal server') ||
        lowerError.contains('server error')) {
      return 'Error del servidor. Por favor, intente más tarde.';
    }

    if (lowerError.contains('503') ||
        lowerError.contains('service unavailable')) {
      return 'El servicio no está disponible en este momento.';
    }

    // Errores de validación
    if (lowerError.contains('400') &&
        (lowerError.contains('validation') || lowerError.contains('invalid'))) {
      return 'Los datos proporcionados no son válidos.';
    }

    // Error no encontrado
    if (lowerError.contains('404') || lowerError.contains('not found')) {
      return 'El recurso solicitado no fue encontrado.';
    }

    // Errores de permisos
    if (lowerError.contains('403') || lowerError.contains('forbidden')) {
      return 'No tiene permisos para realizar esta acción.';
    }

    // Error genérico si no se encuentra un match específico
    return 'Ha ocurrido un error. Por favor, intente nuevamente.';
  }
}
