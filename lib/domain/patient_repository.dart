import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<String> uploadSignature(Uint8List signatureData);

  Future<void> sendVerificationCode(String phone);

  Future<bool> verifyCode(String phone, String code);

  Future<String?> getExpectedCode(String phone);
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

  // =============================================================
  // 🔹 UPLOAD SIGNATURE (Mocked)
  // =============================================================
  // =============================================================
  // 🔹 UPLOAD SIGNATURE
  // =============================================================
  @override
  Future<String> uploadSignature(Uint8List signatureData) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      log("🚀 STARTING SIGNATURE UPLOAD: $timestamp");
      log("📦 Size: ${signatureData.lengthInBytes} bytes");
      print(Firebase.app().options.projectId);
      print(Firebase.app().options.storageBucket);

      final ref = FirebaseStorage.instance.ref().child(
        'signatures/signature_$timestamp.png',
      );
      log("📍 Reference created: ${ref.fullPath}");

      final metadata = SettableMetadata(contentType: 'image/png');

      final uploadTask = ref.putData(signatureData, metadata);

      // Listen to events for debugging
      uploadTask.snapshotEvents.listen((event) {
        log(
          '📸 Upload progress: ${event.bytesTransferred}/${event.totalBytes} (${(event.bytesTransferred / event.totalBytes * 100).toStringAsFixed(2)}%) - State: ${event.state}',
        );
      }, onError: (e) => log("❌ Upload stream error: $e"));

      log("⏳ Awaiting upload task...");
      // Using timeout to prevent infinite hang
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          log("❌ Upload timed out!");
          uploadTask.cancel();
          throw Exception("Upload timed out");
        },
      );

      log("🎉 Snapshot received. State: ${snapshot.state}");

      if (snapshot.state != TaskState.success) {
        throw Exception("Upload failed with state: ${snapshot.state}");
      }

      log("⏳ Getting download URL...");
      final downloadUrl = await snapshot.ref.getDownloadURL();

      log("✅ SIGNATURE UPLOAD SUCCESS → $downloadUrl");
      return downloadUrl;
    } catch (e, stack) {
      log("❌ SIGNATURE UPLOAD ERROR", error: e, stackTrace: stack);
      throw Exception('Error uploading signature: $e');
    }
  }

  // =============================================================
  // 🔹 SEND VERIFICATION CODE
  // =============================================================
  @override
  Future<void> sendVerificationCode(String phone) async {
    try {
      log("📩 SEND VERIFICATION CODE REQUEST → $phone");

      await apiService.request<dynamic>(
        path: api.verificationSendCode,
        method: HttpMethod.post,
        body: {"phone": phone},
        fromJson: (json) => json,
      );

      log("✅ CODE SENT SUCCESS");
    } catch (e, stack) {
      log("❌ SEND CODE ERROR", error: e, stackTrace: stack);
      rethrow;
    }
  }

  // =============================================================
  // 🔹 VERIFY CODE
  // =============================================================
  @override
  Future<bool> verifyCode(String phone, String code) async {
    try {
      log("📩 VERIFY CODE REQUEST → $phone, $code");

      await apiService.request<dynamic>(
        path: api.verificationVerifyCode,
        method: HttpMethod.post,
        body: {"phone": phone, "code": code},
        fromJson: (json) => json,
      );

      log("✅ VERIFICATION SUCCESS");
      return true;
    } catch (e) {
      log("❌ VERIFICATION ERROR: $e");
      return false;
    }
  }

  // =============================================================
  // 🔹 GET EXPECTED CODE (FOR TESTING)
  // =============================================================
  @override
  Future<String?> getExpectedCode(String phone) async {
    try {
      log("📩 GET EXPECTED CODE REQUEST → $phone");

      final response = await apiService.request<dynamic>(
        path: api.verificationGetCode(phone),
        method: HttpMethod.get,
        fromJson: (json) => json,
      );

      log("✅ GET EXPECTED CODE RESPONSE → ${response.data}");
      // Adjust according to the backend response format: {"success": True, "code": "..."}
      return response.data?["code"]?.toString();
    } catch (e) {
      log("❌ GET EXPECTED CODE ERROR: $e");
      return null;
    }
  }
}

