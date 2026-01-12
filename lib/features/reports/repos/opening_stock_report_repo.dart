import 'package:shivay_construction/features/reports/models/opening_stock_report_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class OpeningStockReportRepo {
  static Future<List<OpeningStockReportDm>> getOpeningStockReport({
    required String fromDate,
    required String toDate,
    required String siteCode,
    required String iCodes,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Report/openingStockReport',
        queryParams: {
          'FromDate': fromDate,
          'ToDate': toDate,
          'SiteCode': siteCode,
          'ICode': iCodes,
        },
        token: token,
      );

      if (response == null || response['data'] == null) {
        return [];
      }

      return (response['data'] as List<dynamic>)
          .map((item) => OpeningStockReportDm.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
