import 'package:shivay_construction/features/indent_entry/models/indent_dm.dart';
import 'package:shivay_construction/features/indent_entry/models/indent_detail_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class IndentsRepo {
  static Future<List<IndentDm>> getIndents({
    int pageNumber = 1,
    int pageSize = 10,
    String searchText = '',
    String status = 'ALL',
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Indent/GetIndent',
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
            .map((item) => IndentDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<IndentDetailDm>> getIndentDetails({
    required String invNo,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Indent/getIndentDtl',
        queryParams: {'Invno': invNo},
        token: token,
      );
      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => IndentDetailDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> authorizeIndent({
    required String invNo,
    required List<Map<String, dynamic>> itemAuthData,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "Invno": invNo,
      "ItemAuthData": itemAuthData,
    };
  //  print(requestBody);
    try {
      var response = await ApiService.postRequest(
        endpoint: '/Indent/indentAuth',
        requestBody: requestBody,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
