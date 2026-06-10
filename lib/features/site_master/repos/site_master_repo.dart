import 'package:shivay_construction/features/company_master/models/company_master_dm.dart';
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

  /// Fetches company list from /Master/getCompany for the Company dropdown.
  static Future<List<CompanyMasterDm>> getCompanies() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getCompany',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => CompanyMasterDm.fromJson(item))
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
    required String company,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "siteCode": siteCode,
      "siteName": siteName,
      "address1": address1,
      "address2": address2,
      "city": city,
      "state": state,
      "pinCode": pinCode,
      "phone": phone,
      "fax": fax,
      "eMail": email,
      "pan": pan,
      "gstNumber": gstNumber,
      "Company": company,
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
