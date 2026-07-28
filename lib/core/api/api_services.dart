import 'dart:convert';
import 'dart:developer' as developer;

import 'package:clinexa_derivant_app/core/config/app_config.dart';
import 'package:clinexa_derivant_app/core/services/secure_token_storage.dart';
import 'package:clinexa_derivant_app/data/models/api_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum HttpMethod { get, post, put, delete }

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // La URL llega por --dart-define; antes se cambiaba comentando líneas.
  String baseUrl = AppConfig.apiBaseUrl;

  void setBaseUrl(String url) {
    baseUrl = url;
  }

  ApiService._internal();

  final SecureTokenStorage _tokenStorage = SecureTokenStorage();

  String? _accessToken;
  String? _refreshToken;

  /// Registro solo en debug: los logs del dispositivo no deben contener
  /// tokens ni cuerpos de respuesta con datos de pacientes.
  void _debugLog(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'API');
    }
  }

  // ============================================================
  // 🔹 Tokens (Keychain / Keystore, nunca SharedPreferences)
  // ============================================================
  Future<void> _loadTokensFromPrefs() async {
    _accessToken ??= await _tokenStorage.readAccessToken();
    _refreshToken ??= await _tokenStorage.readRefreshToken();
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _tokenStorage.clear();
  }

  // ============================================================
  // 🔹 REQUEST PRINCIPAL
  // ============================================================
  Future<ApiResponseModel<T>> request<T>({
    required String path,
    required T Function(Map<String, dynamic>) fromJson,
    HttpMethod method = HttpMethod.get,
    Map<String, dynamic>? query,
    dynamic body,
    bool withAuth = true,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: query);

      // Cargar tokens desde prefs si aún no están
      if (_accessToken == null || _refreshToken == null) {
        await _loadTokensFromPrefs();
      }

      final headers = {
        "Content-Type": "application/json",
        if (withAuth && _accessToken != null)
          "Authorization": "Bearer $_accessToken",
      };

      _debugLog("➡️ ${method.name.toUpperCase()} ${uri.path}");

      http.Response response;

      switch (method) {
        case HttpMethod.get:
          response = await http.get(uri, headers: headers);
          break;

        case HttpMethod.post:
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;

        case HttpMethod.put:
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;

        case HttpMethod.delete:
          response = await http.delete(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
      }

      _debugLog("⬅️ ${response.statusCode} ${uri.path}");

      // ============================================================
      // 🔄 REFRESH TOKEN AUTOMÁTICO
      // ============================================================
      if (response.statusCode == 401 && withAuth && _refreshToken != null) {
        final refreshed = await _tryRefreshToken();

        if (refreshed) {
          return await request(
            path: path,
            fromJson: fromJson,
            method: method,
            query: query,
            body: body,
            withAuth: withAuth,
          );
        }
      }

      return _handleResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      _debugLog("❌ Error de red");
      throw Exception("Error realizando la petición HTTP");
    }
  }

  // ============================================================
  // 🔹 REQUEST LIST
  // ============================================================
  Future<ApiResponseModel<List<T>>> requestList<T>({
    required String path,
    required T Function(Map<String, dynamic>) fromJson,
    HttpMethod method = HttpMethod.get,
    Map<String, dynamic>? query,
    dynamic body,
    bool withAuth = true,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: query);

      if (_accessToken == null || _refreshToken == null) {
        await _loadTokensFromPrefs();
      }

      final headers = {
        "Content-Type": "application/json",
        if (withAuth && _accessToken != null)
          "Authorization": "Bearer $_accessToken",
      };

      _debugLog("➡️ LIST ${method.name.toUpperCase()} ${uri.path}");

      http.Response response;

      switch (method) {
        case HttpMethod.get:
          response = await http.get(uri, headers: headers);
          break;
        case HttpMethod.post:
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case HttpMethod.put:
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case HttpMethod.delete:
          response = await http.delete(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
      }

      _debugLog("⬅️ LIST ${response.statusCode} ${uri.path}");

      if (response.statusCode == 401 && withAuth && _refreshToken != null) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return await requestList(
            path: path,
            fromJson: fromJson,
            method: method,
            query: query,
            body: body,
            withAuth: withAuth,
          );
        }
      }

      return _handleListResponse<T>(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      _debugLog("❌ Error de red (lista)");
      throw Exception("Error realizando la petición HTTP (List)");
    }
  }

  // ============================================================
  // 🔹 REFRESH TOKEN
  // ============================================================
  Future<bool> _tryRefreshToken() async {
    try {
      final uri = Uri.parse("$baseUrl/refresh");
      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Refresh-Token": _refreshToken ?? "",
        },
        body: jsonEncode({"refresh_token": _refreshToken ?? ""}),
      );
      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);
        // Firebase devuelve 'id_token', asegúrate de usar la clave correcta que retorna tu backend
        final newAccess =
            jsonResponse["id_token"] ?? jsonResponse["access_token"];
        final newRefresh = jsonResponse["refresh_token"] ?? _refreshToken;
        // Guardar todo en memoria + prefs
        if (newAccess == null || newRefresh == null) return false;
        await setTokens(accessToken: newAccess, refreshToken: newRefresh);
        return true;
      }
      // Si el refresh falla, la sesión ya no sirve.
      if (res.statusCode == 401 || res.statusCode == 403) {
        await clearTokens();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 🔹 HANDLE RESPONSE
  // ============================================================
  // ============================================================
  // 🔹 HANDLE RESPONSE (versión mejorada con status + message)
  // ============================================================
  ApiResponseModel<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final int status = response.statusCode;

    final Map<String, dynamic> jsonBody = jsonDecode(
      response.body.isNotEmpty ? response.body : "{}",
    );

    final String? message = jsonBody["message"] ?? jsonBody["detail"];

    switch (status) {
      case 200:
      case 201:
        if (jsonBody["items"] == null && jsonBody["total"] == null) {
          return ApiResponseModel.single(fromJson(jsonBody), message, status);
        }
        return ApiResponseModel.list(
          jsonBody,
          fromJson,
          message: message,
          statusCode: status,
        );

      case 400:
        throw ApiException(message ?? "Solicitud inválida", 400);

      case 401:
        throw ApiException("Token inválido o expirado.", 401);

      case 403:
        throw ApiException(message ?? "Sin permisos para esta acción.", 403);

      case 404:
        throw ApiException("Recurso no encontrado.", 404);

      case 422:
        throw ApiException(message ?? "Datos inválidos.", 422);

      case 429:
        throw ApiException(
          "Demasiados intentos. Espera un momento e inténtalo de nuevo.",
          429,
        );

      case 500:
        throw ApiException("Error interno del servidor.", 500);

      default:
        throw ApiException("Error desconocido", status);
    }
  }

  // ============================================================
  // 🔹 HANDLE LIST RESPONSE
  // ============================================================
  ApiResponseModel<List<T>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final int status = response.statusCode;

    // For lists, the backend might return an array directly instead of {items: []}
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body.isNotEmpty ? response.body : "[]");
    } catch (e) {
      jsonBody = [];
    }

    String? message;
    if (jsonBody is Map<String, dynamic>) {
      message = jsonBody["message"] ?? jsonBody["detail"];
    }

    switch (status) {
      case 200:
      case 201:
        if (jsonBody is List) {
          final List<T> dataList = jsonBody
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponseModel.single(dataList, null, status);
        } else if (jsonBody is Map<String, dynamic>) {
          final List<T> dataList = [];
          if (jsonBody["items"] is List) {
            final itemsList = jsonBody["items"] as List;
            dataList.addAll(
              itemsList.map((item) => fromJson(item as Map<String, dynamic>)),
            );
          }
          return ApiResponseModel.single(dataList, message, status);
        }
        return ApiResponseModel.single([], message, status);

      case 400:
        throw ApiException(message ?? "Solicitud inválida", 400);

      case 401:
        throw ApiException("Token inválido o expirado.", 401);

      case 403:
        throw ApiException(message ?? "Sin permisos para esta acción.", 403);

      case 404:
        throw ApiException("Recursos no encontrados.", 404);

      case 422:
        throw ApiException(message ?? "Datos inválidos.", 422);

      case 429:
        throw ApiException(
          "Demasiados intentos. Espera un momento e inténtalo de nuevo.",
          429,
        );

      case 500:
        throw ApiException("Error interno del servidor.", 500);

      default:
        throw ApiException("Error desconocido", status);
    }
  }

}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => "ApiException($statusCode): $message";
}
