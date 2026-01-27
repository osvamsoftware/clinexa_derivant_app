import 'dart:developer';

import 'package:clinexa_derivant_app/core/api/api.dart';
import 'package:clinexa_derivant_app/core/api/api_services.dart';
import 'package:clinexa_derivant_app/data/models/patient_model.dart';

abstract interface class PatientRepository {
  Future<PatientModel> create(PatientModel patient);

  Future<List<PatientModel>> getAll({
    int page = 1,
    int limit = 10,
    String? createdBy,
    String? status,
    String? search,
    String? specialtyId,
  });

  Future<PatientModel> getById(String id);

  Future<PatientModel> update(String id, PatientModel patient);

  Future<List<PatientModel>> searchByCreatorSpecialty({
    required String createdBy,
    required String specialtyId,
    String? search,
    int page = 1,
    int limit = 10,
  });

  Future<void> delete(String id);
}

class PatientRepositoryImpl implements PatientRepository {
  final ApiService apiService = ApiService();
  final Api api;

  PatientRepositoryImpl(this.api);

  // =============================================================
  // 🔹 CREATE
  // =============================================================
  @override
  Future<PatientModel> create(PatientModel patient) async {
    try {
      log("📩 CREATE PATIENT REQUEST → ${patient.toMap()}");

      final response = await apiService.request<PatientModel>(
        path: api.patients,
        method: HttpMethod.post,
        body: patient.toMap(),
        fromJson: (json) => PatientModel.fromMap(json),
      );

      log("✅ CREATE PATIENT RESPONSE → ${response.data}");

      if (response.data == null) {
        throw Exception("Error creating patient: Response data is null");
      }

      return response.data!;
    } catch (e, stack) {
      log("❌ CREATE PATIENT ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 GET ALL
  // =============================================================
  @override
  Future<List<PatientModel>> getAll({
    int page = 1,
    int limit = 10,
    String? createdBy,
    String? status,
    String? search,
    String? specialtyId,
  }) async {
    try {
      log("📩 GET ALL PATIENTS REQUEST (Page: $page, Limit: $limit)");

      final query = {
        "page": page.toString(),
        "limit": limit.toString(),
        if (createdBy != null) "created_by": createdBy,
        if (status != null) "status": status,
        if (search != null && search.isNotEmpty) "search": search,
        if (specialtyId != null && specialtyId.isNotEmpty)
          "specialty_id": specialtyId,
      };

      final response = await apiService.request<PatientModel>(
        path: api.patients,
        method: HttpMethod.get,
        query: query,
        fromJson: (json) => PatientModel.fromMap(json),
      );

      log("✅ GET ALL PATIENTS RESPONSE → ${response.items?.length} items");

      return response.items ?? [];
    } catch (e, stack) {
      log("❌ GET ALL PATIENTS ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 GET BY ID
  // =============================================================
  @override
  Future<PatientModel> getById(String id) async {
    try {
      log("📩 GET PATIENT BY ID REQUEST → $id");

      final response = await apiService.request<PatientModel>(
        path: "${api.patients}/$id",
        method: HttpMethod.get,
        fromJson: (json) => PatientModel.fromMap(json),
      );

      log("✅ GET PATIENT RESPONSE → ${response.data}");

      if (response.data == null) {
        throw Exception("Patient not found");
      }

      return response.data!;
    } catch (e, stack) {
      log("❌ GET PATIENT BY ID ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 UPDATE
  // =============================================================
  @override
  Future<PatientModel> update(String id, PatientModel patient) async {
    try {
      log("📩 UPDATE PATIENT REQUEST → $id");

      final response = await apiService.request<PatientModel>(
        path: "${api.patients}/$id",
        method: HttpMethod.put,
        body: patient.toMap(),
        fromJson: (json) => PatientModel.fromMap(json),
      );

      log("✅ UPDATE PATIENT RESPONSE → ${response.data}");

      if (response.data == null) {
        throw Exception("Error updating patient");
      }

      return response.data!;
    } catch (e, stack) {
      log("❌ UPDATE PATIENT ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 DELETE
  // =============================================================
  @override
  Future<void> delete(String id) async {
    try {
      log("📩 DELETE PATIENT REQUEST → $id");

      await apiService.request<dynamic>(
        path: "${api.patients}/$id",
        method: HttpMethod.delete,
        fromJson: (json) => json, // Ignoramos respuesta
      );

      log("✅ DELETE PATIENT SUCCESS");
    } catch (e, stack) {
      log("❌ DELETE PATIENT ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 SEARCH BY CREATOR & SPECIALTY
  // =============================================================
  @override
  Future<List<PatientModel>> searchByCreatorSpecialty({
    required String createdBy,
    required String specialtyId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      log(
        "📩 SEARCH PATIENTS BY CREATOR & SPECIALTY REQUEST (Page: $page, Limit: $limit)",
      );

      final query = {
        "created_by": createdBy,
        "specialty_id": specialtyId,
        "page": page.toString(),
        "limit": limit.toString(),
        if (search != null && search.isNotEmpty) "search": search,
      };

      final response = await apiService.request<PatientModel>(
        path: "${api.patients}/created/filter",
        method: HttpMethod.get,
        query: query,
        fromJson: (json) => PatientModel.fromMap(json),
      );

      log("✅ SEARCH RESULTS → ${response.items?.length} items");

      return response.items ?? [];
    } catch (e, stack) {
      log("❌ SEARCH ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }
}
