import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shivay_construction/features/purchase_order_entry/models/auth_indent_item_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class PurchaseOrderRepo {
  static Future<List<AuthIndentItemDm>> getAuthIndentItems({
    required String siteCode,
    required String gdCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    // print(siteCode);
    // print(gdCode);
    try {
      final response = await ApiService.getRequest(
        endpoint: '/Order/getAuthIndentItems',
        queryParams: {'SiteCode': siteCode, 'GDCode': gdCode},
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => AuthIndentItemDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> savePurchaseOrder({
    required String invNo,
    required String date,
    required String gdCode,
    required String pCode,
    required String remarks,
    required String siteCode,
    required List<Map<String, dynamic>> itemData,
    required List<PlatformFile> newFiles,
    required List<String> existingAttachments,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final Map<String, String> fields = {
        'Invno': invNo,
        'Date': date,
        'GDCode': gdCode,
        'PCode': pCode,
        'Remark': remarks,
        'SiteCode': siteCode,
      };

      for (int i = 0; i < itemData.length; i++) {
        fields['ItemData[$i].SrNo'] = itemData[i]['SrNo'].toString();
        fields['ItemData[$i].ICode'] = itemData[i]['ICode'];
        fields['ItemData[$i].Unit'] = itemData[i]['Unit'];
        fields['ItemData[$i].Qty'] = itemData[i]['Qty'].toString();
        fields['ItemData[$i].IndentNo'] = itemData[i]['IndentNo'];
        fields['ItemData[$i].IndentSrNo'] = itemData[i]['IndentSrNo']
            .toString();
      }

      if (existingAttachments.isNotEmpty) {
        fields['ExistingAttachments'] = existingAttachments.join(',');
      } else {
        fields['ExistingAttachments'] = '';
      }

      final List<http.MultipartFile> multipartFiles = [];

      for (var file in newFiles) {
        if (file.path != null) {
          multipartFiles.add(
            await http.MultipartFile.fromPath(
              'Attachments',
              file.path!,
              filename: file.name,
            ),
          );
        } else if (file.bytes != null) {
          multipartFiles.add(
            http.MultipartFile.fromBytes(
              'Attachments',
              file.bytes!,
              filename: file.name,
            ),
          );
        }
      }

      // print('------ PURCHASE ORDER PAYLOAD ------');
      // fields.forEach((key, value) {
      //   print('$key : $value');
      // });

      // print('------ ATTACHMENTS ------');
      // for (var file in newFiles) {
      //   print({
      //     'name': file.name,
      //     'path': file.path,
      //     'size': file.size,
      //     'hasBytes': file.bytes != null,
      //   });
      // }
      final response = await ApiService.postFormData(
        endpoint: '/Order/orderEntry',
        fields: fields,
        files: multipartFiles,
        token: token,
      );

    //  print(response);

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
