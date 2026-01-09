import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class GrnEntryRepo {
  static Future<dynamic> saveGrnEntry({
    required String invNo,
    required String date,
    required String gdCode,
    required String remarks,
    required String pCode,
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
        'Remarks': remarks,
        'PCode': pCode,
        'SiteCode': siteCode,
      };

      for (int i = 0; i < itemData.length; i++) {
        fields['ItemData[$i].SrNo'] = itemData[i]['SrNo'].toString();
        fields['ItemData[$i].ICode'] = itemData[i]['ICode'];
        fields['ItemData[$i].Unit'] = itemData[i]['Unit'];
        fields['ItemData[$i].Qty'] = itemData[i]['Qty'].toString();
        fields['ItemData[$i].POInvNo'] = itemData[i]['POInvNo'] ?? '';
        fields['ItemData[$i].POSrNo'] = itemData[i]['POSrNo']?.toString() ?? '';
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

      // ===== PRINT FULL PAYLOAD =====
      print('----- GRN PAYLOAD START -----');

      print('FIELDS:');
      fields.forEach((key, value) {
        print('$key : $value');
      });

      print('FILES:');
      for (var f in multipartFiles) {
        print({
          'field': f.field,
          'filename': f.filename,
          'contentType': f.contentType.toString(),
          'length': f.length,
        });
      }

      print('----- GRN PAYLOAD END -----');

      final response = await ApiService.postFormData(
        endpoint: '/GRN/grnEntry',
        fields: fields,
        files: multipartFiles,
        token: token,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
