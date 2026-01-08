import 'package:shivay_construction/features/department_master/models/department_master_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class DepartmentMasterRepo {
  static Future<List<DepartmentMasterDm>> getDepartments() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getDepartment',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => DepartmentMasterDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> addUpdateDepartment({
    required String dCode,
    required String dName,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {"DCode": dCode, "DName": dName};

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/addDepartmentMaster',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> deleteDepartment({
    required String code,
    required String typeMast,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "Code": code,
      "TypeMast": typeMast,
    };

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/deleteMaster',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
