import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_list_repo.dart';
import 'package:shivay_construction/features/opening_stock_entry/controllers/opening_stocks_controller.dart';
import 'package:shivay_construction/features/opening_stock_entry/repos/opening_stock_entry_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class OpeningStockEntryController extends GetxController {
  var isLoading = false.obs;
  final openingStockFormKey = GlobalKey<FormState>();
  final openingStockItemFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();
  var siteNameController = TextEditingController();

  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;
  var selectedGodownName = ''.obs;
  var selectedGodownCode = ''.obs;
  var selectedSiteCode = ''.obs;

  var sites = <SiteMasterDm>[].obs;

  var items = <ItemMasterDm>[].obs;
  var itemNames = <String>[].obs;
  var selectedItemName = ''.obs;
  var selectedItemCode = ''.obs;

  var qtyController = TextEditingController();
  var rateController = TextEditingController();

  var itemsToSend = <Map<String, dynamic>>[].obs;
  var isEditingItem = false.obs;
  var editingItemIndex = (-1).obs;

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
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGodowns() async {
    try {
      isLoading.value = true;
      await getSites();
      final fetchedGodowns = await GodownMasterRepo.getGodowns();
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
    rateController.text = selectedItemObj.rate.toStringAsFixed(2);
    qtyController.clear();
  }

  void prepareAddItem() {
    clearItemForm();
    isEditingItem.value = false;
    editingItemIndex.value = -1;
  }

  void prepareEditItem(int index) {
    final item = itemsToSend[index];
    selectedItemName.value = item['iname'];
    selectedItemCode.value = item['icode'];
    qtyController.text = item['qty'].toString();
    rateController.text = item['rate'].toString();
    isEditingItem.value = true;
    editingItemIndex.value = index;
  }

  void clearItemForm() {
    selectedItemName.value = '';
    selectedItemCode.value = '';
    qtyController.clear();
    rateController.clear();
  }

  void addOrUpdateItem() {
    double qty = double.tryParse(qtyController.text) ?? 0;
    double rate = double.tryParse(rateController.text) ?? 0;

    Map<String, dynamic> itemData = {
      "icode": selectedItemCode.value,
      "iname": selectedItemName.value,
      "qty": qty,
      "rate": rate,
    };

    if (isEditingItem.value) {
      itemData["srNo"] = itemsToSend[editingItemIndex.value]["srNo"];
      itemsToSend[editingItemIndex.value] = itemData;
    } else {
      int srNo = itemsToSend.length + 1;
      itemData["srNo"] = srNo;
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
      itemsToSend[i]["srNo"] = i + 1;
    }
  }

  void initializeEditMode(List<Map<String, dynamic>> existingItems) {
    itemsToSend.assignAll(existingItems);
  }

  final OpeningStocksController openingStocksController =
      Get.find<OpeningStocksController>();

  Future<void> saveOpeningStockEntry({required String invNo}) async {
    isLoading.value = true;

    try {
      final parts = dateController.text.split('-');
      final formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';

      var response = await OpeningStockEntryRepo.saveOpeningStockEntry(
        invNo: invNo,
        date: formattedDate,
        siteCode: selectedSiteCode.value,
        gdCode: selectedGodownCode.value,
        itemData: itemsToSend
            .map(
              (item) => {
                "ICode": item['icode'],
                "Qty": item['qty'],
                "Rate": item['rate'],
              },
            )
            .toList(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        openingStocksController.getOpeningStocks();
        Get.back();
        showSuccessSnackbar('Success', message);
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
}
