import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/features/site_transfer/controllers/site_transfer_list_controller.dart';
import 'package:shivay_construction/features/site_transfer/models/site_transfer_stock_dm.dart';
import 'package:shivay_construction/features/site_transfer/repos/site_transfer_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class SiteTransferController extends GetxController {
  var isLoading = false.obs;
  final transferFormKey = GlobalKey<FormState>();
  final itemFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();
  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;
  var selectedFromGodownName = ''.obs;
  var selectedFromGodownCode = ''.obs;
  var selectedFromSiteCode = ''.obs;
  var fromSiteNameController = TextEditingController();

  var selectedToGodownName = ''.obs;
  var selectedToGodownCode = ''.obs;
  var selectedToSiteCode = ''.obs;
  var toSiteNameController = TextEditingController();

  var sites = <SiteMasterDm>[].obs;

  var stockItems = <SiteTransferStockDm>[].obs;
  var itemNames = <String>[].obs;
  var selectedItemName = ''.obs;
  var selectedItemCode = ''.obs;
  var selectedUnit = ''.obs;
  var availableQty = 0.0.obs;

  var qtyController = TextEditingController();
  var remarksController = TextEditingController();

  var itemsToSend = <Map<String, dynamic>>[].obs;
  var isEditingItem = false.obs;
  var editingItemIndex = (-1).obs;

  var canAddItem = false.obs;
  final SiteTransferListController siteTransferListController =
      Get.find<SiteTransferListController>();

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
      final fetchedGodowns = await GodownMasterRepo.getGodowns(siteCode: "");
      godowns.assignAll(fetchedGodowns);
      godownNames.assignAll(fetchedGodowns.map((gd) => gd.gdName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onFromGodownSelected(String? godownName) {
    selectedFromGodownName.value = godownName!;
    var selectedGodownObj = godowns.firstWhere((gd) => gd.gdName == godownName);
    selectedFromGodownCode.value = selectedGodownObj.gdCode;
    selectedFromSiteCode.value = selectedGodownObj.siteCode;

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

  void onToGodownSelected(String? godownName) {
    selectedToGodownName.value = godownName!;
    var selectedGodownObj = godowns.firstWhere((gd) => gd.gdName == godownName);
    selectedToGodownCode.value = selectedGodownObj.gdCode;
    selectedToSiteCode.value = selectedGodownObj.siteCode;

    if (selectedGodownObj.siteCode.isNotEmpty) {
      final site = sites.firstWhereOrNull(
        (s) => s.siteCode == selectedGodownObj.siteCode,
      );
      toSiteNameController.text = site?.siteName ?? '';
    } else {
      toSiteNameController.clear();
    }

    _checkCanAddItem();
  }

  void _checkCanAddItem() {
    canAddItem.value = selectedFromGodownCode.value.isNotEmpty;
  }

  void onFromGodownSelectedWithClear(String? godownName) {
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

  Future<void> getStockItems() async {
    try {
      isLoading.value = true;
      final fetchedItems = await SiteTransferRepo.getSiteStock(
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

  Future<void> saveSiteTransfer() async {
    isLoading.value = true;

    try {
      if (selectedFromSiteCode.value == selectedToSiteCode.value &&
          selectedFromGodownCode.value == selectedToGodownCode.value) {
        showErrorSnackbar(
          'Invalid Transfer',
          'Cannot transfer to the same site and godown. Please select a different destination.',
        );
        isLoading.value = false;
        return;
      }

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

      var response = await SiteTransferRepo.saveSiteTransfer(
        invNo: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),
        fromSite: selectedFromSiteCode.value,
        toSite: selectedToSiteCode.value,
        fromGDCode: selectedFromGodownCode.value,
        toGDCode: selectedToGodownCode.value,
        remarks: remarksController.text.trim(),
        itemData: itemData,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        siteTransferListController.getSiteTransfers();
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
    fromSiteNameController.clear();
    toSiteNameController.clear();
    selectedFromGodownName.value = '';
    selectedFromGodownCode.value = '';
    selectedFromSiteCode.value = '';
    selectedToGodownName.value = '';
    selectedToGodownCode.value = '';
    selectedToSiteCode.value = '';
    itemsToSend.clear();
    stockItems.clear();
    itemNames.clear();
    canAddItem.value = false;
    isEditMode.value = false;
  }
}
