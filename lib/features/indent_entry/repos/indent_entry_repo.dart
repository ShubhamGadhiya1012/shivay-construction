import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class IndentEntryRepo {
  static Future<dynamic> saveIndentEntry({
    required String invNo,
    required String date,
    required String gdCode,
    required String fromDate,
    required String toDate,
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
        'FromDate': fromDate,
        'ToDate': toDate,
        'SiteCode': siteCode,
      };

      for (int i = 0; i < itemData.length; i++) {
        fields['ItemData[$i].SrNo'] = itemData[i]['SrNo'].toString();
        fields['ItemData[$i].ICode'] = itemData[i]['ICode'];
        fields['ItemData[$i].Unit'] = itemData[i]['Unit'];
        fields['ItemData[$i].Qty'] = itemData[i]['Qty'].toString();
        fields['ItemData[$i].ReqDate'] = itemData[i]['ReqDate'];
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

      // print('---- INDENT ENTRY PAYLOAD (FIELDS) ----');
      // fields.forEach((key, value) {
      //   print('$key : $value');
      // });

      // print('---- INDENT ENTRY PAYLOAD (FILES) ----');
      // for (var file in multipartFiles) {
      //   print('File field: ${file.field}');
      //   print('File name : ${file.filename}');
      //   print('File size : ${file.length}');
      // }

      // print('--------------------------------------');

      final response = await ApiService.postFormData(
        endpoint: '/Indent/indentEntry',
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
