import 'package:shivay_construction/features/party_masters/models/city_dm.dart';
import 'package:shivay_construction/features/party_masters/models/state_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class CompanyMasterRepo {
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

  static Future<dynamic> addUpdateCompanyMaster({
    required int coCode,
    required String name,
    required String address1,
    required String address2,
    required String city,
    required String zip,
    required String state,
    required String country,
    required String pan,
    required String phone,
    required String fax,
    required String email,
    required String url,
    required String gstNumber,
    required String cinNo,
    required String msmeNo,
    required String uan,
    required String ptCode,
    required String estCode,
    required String pfCode,
    required String esiCode,
    required String mgmtEmail,
    required String coBankName1,
    required String coBankBranch1,
    required String coBankAcNo1,
    required String coBankIfsc1,
    required String coBankName2,
    required String coBankBranch2,
    required String coBankAcNo2,
    required String coBankIfsc2,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "COCODE": coCode,
      "NAME": name,
      "ADDRESS1": address1,
      "ADDRESS2": address2,
      "CITY": city,
      "ZIP": zip,
      "STATE": state,
      "COUNTRY": country,
      "PAN": pan,
      "PHONE": phone,
      "FAX": fax,
      "EMAIL": email,
      "URL": url,
      "GSTNUMBER": gstNumber,
      "CINNO": cinNo,
      "MSMENO": msmeNo,
      "UAN": uan,
      "PTCODE": ptCode,
      "ESTCODE": estCode,
      "PFCODE": pfCode,
      "ESICODE": esiCode,
      "MgmtEMail": mgmtEmail,
      "COBANKNAME1": coBankName1,
      "COBANKBRANCH1": coBankBranch1,
      "COBANKACNO1": coBankAcNo1,
      "COBANKIFSC1": coBankIfsc1,
      "COBANKNAME2": coBankName2,
      "COBANKBRANCH2": coBankBranch2,
      "COBANKACNO2": coBankAcNo2,
      "COBANKIFSC2": coBankIfsc2,
    };

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/addUpdateCompany',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
