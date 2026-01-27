import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/api_response_model.dart';
import 'package:clinexa_derivant_app/data/models/specialty_model.dart';

abstract class SpecialtyRepository {
  Future<ApiResponseModel<SpecialtyModel>> getSpecialties({
    int page,
    int limit,
    String? query,
  });

  Future<SpecialtyModel> getSpecialtyById(String id);

  Future<SpecialtyModel> createSpecialty(SpecialtyModel specialty);

  Future<SpecialtyModel> updateSpecialty(SpecialtyModel specialty);

  Future<bool> deleteSpecialty(String id);
}

/// =============================================================
/// 🔹 Implementation (ADAPTADA A ApiService.request)
/// =============================================================
class SpecialtyRepositoryImpl implements SpecialtyRepository {
  final ApiService _api = ApiService();
  final Api api;

  SpecialtyRepositoryImpl(this.api);

  // =============================================================
  // 🔹 GET ALL (paginated)
  // =============================================================
  @override
  Future<ApiResponseModel<SpecialtyModel>> getSpecialties({
    int page = 1,
    int limit = 10,
    String? query,
  }) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: api.specialties,
        method: HttpMethod.get,
        withAuth: true,
        query: {
          "page": page.toString(),
          "limit": limit.toString(),
          if (query != null && query.isNotEmpty) "query": query,
        },
        fromJson: (json) => json,
      );

      return ApiResponseModel<SpecialtyModel>(
        total: res.total,
        page: res.page,
        limit: res.limit,
        pages: res.pages,
        items: res.items?.map((e) => SpecialtyModel.fromMap(e)).toList(),
      );
    } catch (e) {
      print("❌ [SpecialtyRepository.getSpecialties] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 GET BY ID
  // =============================================================
  @override
  Future<SpecialtyModel> getSpecialtyById(String id) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: "${api.specialties}/$id",
        method: HttpMethod.get,
        withAuth: true,
        fromJson: (json) => json,
      );

      return SpecialtyModel.fromMap(res.data ?? {});
    } catch (e) {
      print("❌ [SpecialtyRepository.getSpecialtyById] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 CREATE
  // =============================================================
  @override
  Future<SpecialtyModel> createSpecialty(SpecialtyModel specialty) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: api.specialties,
        method: HttpMethod.post,
        withAuth: true,
        body: specialty.toMap(),
        fromJson: (json) => json,
      );

      return SpecialtyModel.fromMap(res.data ?? {});
    } catch (e) {
      print("❌ [SpecialtyRepository.createSpecialty] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 UPDATE
  // =============================================================
  @override
  Future<SpecialtyModel> updateSpecialty(SpecialtyModel specialty) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: "${api.specialties}/${specialty.id}",
        method: HttpMethod.put,
        withAuth: true,
        body: specialty.toMap(),
        fromJson: (json) => json,
      );

      return SpecialtyModel.fromMap(res.data ?? {});
    } catch (e) {
      print("❌ [SpecialtyRepository.updateSpecialty] $e");
      rethrow;
    }
  }

  // =============================================================
  // 🔹 DELETE
  // =============================================================
  @override
  Future<bool> deleteSpecialty(String id) async {
    try {
      await _api.request(
        path: "${api.specialties}/$id",
        method: HttpMethod.delete,
        withAuth: true,
        fromJson: (json) => json, // ← aunque delete no usa data
      );

      return true;
    } catch (e) {
      print("❌ [SpecialtyRepository.deleteSpecialty] $e");
      rethrow;
    }
  }
}
