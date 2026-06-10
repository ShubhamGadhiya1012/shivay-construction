import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/indent_entry/repos/site_wise_stock_repo.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_list_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/features/site_transfer/controllers/site_transfer_list_controller.dart';
import 'package:shivay_construction/features/site_transfer/repos/site_transfer_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class SiteTransferController extends GetxController {
  var isLoading = false.obs;
  final transferFormKey = GlobalKey<FormState>();
  final itemFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();
  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  var sites = <SiteMasterDm>[].obs;
  var siteNames = <String>[].obs;

  var selectedFromSiteCode = ''.obs;
  var selectedFromSiteName = ''.obs;

  var selectedToSiteCode = ''.obs;
  var selectedToSiteName = ''.obs;

  var fromGodownsForItem = <GodownMasterDm>[].obs;
  var fromGodownNamesForItem = <String>[].obs;
  var selectedFromGodownCodeForItem = ''.obs;
  var selectedFromGodownNameForItem = ''.obs;

  var toGodownsForItem = <GodownMasterDm>[].obs;
  var toGodownNamesForItem = <String>[].obs;
  var selectedToGodownCodeForItem = ''.obs;
  var selectedToGodownNameForItem = ''.obs;

  var allItems = <ItemMasterDm>[].obs;
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

  @override
  void onInit() {
    super.onInit();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

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

  Future<void> getGodownsForItemFromStock(String iCode, String siteCode) async {
    try {
      isLoading.value = true;
      final stockList = await SiteWiseStockRepo.getSiteWiseStock(
        iCode: iCode,
        siteCode: siteCode,
      );

      // Build godown list from stock response
      final godowns = stockList
          .map(
            (s) => GodownMasterDm(
              gdCode: s.gdCode,
              gdName: s.gdName,
              isSubGodown: false,
              siteCode: '',
              // fill other required fields as per your model
            ),
          )
          .toList();

      fromGodownsForItem.assignAll(godowns);
      fromGodownNamesForItem.assignAll(godowns.map((gd) => gd.gdName).toList());

      // Show total stock (sum of all godowns) initially
      availableQty.value = stockList.fold(0.0, (sum, s) => sum + s.stockQty);
    } catch (e) {
      availableQty.value = 0.0;
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onFromSiteSelected(String? siteName) {
    if (siteName == null || siteName.isEmpty) return;

    selectedFromSiteName.value = siteName;
    var selectedSite = sites.firstWhere((s) => s.siteName == siteName);
    selectedFromSiteCode.value = selectedSite.siteCode;

    _checkCanAddItem();
  }

  void onToSiteSelected(String? siteName) {
    if (siteName == null || siteName.isEmpty) return;

    selectedToSiteName.value = siteName;
    var selectedSite = sites.firstWhere((s) => s.siteName == siteName);
    selectedToSiteCode.value = selectedSite.siteCode;

    _checkCanAddItem();
  }

  void _checkCanAddItem() {
    canAddItem.value =
        selectedFromSiteCode.value.isNotEmpty &&
        selectedToSiteCode.value.isNotEmpty;
  }

  Future<void> getItems() async {
    try {
      isLoading.value = true;
      final fetchedItems = await ItemMasterListRepo.getItems();
      allItems.assignAll(fetchedItems);
      itemNames.assignAll(fetchedItems.map((item) => item.iName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getItemStockForGodown(String iCode, String gdCode) async {
    try {
      isLoading.value = true;
      final stock = await SiteTransferRepo.getItemStockForGodown(
        siteCode: selectedFromSiteCode.value,
        gdCode: gdCode,
        iCode: iCode,
      );

      if (stock.isNotEmpty) {
        availableQty.value = stock.first['stockQty'] ?? 0.0;
      } else {
        availableQty.value = 0.0;
      }
    } catch (e) {
      availableQty.value = 0.0;
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onItemSelected(String? itemName) {
    if (itemName == null || itemName.isEmpty) return;

    selectedItemName.value = itemName;
    var selectedItem = allItems.firstWhere((item) => item.iName == itemName);
    selectedItemCode.value = selectedItem.iCode;
    selectedUnit.value = selectedItem.unit;

    // Reset
    availableQty.value = 0.0;
    selectedFromGodownNameForItem.value = '';
    selectedFromGodownCodeForItem.value = '';
    fromGodownsForItem.clear();
    fromGodownNamesForItem.clear();
    qtyController.clear();

    // Fetch stock-based godowns for from-head dropdown
    if (selectedFromSiteCode.value.isNotEmpty) {
      getGodownsForItemFromStock(
        selectedItem.iCode,
        selectedFromSiteCode.value,
      );
    }
  }

  void onFromGodownForItemSelected(String? godownName) {
    if (godownName == null || godownName.isEmpty) {
      selectedFromGodownNameForItem.value = '';
      selectedFromGodownCodeForItem.value = '';
      // Reset to total stock sum
      availableQty.value = fromGodownsForItem.isNotEmpty
          ? 0.0 // or recalculate sum if you store stock per godown
          : 0.0;
      return;
    }

    selectedFromGodownNameForItem.value = godownName;
    var selectedGodown = fromGodownsForItem.firstWhere(
      (gd) => gd.gdName == godownName,
    );
    selectedFromGodownCodeForItem.value = selectedGodown.gdCode;

    // Fetch stock for this specific godown
    if (selectedItemCode.value.isNotEmpty) {
      getItemStockForGodown(selectedItemCode.value, selectedGodown.gdCode);
    }
  }

  void onToGodownForItemSelected(String? godownName) {
    if (godownName == null || godownName.isEmpty) {
      selectedToGodownNameForItem.value = '';
      selectedToGodownCodeForItem.value = '';
      return;
    }

    selectedToGodownNameForItem.value = godownName;
    var selectedGodown = toGodownsForItem.firstWhere(
      (gd) => gd.gdName == godownName,
    );
    selectedToGodownCodeForItem.value = selectedGodown.gdCode;
  }

  void prepareAddItem() async {
    clearItemForm();
    isEditingItem.value = false;
    editingItemIndex.value = -1;

    // From-site godowns are now loaded dynamically on item selection (via stock API)
    // Only pre-load to-site godowns
    if (selectedToSiteCode.value.isNotEmpty) {
      await getGodownsForSite(selectedToSiteCode.value, false);
    }
    await getItems();
  }

  Future<void> getGodownsForSite(String siteCode, bool isFromSite) async {
    try {
      isLoading.value = true;
      final fetchedGodowns = await GodownMasterRepo.getGodowns(
        siteCode: siteCode,
      );
      final parentGodowns = fetchedGodowns
          .where((gd) => !gd.isSubGodown)
          .toList();

      // isFromSite will always be false now (only used for to-site)
      toGodownsForItem.assignAll(parentGodowns);
      toGodownNamesForItem.assignAll(
        parentGodowns.map((gd) => gd.gdName).toList(),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> prepareEditItem(int index) async {
    isLoading.value = true;
    try {
      final item = itemsToSend[index];
      selectedItemName.value = item['iname'] ?? '';
      selectedItemCode.value = item['ICode'] ?? '';
      selectedUnit.value = item['unit'] ?? '';
      qtyController.text = (item['Qty'] ?? 0).toString();
      selectedFromGodownNameForItem.value = item['FromGDName'] ?? '';
      selectedFromGodownCodeForItem.value = item['FromGDCode'] ?? '';
      selectedToGodownNameForItem.value = item['ToGDName'] ?? '';
      selectedToGodownCodeForItem.value = item['ToGDCode'] ?? '';

      isEditingItem.value = true;
      editingItemIndex.value = index;

      // Load from-godowns based on stock, then restore selected
      if (selectedFromSiteCode.value.isNotEmpty &&
          selectedItemCode.value.isNotEmpty) {
        await getGodownsForItemFromStock(
          selectedItemCode.value,
          selectedFromSiteCode.value,
        );

        // After loading godowns, fetch stock for the specific selected godown
        if (selectedFromGodownCodeForItem.value.isNotEmpty) {
          await getItemStockForGodown(
            selectedItemCode.value,
            selectedFromGodownCodeForItem.value,
          );
        }
      }

      // Load to-godowns
      if (selectedToSiteCode.value.isNotEmpty) {
        await getGodownsForSite(selectedToSiteCode.value, false);
      }
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
    selectedFromGodownNameForItem.value = '';
    selectedFromGodownCodeForItem.value = '';
    selectedToGodownNameForItem.value = '';
    selectedToGodownCodeForItem.value = '';
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
      "FromGDCode": selectedFromGodownCodeForItem.value,
      "FromGDName": selectedFromGodownNameForItem.value,
      "ToGDCode": selectedToGodownCodeForItem.value,
      "ToGDName": selectedToGodownNameForItem.value,
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
      if (selectedFromSiteCode.value == selectedToSiteCode.value) {
        showErrorSnackbar(
          'Invalid Transfer',
          'Cannot transfer to the same site. Please select a different destination site.',
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
          "FromGDCode": item["FromGDCode"],
          "ToGDCode": item["ToGDCode"],
        };
      }).toList();

      var response = await SiteTransferRepo.saveSiteTransfer(
        invNo: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),
        fromSite: selectedFromSiteCode.value,
        toSite: selectedToSiteCode.value,
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
    selectedFromSiteCode.value = '';
    selectedFromSiteName.value = '';
    selectedToSiteCode.value = '';
    selectedToSiteName.value = '';
    itemsToSend.clear();
    allItems.clear();
    itemNames.clear();
    canAddItem.value = false;
    isEditMode.value = false;
  }
}
