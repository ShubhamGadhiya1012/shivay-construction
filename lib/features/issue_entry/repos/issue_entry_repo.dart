import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class IssueEntryRepo {
  static Future<dynamic> saveIssueEntry({
    required String date,
    required String siteCode,
    required String pCode,
    required String remark,
    required String refInvNo,
    required List<Map<String, dynamic>> issueItems,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final Map<String, dynamic> requestBody = {
        'Invno': '',
        'Date': date,
        'SiteCode': siteCode,
        'PCode': pCode,
        'Remark': remark,
        'RefInvno': refInvNo,
        'IssueItems': issueItems
            .map(
              (item) => {
                'ICode': item['iCode'],
                'Qty': item['qty'],
                'Rate': item['rate'],
                'GDCode': item['gdCode'],
                'CPCode': item['cpCode'],
              },
            )
            .toList(),
      };

      print('----- ISSUE PAYLOAD START -----');
      print(requestBody);
      print('----- ISSUE PAYLOAD END -----');

      final response = await ApiService.postRequest(
        endpoint: '/Issue/issueEntry',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
