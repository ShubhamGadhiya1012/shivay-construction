import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shivay_construction/features/purchase_order_entry/models/auth_indent_item_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/customise_voucher_po_dm.dart.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/item_tax_po_dm.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class PurchaseOrderRepo {
  static Future<List<AuthIndentItemDm>> getAuthIndentItems() async {
    String? token = await SecureStorageHelper.read('token');
    try {
      final response = await ApiService.getRequest(
        endpoint: '/Order/getAuthIndentItems',
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

  static Future<List<PurchaseOrderItemTaxDm>> getItemTax({
    required String tCode,
    required String iCode,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    print(tCode);
    print(iCode);
    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/getItemTax',
        queryParams: {'TCode': tCode, 'ICode': iCode},
        token: token,
      );
      print(response);
      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => PurchaseOrderItemTaxDm.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PurchaseOrderCustomiseVoucherDm>> getCustomiseVoucher({
    required String bookCode,
    required String dbc,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    try {
      final response = await ApiService.getRequest(
        endpoint: '/Master/customiseVoucher',
        queryParams: {'BookCode': bookCode, 'DBC': dbc},
        token: token,
      );

      if (response == null) return [];

      if (response['data'] != null) {
        return (response['data'] as List<dynamic>)
            .map((item) => PurchaseOrderCustomiseVoucherDm.fromJson(item))
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
    required String pCode,
    required String remarks,
    required String siteCode,
    required String tCode,
    required String gdCode,
    required String amount,
    required String valueOfGoods,
    required List<String> termCodes,
    required List<Map<String, dynamic>> termsData,
    required List<Map<String, dynamic>> itemData,
    required List<Map<String, dynamic>> ledgerData,
    required List<PlatformFile> newFiles,
    required List<String> existingAttachments,
  }) async {
    String? token = await SecureStorageHelper.read('token');

    try {
      final Map<String, String> fields = {
        'Invno': invNo,
        'Date': date,
        'PCode': pCode,
        'Remark': remarks,
        'SiteCode': siteCode,
        'TCode': tCode,
        'GDCode': gdCode,
        'Amount': amount,
        'ValueOfGoods': valueOfGoods,
      };

      for (int i = 0; i < termCodes.length; i++) {
        fields['TermCodes[$i]'] = termCodes[i];
      }

      for (int i = 0; i < termsData.length; i++) {
        fields['TermData[$i].Desc'] =
            termsData[i]['Description']?.toString() ?? '';
      }

      for (int i = 0; i < itemData.length; i++) {
        fields['ItemData[$i].SrNo'] = itemData[i]['SrNo'].toString();
        fields['ItemData[$i].ICode'] = itemData[i]['ICode'];
        fields['ItemData[$i].Unit'] = itemData[i]['Unit'];
        fields['ItemData[$i].Qty'] = itemData[i]['Qty'].toString();
        fields['ItemData[$i].Rate'] = (itemData[i]['Price'] ?? 0.0).toString();
        fields['ItemData[$i].Amount'] = (itemData[i]['Amount'] ?? 0.0)
            .toString();
        fields['ItemData[$i].IndentNo'] = itemData[i]['IndentNo'];
        fields['ItemData[$i].IndentSrNo'] = itemData[i]['IndentSrNo']
            .toString();
        fields['ItemData[$i].ReqDate'] = convertToApiDateFormat(
          itemData[i]['ReqDate'] ?? '',
        );
        fields['ItemData[$i].GDCode'] = itemData[i]['GDCode']?.toString() ?? '';
        fields['ItemData[$i].IndentRemark'] =
            itemData[i]['IndentRemark']?.toString() ?? '';
        fields['ItemData[$i].Dis_P'] =
            itemData[i]['Dis_P']?.toString() ?? '0.00';
        fields['ItemData[$i].Dis_A'] =
            itemData[i]['Dis_A']?.toString() ?? '0.00';
        fields['ItemData[$i].IGSTPerc'] =
            itemData[i]['IGSTPerc']?.toString() ?? '0';
        fields['ItemData[$i].SGSTPerc'] =
            itemData[i]['SGSTPerc']?.toString() ?? '0';
        fields['ItemData[$i].CGSTPerc'] =
            itemData[i]['CGSTPerc']?.toString() ?? '0';
        fields['ItemData[$i].HSNNO'] = itemData[i]['HSNNo']?.toString() ?? '';
      }

      for (int i = 0; i < ledgerData.length; i++) {
        fields['LegderData[$i].SRNO'] = ledgerData[i]['SRNO'].toString();
        fields['LegderData[$i].PERC'] = ledgerData[i]['PERC'].toString();
        fields['LegderData[$i].AMOUNT'] = ledgerData[i]['AMOUNT'].toString();
        fields['LegderData[$i].NT'] = ledgerData[i]['NT'];
        fields['LegderData[$i].PCODE'] = ledgerData[i]['PCODE'];
      }

      fields['ExistingAttachments'] = existingAttachments.isNotEmpty
          ? existingAttachments.join(',')
          : '';

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

      print("------ PURCHASE ORDER PAYLOAD ------");

      print("FIELDS:");
      fields.forEach((key, value) {
        print('$key : $value');
      });

      print("\nFILES:");
      for (var file in newFiles) {
        print('File Name: ${file.name}, Path: ${file.path}');
      }

      print("------------------------------------");
      final response = await ApiService.postFormData(
        endpoint: '/Order/orderEntry',
        fields: fields,
        files: multipartFiles,
        token: token,
      );
      print(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> updateItemHSN({
    required String iCode,
    required String hsnNo,
  }) async {
    String? token = await SecureStorageHelper.read('token');
    print(iCode);
    print(hsnNo);

    try {
      final response = await ApiService.postRequest(
        endpoint: '/Master/updateItemHSN',
        requestBody: {'ICode': iCode, 'HsnNo': hsnNo},
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
