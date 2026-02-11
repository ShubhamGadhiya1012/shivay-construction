import 'package:shivay_construction/features/reports/models/dlr_report_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class DlrReportRepo {
  static Future<List<DlrReportDm>> getDlrReport({
    required String fromDate,
    required String toDate,
    required String pCode,
    required String siteCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Report/dlrReport',
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'PCode': pCode,
          'SiteCode': siteCode,
        },
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => DlrReportDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
