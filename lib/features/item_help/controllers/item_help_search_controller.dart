import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/category_master/models/category_master_dm.dart';
import 'package:shivay_construction/features/category_master/repos/category_master_repo.dart';
import 'package:shivay_construction/features/item_group_master/models/item_group_master_dm.dart';
import 'package:shivay_construction/features/item_group_master/repos/item_group_master_repo.dart';
import 'package:shivay_construction/features/item_sub_group_master/models/item_sub_group_master_dm.dart';
import 'package:shivay_construction/features/item_sub_group_master/repos/item_sub_group_master_repo.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class ItemHelpSearchController extends GetxController {
  var isLoading = false.obs;
  final searchFormKey = GlobalKey<FormState>();

  var categoryList = <CategoryMasterDm>[].obs;
  var categoryNames = <String>[].obs;
  var selectedCategory = ''.obs;
  var selectedCategoryCode = ''.obs;

  var itemGroupList = <ItemGroupMasterDm>[].obs;
  var itemGroupNames = <String>[].obs;
  var selectedItemGroup = ''.obs;
  var selectedItemGroupCode = ''.obs;

  var itemSubGroupList = <ItemSubGroupMasterDm>[].obs;
  var itemSubGroupNames = <String>[].obs;
  var selectedItemSubGroup = ''.obs;
  var selectedItemSubGroupCode = ''.obs;

  var items = <ItemMasterDm>[].obs;
  var itemNames = <String>[].obs;
  var selectedItems = <String>[].obs;
  var selectedItemCodes = <String>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    isLoading.value = true;
    await getCategories();
    await getItemGroups();
    await getItemSubGroups();
    await getItems();
    isLoading.value = false;
  }

  Future<void> getCategories() async {
    try {
      final data = await CategoryMasterRepo.getCategories();
      categoryList.assignAll(data);
      categoryNames.assignAll(data.map((e) => e.cName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onCategorySelected(String? category) {
    if (category != null && category.isNotEmpty) {
      selectedCategory.value = category;
      final selected = categoryList.firstWhere((e) => e.cName == category);
      selectedCategoryCode.value = selected.cCode;
    }
  }

  Future<void> getItemGroups() async {
    try {
      final data = await ItemGroupMasterRepo.getItemGroups();
      itemGroupList.assignAll(data);
      itemGroupNames.assignAll(data.map((e) => e.igName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onItemGroupSelected(String? itemGroup) {
    if (itemGroup != null && itemGroup.isNotEmpty) {
      selectedItemGroup.value = itemGroup;
      final selected = itemGroupList.firstWhere((e) => e.igName == itemGroup);
      selectedItemGroupCode.value = selected.igCode;
    }
  }

  Future<void> getItemSubGroups() async {
    try {
      final data = await ItemSubGroupMasterRepo.getItemSubGroups();
      itemSubGroupList.assignAll(data);
      itemSubGroupNames.assignAll(data.map((e) => e.icName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onItemSubGroupSelected(String? itemSubGroup) {
    if (itemSubGroup != null && itemSubGroup.isNotEmpty) {
      selectedItemSubGroup.value = itemSubGroup;
      final selected = itemSubGroupList.firstWhere(
        (e) => e.icName == itemSubGroup,
      );
      selectedItemSubGroupCode.value = selected.icCode;
    }
  }

  Future<void> getItems() async {
    try {
      final data = await ItemMasterListRepo.getItems();
      items.assignAll(data);
      itemNames.assignAll(data.map((e) => e.iName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void selectAllItems() {
    selectedItemCodes.assignAll(items.map((item) => item.iCode));
    selectedItems.assignAll(items.map((item) => item.iName));
  }

  void clearAll() {
    selectedCategory.value = '';
    selectedCategoryCode.value = '';
    selectedItemGroup.value = '';
    selectedItemGroupCode.value = '';
    selectedItemSubGroup.value = '';
    selectedItemSubGroupCode.value = '';
    selectedItems.clear();
    selectedItemCodes.clear();
  }
}
