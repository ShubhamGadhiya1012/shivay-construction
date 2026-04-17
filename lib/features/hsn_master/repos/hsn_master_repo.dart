import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class HsnMasterRepo {
  static Future<dynamic> addUpdateHsnMaster({
    required String hsnNo,
    required String orgHsnNo,
    required String chapterNo,
    required String unit,
    required String ewbUnit,
    required String description,
    required String effectDate,
    required double igst,
    required double sgst,
    required double cgst,
    required bool sac,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "HSNNO": hsnNo,
      "OrgHSNNO": orgHsnNo,
      "ChapterNo": chapterNo,
      "Unit": unit,
      "EWBUnit": ewbUnit,
      "Description": description,
      "EffectDate": effectDate,
      "IGST": igst,
      "SGST": sgst,
      "CGST": cgst,
      "SAC": sac,
    };
 //   print(requestBody);
    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/AddUpdateHSNMaster',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
