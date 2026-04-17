import 'package:shivay_construction/features/dlr_entry/models/dlr_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class DlrRepo {
  static Future<List<DlrDm>> getDlrList({
    int pageNumber = 1,
    int pageSize = 10,
    String searchText = '',
    String pCode = '',
    String siteCode = '',
    String gdCode = '',
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final queryParams = {
        'PageNumber': pageNumber.toString(),
        'PageSize': pageSize.toString(),
        'SearchText': searchText,
        'PCode': pCode,
        'SiteCode': siteCode,
        'GDCode': gdCode,
      };

      final response = await ApiService.getRequest(
        endpoint: '/DLR/getDLR',
        token: token,
        queryParams: queryParams,
      );

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

  static Future<dynamic> saveDlrEntry({
    required String invno,
    required String pCode,
    required String date,
    required String shift,
    required double skill,
    required double skillRate,
    required double unSkill,
    required double unSkillRate,
    required int supervisor,
    required String deviceId,
    required String siteCode,
    required String gdCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      'Invno': invno,
      'PCode': pCode,
      'Date': date,
      'Shift': shift,
      'Skill': skill,
      'SkillRate': skillRate,
      'UnSkill': unSkill,
      'UnSkillRate': unSkillRate,
      'Supervisor': supervisor,
      'DeviceId': deviceId,
      'SiteCode': siteCode,
      'GDCode': gdCode,
    };

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
