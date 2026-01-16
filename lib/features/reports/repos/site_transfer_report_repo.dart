import 'package:shivay_construction/features/reports/models/site_transfer_report_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class SiteTransferReportRepo {
  static Future<List<SiteTransferReportDm>> getSiteTransferReport({
    required String fromDate,
    required String toDate,
    required String iCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Report/siteTransferReport',
        queryParams: {'FromDate': fromDate, 'ToDate': toDate, 'ICode': iCodes},
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => SiteTransferReportDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
