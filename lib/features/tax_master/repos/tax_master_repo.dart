import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class TaxMasterRepo {
  static Future<dynamic> addUpdateTaxMaster({
    required String tCode,
    required String taxName,
    required bool igst,
    required bool cgst,
    required bool sgst,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "TCode": tCode,
      "TName": taxName,
      "IGST": igst,
      "CGST": cgst,
      "SGST": sgst,
    };

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/addUpdateTax',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
