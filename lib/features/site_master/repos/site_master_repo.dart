import 'package:shivay_construction/features/party_masters/models/city_dm.dart';
import 'package:shivay_construction/features/party_masters/models/state_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class SiteMasterRepo {
  static Future<List<CityDm>> getCities() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getCity',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => CityDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<StateDm>> getStates() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getState',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => StateDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> addUpdateSiteMaster({
    required String siteCode,
    required String siteName,
    required String address1,
    required String address2,
    required String city,
    required String state,
    required String pinCode,
    required String phone,
    required String fax,
    required String email,
    required String pan,
    required String gstNumber,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "SiteCode": siteCode,
      "SiteName": siteName,
      "Address1": address1,
      "Address2": address2,
      "City": city,
      "State": state,
      "PinCode": pinCode,
      "Phone": phone,
      "Fax": fax,
      "EMail": email,
      "Pan": pan,
      "GSTNumber": gstNumber,
    };  

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/addSiteMaster',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
