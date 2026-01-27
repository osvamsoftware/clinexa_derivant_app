import 'dart:convert';
import 'dart:developer' as developer;

import 'package:clinexa_derivant_app/data/models/api_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum HttpMethod { get, post, put, delete }

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  String baseUrl = "http://10.0.2.2:8000";

  void setBaseUrl(String url) {
    baseUrl = url;
  }

  ApiService._internal() {
    _loadTokensFromPrefs();
  }

  String? _accessToken;
  String? _refreshToken;

  // ============================================================
  // 🔹 Cargar tokens desde SharedPreferences (al iniciar)
  // ============================================================
  Future<void> _loadTokensFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("derivant_access_token");
    _refreshToken = prefs.getString("derivant_refresh_token");
  }

  // ============================================================
  // 🔹 Set tokens + guardarlos en SharedPreferences
  // ============================================================
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("derivant_access_token", accessToken);
    await prefs.setString("derivant_refresh_token", refreshToken);
  }

  // ============================================================
  // 🔹 Borrar tokens del sistema + SharedPreferences
  // ============================================================
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("derivant_access_token");
    await prefs.remove("derivant_refresh_token");
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
        if (withAuth && _accessToken != null) "Authorization": _accessToken!,
      };

      developer.log("🔵 REQUEST [${method.name.toUpperCase()}] -> $uri");
      developer.log("Headers: $headers");
      if (body != null) {
        try {
          final maskedBody = _maskSensitiveData(body);
          developer.log("Body: ${jsonEncode(maskedBody)}");
        } catch (e) {
          developer.log("Body: ${jsonEncode(body)} (Error masking data)");
        }
      }

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

      developer.log("🟢 RESPONSE [${response.statusCode}] <- $uri");
      developer.log("Response Body: ${response.body}");

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
    } catch (e) {
      developer.log("🔴 EXCEPTION in request: $e", error: e);
      throw Exception("Error realizando la petición HTTP: $e");
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
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh_token": _refreshToken ?? ""}),
      );
      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);
        // Firebase devuelve 'id_token', asegúrate de usar la clave correcta que retorna tu backend
        final newAccess =
            jsonResponse["id_token"] ?? jsonResponse["access_token"];
        final newRefresh = jsonResponse["refresh_token"] ?? _refreshToken;
        // Guardar todo en memoria + prefs
        await setTokens(accessToken: newAccess, refreshToken: newRefresh);
        return true;
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
        throw ApiException("Sin permisos para esta acción.", 403);

      case 404:
        throw ApiException("Recurso no encontrado.", 404);

      case 500:
        throw ApiException("Error interno del servidor.", 500);

      default:
        throw ApiException("Error desconocido", status);
    }
  }

  // ============================================================
  // 🔹 HELPER: MASK SENSITIVE DATA
  // ============================================================
  dynamic _maskSensitiveData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final newData = Map<String, dynamic>.from(data);
      const sensitiveKeys = [
        'password',
        'token',
        'access_token',
        'refresh_token',
        'secret',
        'pass',
      ];

      for (final key in newData.keys) {
        final lowerKey = key.toLowerCase();
        // Si la clave contiene alguna palabra sensible, enmascaramos
        if (sensitiveKeys.any((s) => lowerKey.contains(s))) {
          newData[key] = "*****";
        } else {
          // Recursión para objetos anidados
          newData[key] = _maskSensitiveData(newData[key]);
        }
      }
      return newData;
    } else if (data is List) {
      return data.map((e) => _maskSensitiveData(e)).toList();
    }
    return data;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => "ApiException($statusCode): $message";
}
