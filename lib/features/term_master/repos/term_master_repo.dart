import 'package:shivay_construction/features/term_master/models/term_master_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class TermMasterRepo {
  static Future<List<TermMasterDm>> getTerms() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getTerms',
        queryParams: {'TermType': 'PO'},
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => TermMasterDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> addUpdateTerm({
    required Map<String, dynamic> requestBody,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/addUpdateTerms',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> deleteTerm({
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
