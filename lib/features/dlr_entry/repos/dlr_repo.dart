import 'package:shivay_construction/features/dlr_entry/controllers/dlr_entry_controller.dart';
import 'package:shivay_construction/features/dlr_entry/models/dlr_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class DlrRepo {
  static Future<List<DlrDm>> getDlrList({
    int pageNumber = 1,
    int pageSize = 10,
    String searchText = '',
    String siteCode = '',
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final queryParams = {
        'PageNumber': pageNumber.toString(),
        'PageSize': pageSize.toString(),
        'SearchText': searchText,
        'SiteCode': siteCode,
      };

      final response = await ApiService.getRequest(
        endpoint: '/DLR/getDLR',
        token: token,
        queryParams: queryParams,
      );
      // print(response);
      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => DlrDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<ActivityDm>> getActivities() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getActivity',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => ActivityDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> saveDlrEntry({
    required String invno,
    required String date,
    required String shift,
    required String deviceId,
    required String siteCode,
    required List<Map<String, dynamic>> dlrData,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      'Invno': invno,
      'Date': date,
      'Shift': shift,
      'DeviceId': deviceId,
      'SiteCode': siteCode,
      'DLRData': dlrData,
    };
    // print(requestBody);
    try {
      var response = await ApiService.postRequest(
        endpoint: '/DLR/dlrEntry',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> deleteDlr({required String invno}) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {'Invno': invno};

    try {
      var response = await ApiService.postRequest(
        endpoint: '/DLR/deleteDLR',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
