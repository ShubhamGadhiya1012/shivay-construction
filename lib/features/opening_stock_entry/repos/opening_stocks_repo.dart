import 'package:shivay_construction/features/opening_stock_entry/models/opening_stock_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class OpeningStocksRepo {
  static Future<List<OpeningStockDm>> getOpeningStocks({
    int pageNumber = 1,
    int pageSize = 10,
    String searchText = '',
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Entry/GetOpeningStock',
        queryParams: {
          'PageNumber': pageNumber.toString(),
          'PageSize': pageSize.toString(),
          'SearchText': searchText,
        },
        token: token,
      );
      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => OpeningStockDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
