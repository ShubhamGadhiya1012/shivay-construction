import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/category_master/models/category_master_dm.dart';
import 'package:shivay_construction/features/category_master/repos/category_master_repo.dart';
import 'package:shivay_construction/features/item_group_master/models/item_group_master_dm.dart';
import 'package:shivay_construction/features/item_group_master/repos/item_group_master_repo.dart';
import 'package:shivay_construction/features/item_sub_group_master/repos/item_sub_group_master_repo.dart';
import 'package:shivay_construction/features/item_sub_group_master/models/item_sub_group_master_dm.dart';
import 'package:shivay_construction/features/item_master/controllers/item_master_list_controller.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class ItemMasterController extends GetxController {
  var isLoading = false.obs;
  final itemFormKey = GlobalKey<FormState>();

  var iNameController = TextEditingController();
  var descriptionController = TextEditingController();
  var rateController = TextEditingController();
  var unitController = TextEditingController();

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
  var isEditMode = false.obs;
  var currentICode = ''.obs;

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

  void autoFillDataForEdit(ItemMasterDm item) {
    isEditMode.value = true;
    currentICode.value = item.iCode;

    iNameController.text = item.iName;
    descriptionController.text = item.description;
    rateController.text = item.rate.toString();
    unitController.text = item.unit;

    if (item.cName.isNotEmpty) {
      selectedCategory.value = item.cName;
      selectedCategoryCode.value = item.cCode;
    }

    if (item.igName.isNotEmpty) {
      selectedItemGroup.value = item.igName;
      selectedItemGroupCode.value = item.igCode;
    }

    if (item.icName.isNotEmpty) {
      selectedItemSubGroup.value = item.icName;
      selectedItemSubGroupCode.value = item.icCode;
    }
  }

  Future<void> addUpdateItemMaster() async {
    isLoading.value = true;
    try {
      final response = await ItemMasterRepo.addUpdateItemMaster(
        iCode: currentICode.value,
        iName: iNameController.text.trim(),
        description: descriptionController.text.trim(),
        rate: double.tryParse(rateController.text.trim()) ?? 0.0,
        igCode: selectedItemGroupCode.value,
        icCode: selectedItemSubGroupCode.value,
        cCode: selectedCategoryCode.value,
        unit: unitController.text.trim(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        showSuccessSnackbar('Success', message);

        if (Get.isRegistered<ItemMasterListController>()) {
          final listController = Get.find<ItemMasterListController>();
          await listController.getItems();
          listController.filterItems(listController.searchController.text);
        }

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
    iNameController.clear();
    descriptionController.clear();
    rateController.clear();
    unitController.clear();

    selectedCategory.value = '';
    selectedCategoryCode.value = '';
    selectedItemGroup.value = '';
    selectedItemGroupCode.value = '';
    selectedItemSubGroup.value = '';
    selectedItemSubGroupCode.value = '';

    isEditMode.value = false;
    currentICode.value = '';
  }
}
