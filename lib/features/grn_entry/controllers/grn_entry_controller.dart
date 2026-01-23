import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/grn_entry/controllers/grns_controller.dart';
import 'package:shivay_construction/features/grn_entry/models/grn_detail_dm.dart';
import 'package:shivay_construction/features/grn_entry/models/po_auth_item_dm.dart';
import 'package:shivay_construction/features/grn_entry/repos/grn_entry_repo.dart';
import 'package:shivay_construction/features/grn_entry/repos/po_auth_items_repo.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_list_repo.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class GrnEntryController extends GetxController {
  var isLoading = false.obs;
  final grnFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();
  var remarksController = TextEditingController();
  var siteNameController = TextEditingController();

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;
  var selectedGodownName = ''.obs;
  var selectedGodownCode = ''.obs;
  var selectedSiteCode = ''.obs;

  var sites = <SiteMasterDm>[].obs;

  var poAuthItems = <PoAuthItemDm>[].obs;
  var selectedPoOrders = <String, Map<String, dynamic>>{}.obs;
  var qtyControllers = <String, TextEditingController>{}.obs;

  var attachmentFiles = <PlatformFile>[].obs;
  var existingAttachmentUrls = <String>[].obs;

  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  var isItemSelectionMode = false.obs;
  var isInSelectionMode = false.obs;

  var isDirectGrn = false.obs;
  var directGrnItems = <Map<String, dynamic>>[].obs;
  final directItemFormKey = GlobalKey<FormState>();

  var items = <ItemMasterDm>[].obs;
  var itemNames = <String>[].obs;
  var selectedDirectItemName = ''.obs;
  var selectedDirectItemCode = ''.obs;
  var selectedDirectUnit = ''.obs;
  var directRateController = TextEditingController();
  var directQtyController = TextEditingController();

  var isEditingDirectItem = false.obs;
  var editingDirectItemIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void onClose() {
    dateController.dispose();
    remarksController.dispose();
    siteNameController.dispose();

    for (var controller in qtyControllers.values) {
      controller.dispose();
    }
    qtyControllers.clear();

    super.onClose();
  }

  Future<void> getSites() async {
    try {
      isLoading.value = true;
      final fetchedSites = await SiteMasterListRepo.getSites();
      sites.assignAll(fetchedSites);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
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

  void onPartySelected(String? partyName) {
    selectedPartyName.value = partyName!;
    var selectedPartyObj = parties.firstWhere(
      (p) => p.accountName == partyName,
    );
    selectedPartyCode.value = selectedPartyObj.pCode;
  }

  Future<void> getGodowns() async {
    try {
      isLoading.value = true;
      await getSites();
      final fetchedGodowns = await GodownMasterRepo.getGodowns(siteCode: "");
      godowns.assignAll(fetchedGodowns);
      godownNames.assignAll(fetchedGodowns.map((gd) => gd.gdName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onGodownSelected(String? godownName) {
    selectedGodownName.value = godownName!;
    var selectedGodownObj = godowns.firstWhere((gd) => gd.gdName == godownName);
    selectedGodownCode.value = selectedGodownObj.gdCode;
    selectedSiteCode.value = selectedGodownObj.siteCode;

    if (selectedGodownObj.siteCode.isNotEmpty) {
      final site = sites.firstWhereOrNull(
        (s) => s.siteCode == selectedGodownObj.siteCode,
      );
      siteNameController.text = site?.siteName ?? '';
    } else {
      siteNameController.clear();
    }

    selectedPoOrders.clear();
    poAuthItems.clear();
    isInSelectionMode.value = false;
    _disposeQtyControllers();
  }

  Future<void> getPoAuthItems() async {
    if (selectedSiteCode.value.isEmpty || selectedGodownCode.value.isEmpty) {
      showErrorSnackbar('Error', 'Please select godown first');
      return;
    }
    if (selectedPartyCode.value.isEmpty) {
      showErrorSnackbar('Error', 'Please select party first');
      return;
    }

    try {
      isLoading.value = true;
      final fetchedItems = await PoAuthItemsRepo.getPoAuthItems(
        siteCode: selectedSiteCode.value,
        gdCode: selectedGodownCode.value,
        pCode: selectedPartyCode.value,
      );
      poAuthItems.assignAll(fetchedItems);
      isItemSelectionMode.value = true;
      isInSelectionMode.value = false;

      for (var item in fetchedItems) {
        for (var order in item.orders) {
          final key = '${order.poInvNo}_${order.poSrNo}';

          if (!qtyControllers.containsKey(key)) {
            qtyControllers[key] = TextEditingController(
              text: order.pendingQty.toStringAsFixed(2),
            );
          }
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void populateSelectedItemsFromGrnDetails(List<GrnDetailDm> details) {
    isLoading.value = true;

    try {
      selectedPoOrders.clear();
      _disposeQtyControllers();

      for (var detail in details) {
        final key = '${detail.poInvNo}_${detail.poSrnNo.toInt()}';

        qtyControllers[key] = TextEditingController(
          text: detail.qty.toStringAsFixed(2),
        );

        selectedPoOrders[key] = {
          'iCode': detail.iCode,
          'iName': detail.iName,
          'unit': detail.unit,
          'rate': detail.rate, // Add this (assuming GrnDetailDm has rate)
          'poInvNo': detail.poInvNo,
          'poSrNo': detail.poSrnNo.toInt(),
          'poDate': detail.poDate,
          'poQty': detail.poQty,
          'pendingQty': detail.pendingQty,
          'grnQty': detail.qty,
        };
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void togglePoOrderSelection(PoAuthItemDm item, PoOrderDm order) {
    final key = '${order.poInvNo}_${order.poSrNo}';

    if (selectedPoOrders.containsKey(key)) {
      selectedPoOrders.remove(key);

      if (selectedPoOrders.isEmpty) {
        isInSelectionMode.value = false;
      }
    } else {
      final controller = qtyControllers[key];
      final grnQty =
          double.tryParse(controller?.text ?? '') ?? order.pendingQty;

      selectedPoOrders[key] = {
        'iCode': item.iCode,
        'iName': item.iName,
        'unit': item.unit,
        'rate': item.rate, // Add this
        'poInvNo': order.poInvNo,
        'poSrNo': order.poSrNo,
        'poDate': order.poDate,
        'poQty': order.poQty,
        'pendingQty': order.pendingQty,
        'grnQty': grnQty,
      };
    }
  }

  void onPoOrderLongPress(PoAuthItemDm item, PoOrderDm order) {
    if (!isInSelectionMode.value) {
      isInSelectionMode.value = true;
    }
    togglePoOrderSelection(item, order);
  }

  bool isPoOrderSelected(String poInvNo, int poSrNo) {
    final key = '${poInvNo}_$poSrNo';
    return selectedPoOrders.containsKey(key);
  }

  void updateGrnQty(String poInvNo, int poSrNo, double qty) {
    final key = '${poInvNo}_$poSrNo';
    if (selectedPoOrders.containsKey(key)) {
      selectedPoOrders[key]!['grnQty'] = qty;
      selectedPoOrders.refresh();
    }
  }

  bool handleBackPress() {
    if (isItemSelectionMode.value) {
      isItemSelectionMode.value = false;
      isInSelectionMode.value = false;
      return false;
    }
    return true;
  }

  void confirmItemSelection() {
    if (selectedPoOrders.isEmpty) {
      showErrorSnackbar('Error', 'Please select at least one PO');
      return;
    }

    bool hasError = false;
    for (var entry in selectedPoOrders.entries) {
      final grnQty = entry.value['grnQty'] as double;
      final pendingQty = entry.value['pendingQty'] as double;

      if (grnQty <= 0) {
        showErrorSnackbar('Error', 'GRN quantity must be greater than 0');
        hasError = true;
        break;
      }

      if (grnQty > pendingQty) {
        showErrorSnackbar(
          'Error',
          'GRN quantity cannot exceed pending quantity',
        );
        hasError = true;
        break;
      }
    }

    if (!hasError) {
      isItemSelectionMode.value = false;
      isInSelectionMode.value = false;
    }
  }

  void cancelItemSelection() {
    if (!isEditMode.value) {
      selectedPoOrders.clear();
      _disposeQtyControllers();
    }
    isItemSelectionMode.value = false;
    isInSelectionMode.value = false;
  }

  void removeSelectedPo(String key) {
    selectedPoOrders.remove(key);

    if (isItemSelectionMode.value && selectedPoOrders.isEmpty) {
      isInSelectionMode.value = false;
    }
  }

  void _disposeQtyControllers() {
    for (var controller in qtyControllers.values) {
      controller.dispose();
    }
    qtyControllers.clear();
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

  Future<void> getItems() async {
    if (items.isNotEmpty) return;

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

  // ADD THIS METHOD
  void onDirectItemSelected(String? itemName) {
    selectedDirectItemName.value = itemName!;
    var selectedItemObj = items.firstWhere((item) => item.iName == itemName);
    selectedDirectItemCode.value = selectedItemObj.iCode;
    selectedDirectUnit.value = selectedItemObj.unit;
    directQtyController.clear();
    directRateController.clear();
  }

  // ADD THIS METHOD
  void prepareAddDirectItem() {
    clearDirectItemForm();
    isEditingDirectItem.value = false;
    editingDirectItemIndex.value = -1;
  }

  // ADD THIS METHOD
  void prepareEditDirectItem(int index) {
    final item = directGrnItems[index];
    selectedDirectItemName.value = item['iname'] ?? '';
    selectedDirectItemCode.value = item['icode'] ?? '';
    selectedDirectUnit.value = item['unit'] ?? '';
    directQtyController.text = (item['qty'] ?? 0).toString();
    directRateController.text = (item['rate'] ?? 0).toString();

    isEditingDirectItem.value = true;
    editingDirectItemIndex.value = index;
  }

  // ADD THIS METHOD
  void clearDirectItemForm() {
    selectedDirectItemName.value = '';
    selectedDirectItemCode.value = '';
    selectedDirectUnit.value = '';
    directQtyController.clear();
    directRateController.clear();
  }

  // ADD THIS METHOD
  void addOrUpdateDirectItem() {
    double qty = double.tryParse(directQtyController.text) ?? 0;
    double rate = double.tryParse(directRateController.text) ?? 0;

    if (!isEditingDirectItem.value) {
      final isDuplicate = directGrnItems.any(
        (item) => item['icode'] == selectedDirectItemCode.value,
      );

      if (isDuplicate) {
        showErrorSnackbar('Duplicate Item', 'This item is already added.');
        return;
      }
    }

    Map<String, dynamic> itemData = {
      "SrNo": isEditingDirectItem.value
          ? directGrnItems[editingDirectItemIndex.value]["SrNo"]
          : directGrnItems.length + 1,
      "icode": selectedDirectItemCode.value,
      "iname": selectedDirectItemName.value,
      "unit": selectedDirectUnit.value,
      "qty": qty,
      "rate": rate,
    };

    if (isEditingDirectItem.value) {
      directGrnItems[editingDirectItemIndex.value] = itemData;
    } else {
      directGrnItems.add(itemData);
    }

    _reassignDirectSrNo();
    Get.back();
  }

  // ADD THIS METHOD
  void deleteDirectItem(int index) {
    if (index >= 0 && index < directGrnItems.length) {
      directGrnItems.removeAt(index);
      _reassignDirectSrNo();
    }
  }

  // ADD THIS METHOD
  void _reassignDirectSrNo() {
    for (int i = 0; i < directGrnItems.length; i++) {
      directGrnItems[i]["SrNo"] = i + 1;
    }
  }

  // ADD THIS METHOD
  void populateDirectItemsFromGrnDetails(List<GrnDetailDm> details) {
    directGrnItems.clear();

    for (var detail in details) {
      directGrnItems.add({
        "SrNo": detail.srNo,
        "icode": detail.iCode,
        "iname": detail.iName,
        "unit": detail.unit,
        "qty": detail.qty,
        "rate": detail.rate,
      });
    }
  }

  final GrnsController grnsController = Get.find<GrnsController>();

  Future<void> saveGrnEntry() async {
    isLoading.value = true;

    try {
      List<Map<String, dynamic>> itemData;

      if (isDirectGrn.value) {
        // Direct GRN
        itemData = directGrnItems
            .map(
              (item) => {
                "SrNo": item['SrNo'],
                "ICode": item['icode'],
                "Unit": item['unit'],
                "Qty": item['qty'],
                "Rate": item['rate'],
                "POInvNo": "",
                "POSrNo": "",
              },
            )
            .toList();
      } else {
        // Against PO
        itemData = [];
        int srNo = 1;

        for (var entry in selectedPoOrders.entries) {
          final poData = entry.value;
          itemData.add({
            "SrNo": srNo++,
            "ICode": poData['iCode'],
            "Unit": poData['unit'],
            "Qty": poData['grnQty'],
            "Rate": poData['rate'],
            "POInvNo": poData['poInvNo'],
            "POSrNo": poData['poSrNo'],
          });
        }
      }

      var response = await GrnEntryRepo.saveGrnEntry(
        invNo: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),
        gdCode: selectedGodownCode.value,
        remarks: remarksController.text,
        pCode: selectedPartyCode.value,
        siteCode: selectedSiteCode.value,
        type: isDirectGrn.value ? 'Direct' : 'Against', // ADD THIS
        itemData: itemData,
        newFiles: attachmentFiles.toList(),
        existingAttachments: existingAttachmentUrls.toList(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        grnsController.getGrns();
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
    siteNameController.clear();

    selectedPartyName.value = '';
    selectedPartyCode.value = '';
    selectedGodownName.value = '';
    selectedGodownCode.value = '';
    selectedSiteCode.value = '';

    selectedPoOrders.clear();
    poAuthItems.clear();
    directGrnItems.clear();
    attachmentFiles.clear();
    existingAttachmentUrls.clear();

    isEditMode.value = false;
    isDirectGrn.value = false;
    isItemSelectionMode.value = false;
    isInSelectionMode.value = false;

    _disposeQtyControllers();
  }
}
