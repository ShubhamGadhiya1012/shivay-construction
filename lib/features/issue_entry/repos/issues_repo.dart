import 'package:shivay_construction/features/issue_entry/models/issue_dm.dart';
import 'package:shivay_construction/features/issue_entry/models/issue_detail_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class IssuesRepo {
  static Future<List<IssueDm>> getIssues({
    int pageNumber = 1,
    int pageSize = 10,
    String searchText = '',
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Issue/getIssue',
        queryParams: {
          'PageNumber': pageNumber.toString(),
          'PageSize': pageSize.toString(),
          'SearchText': searchText,
        },
        token: token,
      );
      if (response == null) return [];
      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => IssueDm.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<IssueDetailDm>> getIssueDetails({
    required String invNo,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Issue/getIssueDtl',
        queryParams: {'Invno': invNo},
        token: token,
      );
      if (response == null) return [];
      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => IssueDetailDm.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
