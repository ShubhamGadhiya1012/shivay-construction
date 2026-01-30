import 'package:shivay_construction/features/site_transfer/models/site_transfer_dm.dart';
import 'package:shivay_construction/features/site_transfer/models/site_transfer_detail_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class SiteTransferListRepo {
  static Future<List<SiteTransferDm>> getSiteTransfers({
    int pageNumber = 1,
    int pageSize = 10,
    String searchText = '',
    String status = 'All',
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Transfer/getSiteTransfer',
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
            .map((item) => SiteTransferDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<SiteTransferDetailDm>> getSiteTransferDetails({
    required String invNo,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Transfer/getSiteTransferDtl',
        queryParams: {'Invno': invNo},
        token: token,
      );

      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => SiteTransferDetailDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
