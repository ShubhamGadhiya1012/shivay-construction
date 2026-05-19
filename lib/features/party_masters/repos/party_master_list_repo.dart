import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class PartyMasterListRepo {
  static Future<List<PartyMasterDm>> getParties({bool? isContSubCont}) async {
    String? token = await SecureStorageHelper.read('token');

    String endpoint = '/Master/getParty';

    try {
      final response = await ApiService.getRequest(
        endpoint: endpoint,
        token: token,
        queryParams: isContSubCont != null
            ? {'IsContSubCont': isContSubCont.toString()}
            : null,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => PartyMasterDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> deletePartyMaster({
    required String code,
    required String typeMast,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "Code": code,
      "TypeMast": typeMast,
    };

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/deleteMaster',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
