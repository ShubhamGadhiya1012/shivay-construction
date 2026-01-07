import 'package:shivay_construction/features/party_masters/models/city_dm.dart';
import 'package:shivay_construction/features/party_masters/models/location_dm.dart';
import 'package:shivay_construction/features/party_masters/models/state_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class PartyMasterRepo {
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

  static Future<List<LocationDm>> getLocations() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getLocation',
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => LocationDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

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

  static Future<dynamic> addUpdatePartyMaster({
    required String pCode,
    required String accountName,
    required String printName,
    required String location,
    required String addressLine1,
    required String addressLine2,
    required String addressLine3,
    required String city,
    required String state,
    required String pinCode,
    required String personName,
    required String phone1,
    required String phone2,
    required String mobile,
    required String gstNumber,
    required String panNumber,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    final Map<String, dynamic> requestBody = {
      "PCode": pCode,
      "AccountName": accountName,
      "PrintName": printName,
      "Location": location,
      "AddressLine1": addressLine1,
      "AddressLine2": addressLine2,
      "AddressLine3": addressLine3,
      "City": city,
      "State": state,
      "PinCode": pinCode,
      "PersonName": personName,
      "Phone1": phone1,
      "Phone2": phone2,
      "Mobile": mobile,
      "GSTNumber": gstNumber,
      "PANNumber": panNumber,
    };

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/addPartyMaster',
        requestBody: requestBody,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
