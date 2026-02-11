import 'package:shivay_construction/features/notification_master/notification_recievers/models/notification_reciever_dm.dart';
import 'package:shivay_construction/features/user_settings/models/user_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class NotificationRecieversRepo {
  static Future<List<NotificationRecieverDm>> getNotificationRecievers({
    required String nid,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Notification/receiver',
        queryParams: {'NID': nid},
        token: token,
      );
      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => NotificationRecieverDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<UserDm>> getUsers() async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/User/users',
        token: token,
      );
      if (response == null) {
        return [];
      }

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => UserDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> addReciever({
    required String userId,
    required String nid,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Notification/addReceiver',
        queryParams: {'UserId': userId, 'NID': nid},
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> removeReciever({
    required String userId,
    required String nid,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final response = await ApiService.getRequest(
        endpoint: '/Notification/removeReceiver',
        queryParams: {'UserId': userId, 'NID': nid},
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
