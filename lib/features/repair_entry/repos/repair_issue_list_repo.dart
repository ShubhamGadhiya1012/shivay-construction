import 'package:shivay_construction/features/repair_entry/models/repair_issue_dm.dart';
import 'package:shivay_construction/features/repair_entry/models/repair_issue_detail_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class RepairIssueListRepo {
  static Future<List<RepairIssueDm>> getRepairIssues({
    int pageNumber = 1,
    int pageSize = 10,
    String searchText = '',
    String status = 'All',
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Transfer/getIssueRepair',
        queryParams: {
          'PageNumber': pageNumber.toString(),
          'PageSize': pageSize.toString(),
          'SearchText': searchText,
          'Status': status,
        },
        token: token,
      );

      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => RepairIssueDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<RepairIssueDetailDm>> getRepairIssueDetails({
    required String invNo,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Transfer/getIssueRepairDtl',
        queryParams: {'Invno': invNo},
        token: token,
      );

      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => RepairIssueDetailDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
