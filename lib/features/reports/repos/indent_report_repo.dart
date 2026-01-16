import 'package:shivay_construction/features/reports/models/indent_report_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class IndentReportRepo {
  static Future<List<IndentReportDm>> getIndentReport({
    required String fromDate,
    required String toDate,
    required String status,
    required String siteCode,
    required String gdCode,
    required String iCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Report/indentReport',
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'Status': status,
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
          .map((item) => IndentReportDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
