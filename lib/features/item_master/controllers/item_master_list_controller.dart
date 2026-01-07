import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class ItemMasterListController extends GetxController {
  var isLoading = false.obs;

  var items = <ItemMasterDm>[].obs;
  var filteredItems = <ItemMasterDm>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getItems();
  }

  Future<void> getItems() async {
    isLoading.value = true;
    try {
      final fetchedItems = await ItemMasterListRepo.getItems();
      items.assignAll(fetchedItems);
      filteredItems.assignAll(fetchedItems);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItems.assignAll(items);
    } else {
      filteredItems.assignAll(
        items.where((item) {
          return item.iName.toLowerCase().contains(query.toLowerCase()) ||
              item.iCode.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }
}
