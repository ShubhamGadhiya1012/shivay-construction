import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/indent_entry/controllers/indents_controller.dart';
import 'package:shivay_construction/features/indent_entry/repos/indent_entry_repo.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_list_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class IndentEntryController extends GetxController {
  var isLoading = false.obs;
  final indentFormKey = GlobalKey<FormState>();
  final indentItemFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();

  var sites = <SiteMasterDm>[].obs;
  var siteNames = <String>[].obs;
  var selectedSiteName = ''.obs;
  var selectedSiteCode = ''.obs;

  var items = <ItemMasterDm>[].obs;
  var itemNames = <String>[].obs;
  var selectedItemName = ''.obs;
  var selectedItemCode = ''.obs;
  var selectedUnit = ''.obs;

  var reqDateController = TextEditingController();
  var qtyController = TextEditingController();

  var itemsToSend = <Map<String, dynamic>>[].obs;
  var isEditingItem = false.obs;
  var editingItemIndex = (-1).obs;

  var attachmentFiles = <PlatformFile>[].obs;
  var existingAttachmentUrls = <String>[].obs;

  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  Future<void> getSites() async {
    try {
      isLoading.value = true;
      final fetchedSites = await SiteMasterListRepo.getSites();
      sites.assignAll(fetchedSites);
      siteNames.assignAll(fetchedSites.map((s) => s.siteName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSiteSelected(String? siteName) {
    selectedSiteName.value = siteName!;
    var selectedSiteObj = sites.firstWhere((s) => s.siteName == siteName);
    selectedSiteCode.value = selectedSiteObj.siteCode;
  }

  Future<void> getItems() async {
    try {
      isLoading.value = true;
      final fetchedItems = await ItemMasterListRepo.getItems();
      items.assignAll(fetchedItems);
      itemNames.assignAll(fetchedItems.map((item) => item.iName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onItemSelected(String? itemName) {
    selectedItemName.value = itemName!;
    var selectedItemObj = items.firstWhere((item) => item.iName == itemName);
    selectedItemCode.value = selectedItemObj.iCode;
    selectedUnit.value = selectedItemObj.unit;
    qtyController.clear();
  }

  void prepareAddItem() {
    clearItemForm();
    isEditingItem.value = false;
    editingItemIndex.value = -1;
  }

  void prepareEditItem(int index) {
    isLoading.value = true;
    try {
      final item = itemsToSend[index];
      selectedItemName.value = item['iname'] ?? '';
      selectedItemCode.value = item['icode'] ?? item['ICode'] ?? '';
      selectedUnit.value = item['unit'] ?? item['Unit'] ?? '';
      qtyController.text = (item['qty'] ?? item['Qty'] ?? 0).toString();

      final reqDate = item['ReqDate']?.toString() ?? '';
      reqDateController.text = reqDate.isNotEmpty
          ? _convertyyyyMMddToddMMyyyy(reqDate)
          : '';

      isEditingItem.value = true;
      editingItemIndex.value = index;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void clearItemForm() {
    selectedItemName.value = '';
    selectedItemCode.value = '';
    selectedUnit.value = '';
    qtyController.clear();
    reqDateController.clear();
  }

  void addOrUpdateItem() {
    double qty = double.tryParse(qtyController.text) ?? 0;

    if (!isEditingItem.value) {
      final isDuplicate = itemsToSend.any(
        (item) => item['ICode'] == selectedItemCode.value,
      );

      if (isDuplicate) {
        showErrorSnackbar(
          'Duplicate Item',
          'This item is already added. Please select a different item.',
        );
        return;
      }
    }

    Map<String, dynamic> itemData = {
      "SrNo": isEditingItem.value
          ? itemsToSend[editingItemIndex.value]["SrNo"]
          : itemsToSend.length + 1,
      "ICode": selectedItemCode.value,
      "iname": selectedItemName.value,
      "Unit": selectedUnit.value,
      "Qty": qty,
      "ReqDate": _convertToApiDateFormat(reqDateController.text),
    };

    if (isEditingItem.value) {
      itemsToSend[editingItemIndex.value] = itemData;
    } else {
      itemsToSend.add(itemData);
    }

    _reassignSrNo();
    Get.back();
  }

  void deleteItem(int index) {
    if (index >= 0 && index < itemsToSend.length) {
      itemsToSend.removeAt(index);
      _reassignSrNo();
    }
  }

  void _reassignSrNo() {
    for (int i = 0; i < itemsToSend.length; i++) {
      itemsToSend[i]["SrNo"] = i + 1;
    }
  }

  Future<void> pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        final File file = File(photo.path);
        final bytes = await file.readAsBytes();

        final platformFile = PlatformFile(
          name: photo.name,
          size: bytes.length,
          path: photo.path,
          bytes: bytes,
        );

        attachmentFiles.add(platformFile);
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to capture image: ${e.toString()}');
    }
  }

  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'xls',
          'xlsx',
        ],
      );

      if (result != null) {
        attachmentFiles.addAll(result.files);
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to pick files: ${e.toString()}');
    }
  }

  void removeFile(int index) {
    attachmentFiles.removeAt(index);
  }

  void removeExistingAttachment(int index) {
    existingAttachmentUrls.removeAt(index);
  }

  Future<void> openAttachment(String fileUrl) async {
    String url =
        '${ApiService.kBaseUrl.replaceAll('/api', '')}/${fileUrl.replaceAll('\\', '/')}';

    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          showErrorSnackbar('Error', 'Could not open attachment');
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to open attachment: ${e.toString()}');
    }
  }

  String _convertToApiDateFormat(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  String _convertyyyyMMddToddMMyyyy(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  final IndentsController indentsController = Get.find<IndentsController>();

  Future<void> saveIndentEntry() async {
    isLoading.value = true;

    try {
      var response = await IndentEntryRepo.saveIndentEntry(
        invNo: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),

        siteCode: selectedSiteCode.value,
        itemData: itemsToSend.toList(),
        newFiles: attachmentFiles.toList(),
        existingAttachments: existingAttachmentUrls.toList(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        indentsController.getIndents();
        Get.back();
        showSuccessSnackbar('Success', message);
        clearAll();
      }
    } catch (e) {
      if (e is Map<String, dynamic>) {
        showErrorSnackbar('Error', e['message']);
      } else {
        showErrorSnackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void clearAll() {
    currentInvNo.value = '';
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    selectedSiteName.value = '';
    selectedSiteCode.value = '';

    itemsToSend.clear();
    attachmentFiles.clear();
    existingAttachmentUrls.clear();

    isEditMode.value = false;
  }
}
