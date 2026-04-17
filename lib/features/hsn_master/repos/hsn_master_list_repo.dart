import 'package:shivay_construction/features/hsn_master/models/hsn_master_dm.dart';
import 'package:shivay_construction/features/hsn_master/models/hsn_master_detail_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class HsnMasterListRepo {
  static Future<List<HsnMasterDm>> getHsnList() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/GetHSNMaster',
        token: token,
      );

      if (response == null || response['data'] == null) return [];

      return (response['data'] as List<dynamic>)
          .map((item) => HsnMasterDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<HsnMasterDetailDm>> getHsnDetail({
    required String hsnNo,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/GetHSNMasterDtl?HSNNO=$hsnNo',
        token: token,
      );

      if (response == null || response['data'] == null) return [];

      return (response['data'] as List<dynamic>)
          .map((item) => HsnMasterDetailDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> deleteHsn({required String hsnno}) async {
    String? token = await SecureStorageHelper.read('token');

    final queryParams = {"HSNNO": hsnno};

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/DeleteHSN',
        queryParams: queryParams,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
