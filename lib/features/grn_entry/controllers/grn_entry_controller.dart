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

  var currentStep = 0.obs;

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var sites = <SiteMasterDm>[].obs;
  var selectedSiteName = ''.obs;
  var selectedSiteCode = ''.obs;

  var selectedDirectPartyName = ''.obs;
  var selectedDirectPartyCode = ''.obs;
  var selectedDirectSiteName = ''.obs;
  var selectedDirectSiteCode = ''.obs;

  var selectedDirectGodownName = ''.obs;
  var selectedDirectGodownCode = ''.obs;

  var lockedSiteCode = ''.obs;
  var lockedSiteName = ''.obs;
  var lockedPartyCode = ''.obs;
  var lockedPartyName = ''.obs;

  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;

  var selectedPoGodownName = <String, String>{}.obs;
  var selectedPoGodownCode = <String, String>{}.obs;
  var poRemarkControllers = <String, TextEditingController>{}.obs;

  var poAuthItems = <PoAuthItemDm>[].obs;
  var selectedPoOrders = <String, Map<String, dynamic>>{}.obs;
  var qtyControllers = <String, TextEditingController>{}.obs;

  var expandedItemIndices = <int>[].obs;
  var isInSelectionMode = false.obs;

  var attachmentFiles = <PlatformFile>[].obs;
  var existingAttachmentUrls = <String>[].obs;

  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  var isDirectGrn = false.obs;
  var directGrnItems = <Map<String, dynamic>>[].obs;
  final directItemFormKey = GlobalKey<FormState>();

  var items = <ItemMasterDm>[].obs;
  var itemNames = <String>[].obs;
  var selectedDirectItemName = ''.obs;
  var selectedDirectItemCode = ''.obs;
  var selectedDirectUnit = ''.obs;
  var directQtyController = TextEditingController();
  var directRateController = TextEditingController();

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
    directRateController.dispose();
    directQtyController.dispose();
    for (var c in qtyControllers.values) {
      c.dispose();
    }
    for (var c in poRemarkControllers.values) {
      c.dispose();
    }
    qtyControllers.clear();
    poRemarkControllers.clear();
    super.onClose();
  }

  void cancelItemSelection() {
    if (!isEditMode.value) {
      selectedPoOrders.clear();
      _disposeQtyControllers();
    }
    isInSelectionMode.value = false;
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
      isInSelectionMode.value = false;
    }
  }

  Future<void> getPoAuthItems() async {
    if (isDirectGrn.value) {
      return;
    }

    try {
      isLoading.value = true;
      final fetchedItems = await PoAuthItemsRepo.getPoAuthItems();
      poAuthItems.assignAll(fetchedItems);

      if (fetchedItems.isEmpty) {
        showErrorSnackbar('Info', 'No authorized PO items available');
        return;
      }

      expandedItemIndices.clear();
      for (int i = 0; i < fetchedItems.length; i++) {
        expandedItemIndices.add(i);
      }

      for (var item in fetchedItems) {
        for (var order in item.orders) {
          final key = '${order.poInvNo}_${order.poSrNo}';
          if (!qtyControllers.containsKey(key)) {
            qtyControllers[key] = TextEditingController(
              text: order.pendingQty.toStringAsFixed(2),
            );
          }
          if (!selectedPoGodownCode.containsKey(key)) {
            selectedPoGodownCode[key] = order.gdCode;
            selectedPoGodownName[key] = order.gdName;
          }
          if (!poRemarkControllers.containsKey(key)) {
            poRemarkControllers[key] = TextEditingController(
              text: order.poRemark,
            );
          }
        }
      }

      await getGodowns();
      _reapplySelectionsFromOrders();
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onDirectGodownSelected(String? godownName) {
    selectedDirectGodownName.value = godownName ?? '';
    final godown = godowns.firstWhereOrNull((gd) => gd.gdName == godownName);
    selectedDirectGodownCode.value = godown?.gdCode ?? '';
  }

  void _reapplySelectionsFromOrders() {
    for (var selectedEntry in selectedPoOrders.entries) {
      final selectedData = selectedEntry.value;
      for (var item in poAuthItems) {
        for (var order in item.orders) {
          if (order.poInvNo == selectedData['poInvNo'] &&
              order.poSrNo == selectedData['poSrNo']) {
            final key = '${order.poInvNo}_${order.poSrNo}';
            qtyControllers[key]?.text = (selectedData['grnQty'] as double)
                .toStringAsFixed(2);
            if (selectedData['GDCode'] != null) {
              selectedPoGodownCode[key] = selectedData['GDCode'];
              final obj = godowns.firstWhereOrNull(
                (gd) => gd.gdCode == selectedData['GDCode'],
              );
              selectedPoGodownName[key] =
                  obj?.gdName ?? selectedData['GDName'] ?? '';
            }
            if (selectedData['PORemark'] != null) {
              poRemarkControllers[key]?.text = selectedData['PORemark'];
            }
          }
        }
      }
    }
    if (selectedPoOrders.isNotEmpty) {
      isInSelectionMode.value = true;
    }
    poAuthItems.refresh();
  }

  void toggleItemExpansion(int index) {
    if (expandedItemIndices.contains(index)) {
      expandedItemIndices.remove(index);
    } else {
      expandedItemIndices.add(index);
    }
  }

  bool togglePoOrderSelection(PoAuthItemDm item, PoOrderDm order) {
    final key = '${order.poInvNo}_${order.poSrNo}';

    if (selectedPoOrders.containsKey(key)) {
      selectedPoOrders.remove(key);
      _updateLockIfNoSelection();
      if (selectedPoOrders.isEmpty) {
        isInSelectionMode.value = false;
      }
      return true;
    }

    if (lockedSiteCode.value.isEmpty) {
      lockedSiteCode.value = order.siteCode;
      lockedSiteName.value = order.siteName;
      lockedPartyCode.value = order.pCode;
      lockedPartyName.value = order.pName;
    } else {
      if (order.siteCode != lockedSiteCode.value) {
        showErrorSnackbar(
          'Site Mismatch',
          'You can only select orders from "${lockedSiteName.value}". Deselect all to change.',
        );
        return false;
      }

      if (order.pCode != lockedPartyCode.value) {
        showErrorSnackbar(
          'Party Mismatch',
          'You can only select orders from "${lockedPartyName.value}". Deselect all to change.',
        );
        return false;
      }
    }

    final qtyController = qtyControllers[key];
    final grnQty =
        double.tryParse(qtyController?.text ?? '') ?? order.pendingQty;

    selectedPoOrders[key] = {
      'iCode': item.iCode,
      'iName': item.iName,
      'unit': item.unit,
      'rate': item.rate,
      'poInvNo': order.poInvNo,
      'poSrNo': order.poSrNo,
      'poDate': order.poDate,
      'poQty': order.poQty,
      'pendingQty': order.pendingQty,
      'grnQty': grnQty,
      'GDCode': selectedPoGodownCode[key] ?? order.gdCode,
      'GDName': selectedPoGodownName[key] ?? order.gdName,
      'PORemark': poRemarkControllers[key]?.text ?? order.poRemark,
    };

    selectedSiteCode.value = lockedSiteCode.value;
    selectedSiteName.value = lockedSiteName.value;
    selectedPartyCode.value = lockedPartyCode.value;
    selectedPartyName.value = lockedPartyName.value;

    return true;
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

  void deselectAllOrders() {
    selectedPoOrders.clear();
    lockedSiteCode.value = '';
    lockedSiteName.value = '';
    lockedPartyCode.value = '';
    lockedPartyName.value = '';
    selectedSiteCode.value = '';
    selectedSiteName.value = '';
    selectedPartyCode.value = '';
    selectedPartyName.value = '';
    isInSelectionMode.value = false;
  }

  void _updateLockIfNoSelection() {
    if (selectedPoOrders.isEmpty) {
      lockedSiteCode.value = '';
      lockedSiteName.value = '';
      lockedPartyCode.value = '';
      lockedPartyName.value = '';
      selectedSiteCode.value = '';
      selectedSiteName.value = '';
      selectedPartyCode.value = '';
      selectedPartyName.value = '';
    }
  }

  void updateGrnQty(String poInvNo, int poSrNo, double qty) {
    final key = '${poInvNo}_$poSrNo';
    if (selectedPoOrders.containsKey(key)) {
      selectedPoOrders[key]!['grnQty'] = qty;
      selectedPoOrders.refresh();
    }
  }

  void onPoGodownSelected(String key, String? godownName) {
    selectedPoGodownName[key] = godownName ?? '';
    final obj = godowns.firstWhereOrNull((gd) => gd.gdName == godownName);
    selectedPoGodownCode[key] = obj?.gdCode ?? '';
    if (selectedPoOrders.containsKey(key)) {
      selectedPoOrders[key]!['GDCode'] = selectedPoGodownCode[key];
      selectedPoOrders[key]!['GDName'] = godownName ?? '';
      selectedPoOrders.refresh();
    }
    selectedPoGodownName.refresh();
    selectedPoGodownCode.refresh();
  }

  void proceedToForm() {
    if (selectedPoOrders.isEmpty) {
      showErrorSnackbar('Error', 'Please select at least one PO order');
      return;
    }
    currentStep.value = 1;
  }

  void goBackToSelection() {
    currentStep.value = 0;
  }

  void removeSelectedPo(String key) {
    selectedPoOrders.remove(key);
    _updateLockIfNoSelection();
    if (selectedPoOrders.isEmpty) {
      isInSelectionMode.value = false;
    }
  }

  Future<void> getGodowns([String siteCode = '']) async {
    try {
      isLoading.value = true;
      final fetchedGodowns = await GodownMasterRepo.getGodowns(
        siteCode: siteCode,
      );
      godowns.assignAll(fetchedGodowns);
      godownNames.assignAll(fetchedGodowns.map((gd) => gd.gdName).toList());
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

  void onDirectPartySelected(String? partyName) {
    selectedDirectPartyName.value = partyName ?? '';
    final party = parties.firstWhereOrNull((p) => p.accountName == partyName);
    selectedDirectPartyCode.value = party?.pCode ?? '';
  }

  void onDirectSiteSelected(String? siteName) {
    selectedDirectSiteName.value = siteName ?? '';
    final site = sites.firstWhereOrNull((s) => s.siteName == siteName);
    selectedDirectSiteCode.value = site?.siteCode ?? '';
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

  void onDirectItemSelected(String? itemName) {
    selectedDirectItemName.value = itemName!;
    var selectedItemObj = items.firstWhere((item) => item.iName == itemName);
    selectedDirectItemCode.value = selectedItemObj.iCode;
    selectedDirectUnit.value = selectedItemObj.unit;
    directQtyController.clear();
    directRateController.clear();
  }

  void prepareAddDirectItem() {
    clearDirectItemForm();
    isEditingDirectItem.value = false;
    editingDirectItemIndex.value = -1;
  }

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

  void clearDirectItemForm() {
    selectedDirectItemName.value = '';
    selectedDirectItemCode.value = '';
    selectedDirectUnit.value = '';
    selectedDirectGodownName.value = '';
    selectedDirectGodownCode.value = '';
    directQtyController.clear();
    directRateController.clear();
  }

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
      "gdCode": selectedDirectGodownCode.value,
      "gdName": selectedDirectGodownName.value,
    };

    if (isEditingDirectItem.value) {
      directGrnItems[editingDirectItemIndex.value] = itemData;
    } else {
      directGrnItems.add(itemData);
    }

    _reassignDirectSrNo();
    Get.back();
  }

  void deleteDirectItem(int index) {
    if (index >= 0 && index < directGrnItems.length) {
      directGrnItems.removeAt(index);
      _reassignDirectSrNo();
    }
  }

  void _reassignDirectSrNo() {
    for (int i = 0; i < directGrnItems.length; i++) {
      directGrnItems[i]["SrNo"] = i + 1;
    }
  }

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
        "gdCode": detail.gdCode,
        "gdName": detail.gdName,
      });
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
        selectedPoGodownCode[key] = detail.gdCode;
        selectedPoGodownName[key] = detail.gdName;
        poRemarkControllers[key] = TextEditingController(text: detail.poRemark);

        selectedPoOrders[key] = {
          'iCode': detail.iCode,
          'iName': detail.iName,
          'unit': detail.unit,
          'rate': detail.rate,
          'poInvNo': detail.poInvNo,
          'poSrNo': detail.poSrnNo.toInt(),
          'poDate': detail.poDate,
          'poQty': detail.poQty,
          'pendingQty': detail.pendingQty,
          'grnQty': detail.qty,
          'GDCode': detail.gdCode,
          'GDName': detail.gdName,
          'PORemark': detail.poRemark,
        };
      }
      if (selectedPoOrders.isNotEmpty) {
        isInSelectionMode.value = true;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void _disposeQtyControllers() {
    for (var c in qtyControllers.values) {
      c.dispose();
    }
    qtyControllers.clear();
  }

  final GrnsController grnsController = Get.find<GrnsController>();

  Future<void> saveGrnEntry() async {
    if (!grnFormKey.currentState!.validate()) return;

    if (isDirectGrn.value) {
      if (selectedDirectPartyCode.value.isEmpty) {
        showErrorSnackbar('Error', 'Please select party');
        return;
      }
      if (selectedDirectSiteCode.value.isEmpty) {
        showErrorSnackbar('Error', 'Please select site');
        return;
      }
      if (directGrnItems.isEmpty) {
        showErrorSnackbar('Error', 'Please add at least one item');
        return;
      }
    }

    isLoading.value = true;

    try {
      List<Map<String, dynamic>> itemData;

      if (isDirectGrn.value) {
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
                "GDCode": item['gdCode'] ?? '',
                "PORemark": "",
              },
            )
            .toList();
      } else {
        if (selectedPoOrders.isEmpty) {
          showErrorSnackbar('Error', 'Please select at least one PO order');
          return;
        }
        itemData = [];
        int srNo = 1;
        for (var entry in selectedPoOrders.entries) {
          final key = entry.key;
          final poData = entry.value;
          itemData.add({
            "SrNo": srNo++,
            "ICode": poData['iCode'],
            "Unit": poData['unit'],
            "Qty": poData['grnQty'],
            "Rate": poData['rate'],
            "POInvNo": poData['poInvNo'],
            "POSrNo": poData['poSrNo'],
            "GDCode": selectedPoGodownCode[key] ?? poData['GDCode'] ?? '',
            "PORemark":
                poRemarkControllers[key]?.text ?? poData['PORemark'] ?? '',
          });
        }
      }

      var response = await GrnEntryRepo.saveGrnEntry(
        invNo: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),
        remarks: remarksController.text,
        pCode: isDirectGrn.value
            ? selectedDirectPartyCode.value
            : selectedPartyCode.value,
        siteCode: isDirectGrn.value
            ? selectedDirectSiteCode.value
            : selectedSiteCode.value,
        type: isDirectGrn.value ? 'Direct' : 'Against',
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

  Future<void> clearAll() async {
    currentInvNo.value = '';
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    remarksController.clear();

    selectedPartyName.value = '';
    selectedPartyCode.value = '';
    selectedSiteCode.value = '';
    selectedSiteName.value = '';
    lockedSiteCode.value = '';
    lockedSiteName.value = '';
    lockedPartyCode.value = '';
    lockedPartyName.value = '';

    selectedDirectPartyName.value = '';
    selectedDirectPartyCode.value = '';
    selectedDirectSiteName.value = '';
    selectedDirectSiteCode.value = '';

    selectedDirectGodownName.value = '';
    selectedDirectGodownCode.value = '';
    selectedPoOrders.clear();
    poAuthItems.clear();
    directGrnItems.clear();
    attachmentFiles.clear();
    existingAttachmentUrls.clear();

    isEditMode.value = false;
    isDirectGrn.value = false;
    isInSelectionMode.value = false;
    currentStep.value = 0;
    expandedItemIndices.clear();

    for (var c in poRemarkControllers.values) {
      c.dispose();
    }
    poRemarkControllers.clear();
    selectedPoGodownName.clear();
    selectedPoGodownCode.clear();

    _disposeQtyControllers();
    await getGodowns();
  }
}
