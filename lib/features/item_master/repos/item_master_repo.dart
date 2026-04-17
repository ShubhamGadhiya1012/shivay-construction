import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class ItemMasterRepo {
  static Future<dynamic> addUpdateItemMaster({
    required String iCode,
    required String iName,
    required String description,
    required double rate,
    required String igCode,
    required String icCode,
    required String cCode,
    required String unit,
    required String hsnNo,
    required bool rentItem,
    required String frequency,
    required double rentRate,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "ICode": iCode,
      "IName": iName,
      "Description": description,
      "Rate": rate,
      "IGCode": igCode,
      "ICCode": icCode,
      "CCode": cCode,
      "Unit": unit,
      "HsnNo": hsnNo,
      "RentItem": rentItem,
      "Frequency": frequency,
      "RentRate": rentRate,
    };

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/addItemMaster',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
