import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/api_response_model.dart';
import 'package:clinexa_derivant_app/data/models/pathology_model.dart';

abstract class PathologyRepository {
  Future<ApiResponseModel<PathologyModel>> getPathologies({
    int page,
    int limit,
    String? query,
  });

  Future<PathologyModel> getPathologyById(String id);

  Future<PathologyModel> createPathology(PathologyModel pathology);

  Future<PathologyModel> updatePathology(PathologyModel pathology);

  Future<bool> deletePathology(String id);
}

class PathologyRepositoryImpl implements PathologyRepository {
  final ApiService _api = ApiService();
  final Api api;

  PathologyRepositoryImpl(this.api);

  @override
  Future<ApiResponseModel<PathologyModel>> getPathologies({
    int page = 1,
    int limit = 10,
    String? query,
  }) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: api.pathologies,
        method: HttpMethod.get,
        withAuth: true,
        query: {
          "page": page.toString(),
          "limit": limit.toString(),
          if (query != null && query.isNotEmpty) "query": query,
        },
        fromJson: (json) => json,
      );

      return ApiResponseModel<PathologyModel>(
        total: res.total,
        page: res.page,
        limit: res.limit,
        pages: res.pages,
        items: res.items?.map((e) => PathologyModel.fromMap(e)).toList(),
      );
    } catch (e) {
      print("❌ [PathologyRepository.getPathologies] $e");
      rethrow;
    }
  }

  @override
  Future<PathologyModel> getPathologyById(String id) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: "${api.pathologies}/$id",
        method: HttpMethod.get,
        withAuth: true,
        fromJson: (json) => json,
      );

      return PathologyModel.fromMap(res.data ?? {});
    } catch (e) {
      print("❌ [PathologyRepository.getPathologyById] $e");
      rethrow;
    }
  }

  @override
  Future<PathologyModel> createPathology(PathologyModel pathology) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: api.pathologies,
        method: HttpMethod.post,
        withAuth: true,
        body: pathology.toMap(),
        fromJson: (json) => json,
      );

      return PathologyModel.fromMap(res.data ?? {});
    } catch (e) {
      print("❌ [PathologyRepository.createPathology] $e");
      rethrow;
    }
  }

  @override
  Future<PathologyModel> updatePathology(PathologyModel pathology) async {
    try {
      final res = await _api.request<Map<String, dynamic>>(
        path: "${api.pathologies}/${pathology.id}",
        method: HttpMethod.put,
        withAuth: true,
        body: pathology.toMap(),
        fromJson: (json) => json,
      );

      return PathologyModel.fromMap(res.data ?? {});
    } catch (e) {
      print("❌ [PathologyRepository.updatePathology] $e");
      rethrow;
    }
  }

  @override
  Future<bool> deletePathology(String id) async {
    try {
      await _api.request(
        path: "${api.pathologies}/$id",
        method: HttpMethod.delete,
        withAuth: true,
        fromJson: (json) => json,
      );

      return true;
    } catch (e) {
      print("❌ [PathologyRepository.deletePathology] $e");
      rethrow;
    }
  }
}
