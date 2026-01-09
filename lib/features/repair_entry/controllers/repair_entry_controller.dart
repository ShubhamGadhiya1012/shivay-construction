// controllers/repair_entry_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/features/repair_entry/controllers/repair_issue_list_controller.dart';
import 'package:shivay_construction/features/repair_entry/repos/repair_entry_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/features/site_transfer/models/site_transfer_stock_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class RepairEntryController extends GetxController {
  var isLoading = false.obs;
  final repairFormKey = GlobalKey<FormState>();
  final itemFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();
  var descriptionController = TextEditingController();
  var remarksController = TextEditingController();

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;
  var selectedFromGodownName = ''.obs;
  var selectedFromGodownCode = ''.obs;
  var selectedFromSiteCode = ''.obs;
  var fromSiteNameController = TextEditingController();

  var sites = <SiteMasterDm>[].obs;

  var stockItems = <SiteTransferStockDm>[].obs;
  var itemNames = <String>[].obs;
  var selectedItemName = ''.obs;
  var selectedItemCode = ''.obs;
  var selectedUnit = ''.obs;
  var availableQty = 0.0.obs;

  var qtyController = TextEditingController();

  var itemsToSend = <Map<String, dynamic>>[].obs;
  var isEditingItem = false.obs;
  var editingItemIndex = (-1).obs;

  var canAddItem = false.obs;

  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  @override
  void onInit() {
    super.onInit();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _initialize();
  }

  Future<void> _initialize() async {
    await getSites();
    await getGodowns();
    await getParties();
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

  Future<void> getGodowns() async {
    try {
      isLoading.value = true;
      final fetchedGodowns = await GodownMasterRepo.getGodowns();
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

  void onPartySelected(String? partyName) {
    selectedPartyName.value = partyName!;
    var selectedPartyObj = parties.firstWhere(
      (p) => p.accountName == partyName,
    );
    selectedPartyCode.value = selectedPartyObj.pCode;
  }

  void onFromGodownSelected(String? godownName) {
    selectedFromGodownName.value = godownName!;
    var selectedGodownObj = godowns.firstWhere((gd) => gd.gdName == godownName);

    bool isGodownChanging =
        selectedFromGodownCode.value.isNotEmpty &&
        selectedFromGodownCode.value != selectedGodownObj.gdCode;

    selectedFromGodownCode.value = selectedGodownObj.gdCode;
    selectedFromSiteCode.value = selectedGodownObj.siteCode;

    if (isGodownChanging && itemsToSend.isNotEmpty) {
      itemsToSend.clear();
      stockItems.clear();
    }

    if (selectedGodownObj.siteCode.isNotEmpty) {
      final site = sites.firstWhereOrNull(
        (s) => s.siteCode == selectedGodownObj.siteCode,
      );
      fromSiteNameController.text = site?.siteName ?? '';
    } else {
      fromSiteNameController.clear();
    }

    _checkCanAddItem();

    if (selectedFromSiteCode.value.isNotEmpty &&
        selectedFromGodownCode.value.isNotEmpty) {
      getStockItems();
    }
  }

  void _checkCanAddItem() {
    canAddItem.value = selectedFromGodownCode.value.isNotEmpty;
  }

  Future<void> getStockItems() async {
    try {
      isLoading.value = true;
      final fetchedItems = await RepairEntryRepo.getStockItems(
        siteCode: selectedFromSiteCode.value,
        gdCode: selectedFromGodownCode.value,
      );
      stockItems.assignAll(fetchedItems);
      itemNames.assignAll(fetchedItems.map((item) => item.iName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onItemSelected(String? itemName) {
    selectedItemName.value = itemName!;
    var selectedItemObj = stockItems.firstWhere(
      (item) => item.iName == itemName,
    );
    selectedItemCode.value = selectedItemObj.iCode;
    selectedUnit.value = selectedItemObj.unit;
    availableQty.value = selectedItemObj.stockQty;
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
      selectedItemCode.value = item['ICode'] ?? '';
      selectedUnit.value = item['unit'] ?? '';
      qtyController.text = (item['Qty'] ?? 0).toString();

      final stockItem = stockItems.firstWhereOrNull(
        (si) => si.iCode == selectedItemCode.value,
      );
      availableQty.value = stockItem?.stockQty ?? 0.0;

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
    availableQty.value = 0.0;
    qtyController.clear();
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
      "unit": selectedUnit.value,
      "Qty": qty,
      "availableQty": availableQty.value,
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

  String _convertToApiDateFormat(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  final RepairIssueListController repairIssueListController =
      Get.find<RepairIssueListController>();

  Future<void> saveRepairIssue() async {
    isLoading.value = true;

    try {
      if (itemsToSend.isEmpty) {
        showErrorSnackbar('Error', 'Please add at least one item');
        return;
      }

      final itemData = itemsToSend.map((item) {
        return {
          "SrNo": item["SrNo"],
          "ICode": item["ICode"],
          "Qty": item["Qty"],
        };
      }).toList();

      var response = await RepairEntryRepo.saveRepairIssue(
        invNo: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),
        pCode: selectedPartyCode.value,
        description: descriptionController.text.trim(),
        fromSite: selectedFromSiteCode.value,
        fromGDCode: selectedFromGodownCode.value,
        itemData: itemData,
        remarks: remarksController.text.trim(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        repairIssueListController.getRepairIssues();
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
    descriptionController.clear();
    remarksController.clear();
    fromSiteNameController.clear();

    selectedPartyName.value = '';
    selectedPartyCode.value = '';
    selectedFromGodownName.value = '';
    selectedFromGodownCode.value = '';
    selectedFromSiteCode.value = '';

    itemsToSend.clear();
    stockItems.clear();
    itemNames.clear();

    canAddItem.value = false;
    isEditMode.value = false;
  }
}
