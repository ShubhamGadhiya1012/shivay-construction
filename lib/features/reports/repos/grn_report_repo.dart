import 'package:shivay_construction/features/reports/models/grn_report_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class GrnReportRepo {
  static Future<List<GrnReportDm>> getGrnReport({
    required String fromDate,
    required String toDate,
    required String pCode,
    required String siteCode,
    required String gdCode,
    required String iCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Report/grnReport',
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'PCode': pCode,
          'SiteCode': siteCode,
          'GDCode': gdCode,
          'ICode': iCodes,
        },
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => GrnReportDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
