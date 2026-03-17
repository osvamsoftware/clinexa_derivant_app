import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/api_response_model.dart';
import 'package:clinexa_derivant_app/data/models/protocol_model.dart';

abstract class ProtocolRepository {
  Future<ApiResponseModel<ProtocolModel>> getProtocols({
    int page = 1,
    int limit = 10,
    String? query,
    String? specialty,
    String? pathology,
  });

  Future<ProtocolModel> getProtocolById(String id);

  Future<ApiResponseModel<ProtocolModel>> getProtocolsByCategories({
    required int page,
    required int limit,
    List<String>? specialties,
    List<String>? pathologies,
  });

  Future<ProtocolModel> createProtocol(ProtocolModel protocol);

  Future<ProtocolModel> updateProtocol(ProtocolModel protocol);

  Future<bool> deleteProtocol(String id);

  Future<List<ProtocolModel>> getProtocolsByIds(List<String> ids);
}

/// =============================================================
/// IMPLEMENTACIÓN OFICIAL (ApiService unificado)
/// =============================================================
class ProtocolRepositoryImpl implements ProtocolRepository {
  final ApiService _api = ApiService();
  final Api api;

  ProtocolRepositoryImpl(this.api);

  // =============================================================
  // 🔹 GET ALL PROTOCOLS (paginated + filters)
  // =============================================================
  @override
  Future<ApiResponseModel<ProtocolModel>> getProtocols({
    int page = 1,
    int limit = 10,
    String? query,
    String? specialty,
    String? pathology,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (query != null && query.isNotEmpty) 'query': query,
        if (specialty != null && specialty.isNotEmpty) 'specialty': specialty,
        if (pathology != null && pathology.isNotEmpty) 'pathology': pathology,
      };

      return await _api.request(
        path: api.protocols,
        method: HttpMethod.get,
        query: queryParams,
        withAuth: true,
        fromJson: (json) => ProtocolModel.fromMap(json),
      );
    } catch (e) {
      print("❌ [ProtocolRepositoryImpl.getProtocols] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 GET BY ID
  // =============================================================
  @override
  Future<ProtocolModel> getProtocolById(String id) async {
    try {
      final response = await _api.request(
        path: "${api.protocols}/$id",
        method: HttpMethod.get,
        withAuth: true,
        fromJson: (json) => ProtocolModel.fromMap(json),
      );

      return response.data!;
    } catch (e) {
      print("❌ [ProtocolRepositoryImpl.getProtocolById] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 CREATE
  // =============================================================
  @override
  Future<ProtocolModel> createProtocol(ProtocolModel protocol) async {
    try {
      final payload = {
        'name': protocol.name.trim(),
        'description': protocol.description.trim(),
        'specialties': protocol.specialties
            .map((s) => {'id': s.id, 'collection': 'specialties'})
            .toList(),
        'pathologies': protocol.pathologies
            .map((p) => {'id': p.id, 'collection': 'pathologies'})
            .toList(),
        'criteria': protocol.criteria.map((c) => c.toMap()).toList(),
        'status': protocol.status.toString(),
        'created_by': protocol.createdBy,
      };

      final response = await _api.request(
        path: api.protocols,
        method: HttpMethod.post,
        body: payload,
        withAuth: true,
        fromJson: (json) => ProtocolModel.fromMap(json),
      );

      return response.data!;
    } catch (e) {
      print("❌ [ProtocolRepositoryImpl.createProtocol] $e");
      rethrow;
    }
  }

  @override
  Future<ApiResponseModel<ProtocolModel>> getProtocolsByCategories({
    required int page,
    required int limit,
    List<String>? specialties,
    List<String>? pathologies,
  }) async {
    try {
      final queryParams = {
        "page": page.toString(),
        "limit": limit.toString(),
        if (specialties != null && specialties.isNotEmpty)
          "specialties": specialties,
        if (pathologies != null && pathologies.isNotEmpty)
          "pathologies": pathologies,
      };

      final response = await _api.request(
        path: "${api.protocols}/filter/by-categories",
        method: HttpMethod.get,
        query: queryParams,
        fromJson: (json) => ProtocolModel.fromMap(json),
        withAuth: true,
      );

      return response;
    } catch (e) {
      print("❌ [ProtocolRepositoryImpl.getProtocolsByCategories] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 UPDATE
  // =============================================================
  @override
  Future<ProtocolModel> updateProtocol(ProtocolModel protocol) async {
    try {
      final payload = {
        'name': protocol.name.trim(),
        'description': protocol.description.trim(),
        'specialties': protocol.specialties
            .map((s) => {'id': s.id, 'collection': 'specialties'})
            .toList(),
        'pathologies': protocol.pathologies
            .map((p) => {'id': p.id, 'collection': 'pathologies'})
            .toList(),
        'criteria': protocol.criteria.map((c) => c.toMap()).toList(),
        'status': protocol.status.toString(),
        'created_by': protocol.createdBy,
      };

      final response = await _api.request(
        path: "${api.protocols}/${protocol.id}",
        method: HttpMethod.put,
        body: payload,
        withAuth: true,
        fromJson: (json) => ProtocolModel.fromMap(json),
      );

      return response.data!;
    } catch (e) {
      print("❌ [ProtocolRepositoryImpl.updateProtocol] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 DELETE
  // =============================================================
  @override
  Future<bool> deleteProtocol(String id) async {
    try {
      await _api.request(
        path: "${api.protocols}/$id",
        method: HttpMethod.delete,
        withAuth: true,
        fromJson: (json) => ProtocolModel.fromMap(json),
      );
      return true;
    } catch (e) {
      print("❌ [ProtocolRepositoryImpl.deleteProtocol] $e");
      rethrow;
    }
  }

  @override
  Future<List<ProtocolModel>> getProtocolsByIds(List<String> ids) async {
    try {
      // Construimos la parte del query string manualmente
      final queryString = ids.map((id) => "ids=$id").join("&");

      final response = await _api.request(
        path: "${api.protocols}/filter/by-ids?$queryString",
        method: HttpMethod.get,
        withAuth: true,
        fromJson: (json) => ProtocolModel.fromMap(json),
      );

      return response.items!;
    } catch (e) {
      print("❌ Error in getProtocolsByIds: $e");
      rethrow;
    }
  }
}

///protocols/filter/by-ids?ids=692f6228bb750ccc2e08d98a%2C692f6187bb750ccc2e08d988
///protocols/filter/by-ids?ids=692f6228bb750ccc2e08d98a&ids=692f6187bb750ccc2e08d988
