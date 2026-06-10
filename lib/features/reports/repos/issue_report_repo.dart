import 'package:shivay_construction/features/reports/models/issue_report_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class IssueReportRepo {
  static Future<List<IssueReportDm>> getIssueReport({
    required String fromDate,
    required String toDate,
    required String pCode,
    required String gdCode,
    required String iCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Issue/getIssueReport',
        requestBody: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'PCode': pCode,
          'GDCode': gdCode,
          'ICode': iCode,
        },
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => IssueReportDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
