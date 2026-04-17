import 'package:shivay_construction/features/reports/models/issue_repair_report_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class IssueRepairReportRepo {
  static Future<List<IssueRepairReportDm>> getIssueRepairReport({
    required String fromDate,
    required String toDate,
    required String status,
    required String pCode,
    required String siteCode,
    required String gdCode,
    required String iCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

   // print(fromDate);
  //  print(toDate);

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Report/repairReport',
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'Status': status,
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
          .map((item) => IssueRepairReportDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
