import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/purchase_order_list_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/auth_indent_item_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/repos/purchase_order_repo.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../godown_master/repos/godown_master_repo.dart';

class PurchaseOrderController extends GetxController {
  var isLoading = false.obs;
  final purchaseOrderFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();
  var remarksController = TextEditingController();

  var selectedSiteName = ''.obs;
  var selectedSiteCode = ''.obs;

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var attachmentFiles = <PlatformFile>[].obs;
  var existingAttachmentUrls = <String>[].obs;

  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  var currentStep = 0.obs;

  var authIndentItems = <AuthIndentItemDm>[].obs;
  var isSelectionMode = false.obs;
  var expandedItemIndices = <int>[].obs;
  var selectedPurchaseItems = <Map<String, dynamic>>[].obs;

  var qtyControllers = <String, TextEditingController>{}.obs;
  var priceControllers = <String, TextEditingController>{}.obs;
  var dateControllers = <String, TextEditingController>{}.obs;

  var godowns = <dynamic>[].obs;
  var godownNames = <String>[].obs;
  var selectedGodownName = <String, String>{}.obs;
  var selectedGodownCode = <String, String>{}.obs;
  var remarkControllers = <String, TextEditingController>{}.obs;

  var lockedSiteCode = ''.obs;
  var lockedSiteName = ''.obs;

  void onPartySelected(String? partyName) {
    selectedPartyName.value = partyName!;
    var selectedPartyObj = parties.firstWhere(
      (p) => p.accountName == partyName,
    );
    selectedPartyCode.value = selectedPartyObj.pCode;
  }

  Future<void> getParties() async {
    try {
      isLoading.value = true;
      final fetchedParties = await PartyMasterListRepo.getParties();
      parties.assignAll(fetchedParties);
      partyNames.assignAll(fetchedParties.map((p) => p.accountName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGodowns() async {
    isLoading.value = true;
    try {
      final fetchedGodowns = await GodownMasterRepo.getGodowns(siteCode: '');
      godowns.assignAll(fetchedGodowns);
      godownNames.assignAll(fetchedGodowns.map((gd) => gd.gdName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onGodownSelected(String key, String? godownName) {
    selectedGodownName[key] = godownName ?? '';
    final obj = godowns.firstWhereOrNull((gd) => gd.gdName == godownName);
    selectedGodownCode[key] = obj?.gdCode ?? '';
    selectedGodownName.refresh();
    selectedGodownCode.refresh();
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

  void removeFile(int index) => attachmentFiles.removeAt(index);
  void removeExistingAttachment(int index) =>
      existingAttachmentUrls.removeAt(index);

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

  void proceedToForm() {
    if (selectedPurchaseItems.isEmpty) {
      showErrorSnackbar('Error', 'Please select at least one indent');
      return;
    }
    currentStep.value = 1;
  }

  void goBackToSelection() {
    currentStep.value = 0;
  }

  bool toggleIndentSelection(int itemIndex, int indentIndex) {
    final indent = authIndentItems[itemIndex].items[indentIndex];

    if (lockedSiteCode.value.isEmpty) {
      lockedSiteCode.value = indent.siteCode;
      lockedSiteName.value = indent.siteName;
    } else if (indent.siteCode != lockedSiteCode.value) {
      showErrorSnackbar(
        'Site Mismatch',
        'You can only select indents from "${lockedSiteName.value}". Deselect all to change site.',
      );
      return false;
    }

    indent.isSelected = !indent.isSelected;
    authIndentItems.refresh();

    _syncSelectedPurchaseItems();
    _updateLockIfNoSelection();
    _updateSelectionMode();
    return true;
  }

  void enableSelectionMode(int itemIndex, int indentIndex) {
    final indent = authIndentItems[itemIndex].items[indentIndex];
    if (lockedSiteCode.value.isNotEmpty &&
        indent.siteCode != lockedSiteCode.value) {
      showErrorSnackbar(
        'Site Mismatch',
        'You can only select indents from "${lockedSiteName.value}".',
      );
      return;
    }
    if (lockedSiteCode.value.isEmpty) {
      lockedSiteCode.value = indent.siteCode;
      lockedSiteName.value = indent.siteName;
    }
    isSelectionMode.value = true;
    indent.isSelected = true;
    authIndentItems.refresh();
    _syncSelectedPurchaseItems();
    _updateSelectionMode();
  }

  void selectAllIndents() {
    for (var item in authIndentItems) {
      for (var indent in item.items) {
        if (lockedSiteCode.value.isEmpty) {
          lockedSiteCode.value = indent.siteCode;
          lockedSiteName.value = indent.siteName;
        }
        if (indent.siteCode == lockedSiteCode.value) {
          indent.isSelected = true;
        }
      }
    }
    authIndentItems.refresh();
    _syncSelectedPurchaseItems();
    _updateSelectionMode();
  }

  void deselectAllIndents() {
    for (var item in authIndentItems) {
      for (var indent in item.items) {
        indent.isSelected = false;
      }
    }
    authIndentItems.refresh();
    lockedSiteCode.value = '';
    lockedSiteName.value = '';
    selectedPurchaseItems.clear();
    isSelectionMode.value = false;
  }

  void _updateSelectionMode() {
    bool anySelected = authIndentItems.any(
      (item) => item.items.any((indent) => indent.isSelected),
    );
    isSelectionMode.value = anySelected;
  }

  void _updateLockIfNoSelection() {
    bool anySelected = authIndentItems.any(
      (item) => item.items.any((indent) => indent.isSelected),
    );
    if (!anySelected) {
      lockedSiteCode.value = '';
      lockedSiteName.value = '';
    }
  }

  void _syncSelectedPurchaseItems() {
    selectedPurchaseItems.clear();
    int srNo = 1;
    for (var item in authIndentItems) {
      for (var indent in item.items) {
        if (indent.isSelected) {
          final key = '${item.indentNo}_${indent.indentSrNo}';
          _ensureControllers(key, indent);
          selectedPurchaseItems.add({
            'SrNo': srNo++,
            'ICode': indent.iCode,
            'iName': indent.iName,
            'Unit': 'Nos',
            'Qty':
                double.tryParse(qtyControllers[key]?.text ?? '') ??
                indent.authoriseQty,
            'Price':
                double.tryParse(priceControllers[key]?.text ?? '') ??
                indent.rate,
            'IndentNo': item.indentNo,
            'IndentSrNo': indent.indentSrNo,
            'ReqDate':
                dateControllers[key]?.text ??
                convertyyyyMMddToddMMyyyy(indent.reqDate),
            'GDCode': selectedGodownCode[key] ?? indent.gCode,
            'GDName': selectedGodownName[key] ?? indent.gdName,
            'IndentRemark': remarkControllers[key]?.text ?? indent.indentRemark,
            'SiteCode': indent.siteCode,
            'SiteName': indent.siteName,
          });
        }
      }
    }
    selectedPurchaseItems.refresh();

    if (lockedSiteCode.value.isNotEmpty) {
      selectedSiteCode.value = lockedSiteCode.value;
      selectedSiteName.value = lockedSiteName.value;
    }
  }

  void _ensureControllers(String key, IndentDm indent) {
    if (!qtyControllers.containsKey(key)) {
      qtyControllers[key] = TextEditingController(
        text: indent.authoriseQty.toStringAsFixed(2),
      );
    }
    if (!priceControllers.containsKey(key)) {
      priceControllers[key] = TextEditingController(
        text: indent.rate.toStringAsFixed(2),
      );
    }
    if (!dateControllers.containsKey(key)) {
      dateControllers[key] = TextEditingController(
        text: convertyyyyMMddToddMMyyyy(indent.reqDate),
      );
    }
    if (!selectedGodownCode.containsKey(key)) {
      selectedGodownCode[key] = indent.gCode;
      selectedGodownName[key] = indent.gdName;
    }
    if (!remarkControllers.containsKey(key)) {
      remarkControllers[key] = TextEditingController(text: indent.indentRemark);
    }
  }

  void removeSelectedItem(int index) {
    final item = selectedPurchaseItems[index];
    for (var authItem in authIndentItems) {
      for (var indent in authItem.items) {
        if (authItem.indentNo == item['IndentNo'] &&
            indent.indentSrNo == item['IndentSrNo']) {
          indent.isSelected = false;
        }
      }
    }
    authIndentItems.refresh();
    selectedPurchaseItems.removeAt(index);
    for (int i = 0; i < selectedPurchaseItems.length; i++) {
      selectedPurchaseItems[i]['SrNo'] = i + 1;
    }
    selectedPurchaseItems.refresh();
    _updateLockIfNoSelection();
    _updateSelectionMode();
  }

  Future<void> getAuthIndentItems() async {
    isLoading.value = true;
    try {
      final fetchedItems = await PurchaseOrderRepo.getAuthIndentItems();
      authIndentItems.assignAll(fetchedItems);

      expandedItemIndices.clear();
      for (int i = 0; i < fetchedItems.length; i++) {
        expandedItemIndices.add(i);
      }

      for (var item in fetchedItems) {
        for (var indent in item.items) {
          final key = '${item.indentNo}_${indent.indentSrNo}';
          if (!qtyControllers.containsKey(key)) {
            qtyControllers[key] = TextEditingController(
              text: indent.authoriseQty.toStringAsFixed(2),
            );
          }
          if (!priceControllers.containsKey(key)) {
            priceControllers[key] = TextEditingController(
              text: indent.rate.toStringAsFixed(2),
            );
          }
          if (!dateControllers.containsKey(key)) {
            dateControllers[key] = TextEditingController(
              text: convertyyyyMMddToddMMyyyy(indent.reqDate),
            );
          }
          if (!selectedGodownCode.containsKey(key)) {
            selectedGodownCode[key] = indent.gCode;
            selectedGodownName[key] = indent.gdName;
          }
          if (!remarkControllers.containsKey(key)) {
            remarkControllers[key] = TextEditingController(
              text: indent.indentRemark,
            );
          }
        }
      }

      await getGodowns();

      _reapplySelectionsFromItems();
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _reapplySelectionsFromItems() {
    for (var selectedItem in selectedPurchaseItems) {
      for (var item in authIndentItems) {
        for (var indent in item.items) {
          if (item.indentNo == selectedItem['IndentNo'] &&
              indent.indentSrNo == selectedItem['IndentSrNo']) {
            indent.isSelected = true;
            final key = '${item.indentNo}_${indent.indentSrNo}';
            qtyControllers[key]?.text = selectedItem['Qty'].toStringAsFixed(2);
            priceControllers[key]?.text = (selectedItem['Price'] ?? 0.0)
                .toStringAsFixed(2);
            if (selectedItem.containsKey('ReqDate')) {
              dateControllers[key]?.text = selectedItem['ReqDate'];
            }
            if (selectedItem.containsKey('GDCode')) {
              selectedGodownCode[key] = selectedItem['GDCode'] ?? '';
              final obj = godowns.firstWhereOrNull(
                (gd) => gd.gdCode == selectedItem['GDCode'],
              );
              selectedGodownName[key] =
                  obj?.gdName ?? selectedItem['GDName'] ?? '';
            }
            if (selectedItem.containsKey('IndentRemark')) {
              remarkControllers[key]?.text = selectedItem['IndentRemark'] ?? '';
            }
            if (lockedSiteCode.value.isEmpty) {
              lockedSiteCode.value = indent.siteCode;
              lockedSiteName.value = indent.siteName;
            }
          }
        }
      }
    }
    authIndentItems.refresh();
    _updateSelectionMode();
  }

  void toggleItemExpansion(int index) {
    if (expandedItemIndices.contains(index)) {
      expandedItemIndices.remove(index);
    } else {
      expandedItemIndices.add(index);
    }
  }

  void updateSelectedItemQty(int index, double qty) {
    if (index >= 0 && index < selectedPurchaseItems.length) {
      selectedPurchaseItems[index]['Qty'] = qty;
      selectedPurchaseItems.refresh();
    }
  }

  void updateSelectedItemPrice(int index, double price) {
    if (index >= 0 && index < selectedPurchaseItems.length) {
      selectedPurchaseItems[index]['Price'] = price;
      selectedPurchaseItems.refresh();
    }
  }

  final PurchaseOrderListController purchaseOrderListController =
      Get.find<PurchaseOrderListController>();

  Future<void> savePurchaseOrder() async {
    if (!purchaseOrderFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      if (selectedPurchaseItems.isEmpty) {
        showErrorSnackbar('Error', 'Please add at least one item');
        return;
      }
      for (var item in selectedPurchaseItems) {
        if (item['Price'] == null || item['Price'] <= 0) {
          showErrorSnackbar(
            'Error',
            'Price must be greater than 0 for all items',
          );
          return;
        }
      }

      final itemsToSave = selectedPurchaseItems.map((item) {
        final key = '${item['IndentNo']}_${item['IndentSrNo']}';
        return {
          ...item,
          'Qty':
              double.tryParse(qtyControllers[key]?.text ?? '') ?? item['Qty'],
          'Price':
              double.tryParse(priceControllers[key]?.text ?? '') ??
              item['Price'],
          'ReqDate': dateControllers[key]?.text ?? item['ReqDate'],
          'GDCode': selectedGodownCode[key] ?? item['GDCode'] ?? '',
          'IndentRemark':
              remarkControllers[key]?.text ?? item['IndentRemark'] ?? '',
        };
      }).toList();

      var response = await PurchaseOrderRepo.savePurchaseOrder(
        invNo: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),
        pCode: selectedPartyCode.value,
        remarks: remarksController.text.trim(),
        siteCode: selectedSiteCode.value,
        itemData: itemsToSave,
        newFiles: attachmentFiles.toList(),
        existingAttachments: existingAttachmentUrls.toList(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        purchaseOrderListController.getPurchaseOrders();
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
    remarksController.clear();

    selectedSiteName.value = '';
    selectedSiteCode.value = '';
    selectedPartyName.value = '';
    selectedPartyCode.value = '';
    lockedSiteCode.value = '';
    lockedSiteName.value = '';

    attachmentFiles.clear();
    existingAttachmentUrls.clear();
    authIndentItems.clear();
    selectedPurchaseItems.clear();

    for (var c in remarkControllers.values) {
      c.dispose();
    }
    for (var c in qtyControllers.values) {
      c.dispose();
    }
    for (var c in priceControllers.values) {
      c.dispose();
    }
    for (var c in dateControllers.values) {
      c.dispose();
    }

    remarkControllers.clear();
    qtyControllers.clear();
    priceControllers.clear();
    dateControllers.clear();

    selectedGodownName.clear();
    selectedGodownCode.clear();
    godowns.clear();
    godownNames.clear();

    currentStep.value = 0;
    isEditMode.value = false;
    isSelectionMode.value = false;
    expandedItemIndices.clear();
  }
}
