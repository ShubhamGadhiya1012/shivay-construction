import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/category_master/models/category_master_dm.dart';
import 'package:shivay_construction/features/category_master/repos/category_master_repo.dart';
import 'package:shivay_construction/features/hsn_master/models/hsn_master_dm.dart';
import 'package:shivay_construction/features/hsn_master/repos/hsn_master_list_repo.dart';
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

  var hsnList = <HsnMasterDm>[].obs;
  var hsnNumbers = <String>[].obs;
  var selectedHsnNo = ''.obs;

  var rentItem = false.obs;
  var frequencyController = TextEditingController();
  var rentRateController = TextEditingController();

  static const List<String> frequencyOptions = ['Hourly', 'Daily', 'Monthly'];

  void toggleRentItem() {
    rentItem.value = !rentItem.value;
    if (!rentItem.value) {
      frequencyController.clear();
      rentRateController.clear();
    }
  }

  void onHsnSelected(String? hsnNo) {
    if (hsnNo != null && hsnNo.isNotEmpty) {
      selectedHsnNo.value = hsnNo;
    }
  }

  void clearHsn() {
    selectedHsnNo.value = '';
  }

  void onFrequencySelected(String? frequency) {
    if (frequency != null) {
      frequencyController.text = frequency;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await fetchDropdownData();

    iNameController.addListener(() {
      if (!isEditMode.value) {
        descriptionController.text = iNameController.text;
      }
    });
    if (!isEditMode.value) {
      unitController.text = 'NOS';
    }
  }

  Future<void> fetchDropdownData() async {
    isLoading.value = true;
    await getCategories();
    await getItemGroups();
    await getItemSubGroups();
    await getHsnList();
    isLoading.value = false;
  }

  Future<void> getHsnList() async {
    try {
      final data = await HsnMasterListRepo.getHsnList();
      hsnList.assignAll(data);
      hsnNumbers.assignAll(data.map((e) => e.hsnNo));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  Future<void> getCategories() async {
    try {
      final data = await CategoryMasterRepo.getCategories();
      categoryList.assignAll(data);
      _updateCategoryNames();
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void _updateCategoryNames() {
    categoryNames.assignAll(categoryList.map((e) => e.cName));
  }

  void onCategorySelected(String? category) {
    if (category != null && category.isNotEmpty) {
      selectedCategory.value = category;
      final selected = categoryList.firstWhere((e) => e.cName == category);
      selectedCategoryCode.value = selected.cCode;
    }
  }

  Future<void> addNewCategory(String categoryName) async {
    isLoading.value = true;
    try {
      final response = await CategoryMasterRepo.addUpdateCategory(
        cCode: '',
        cName: categoryName,
      );

      if (response != null && response.containsKey('message')) {
        await getCategories();
        onCategorySelected(categoryName);
        showSuccessSnackbar('Success', response['message']);
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

  Future<void> getItemGroups() async {
    try {
      final data = await ItemGroupMasterRepo.getItemGroups();
      itemGroupList.assignAll(data);
      _updateItemGroupNames();
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void _updateItemGroupNames() {
    itemGroupNames.assignAll(itemGroupList.map((e) => e.igName));
  }

  void onItemGroupSelected(String? itemGroup) {
    if (itemGroup != null && itemGroup.isNotEmpty) {
      selectedItemGroup.value = itemGroup;
      final selected = itemGroupList.firstWhere((e) => e.igName == itemGroup);
      selectedItemGroupCode.value = selected.igCode;
    }
  }

  Future<void> addNewItemGroup(String itemGroupName) async {
    isLoading.value = true;
    try {
      final response = await ItemGroupMasterRepo.addUpdateItemGroup(
        igCode: '',
        igName: itemGroupName,
      );

      if (response != null && response.containsKey('message')) {
        await getItemGroups();
        onItemGroupSelected(itemGroupName);
        showSuccessSnackbar('Success', response['message']);
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

  Future<void> getItemSubGroups() async {
    try {
      final data = await ItemSubGroupMasterRepo.getItemSubGroups();
      itemSubGroupList.assignAll(data);
      _updateItemSubGroupNames();
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void _updateItemSubGroupNames() {
    itemSubGroupNames.assignAll(itemSubGroupList.map((e) => e.icName));
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

  Future<void> addNewItemSubGroup(String itemSubGroupName) async {
    isLoading.value = true;
    try {
      final response = await ItemSubGroupMasterRepo.addUpdateItemSubGroup(
        icCode: '',
        icName: itemSubGroupName,
      );

      if (response != null && response.containsKey('message')) {
        await getItemSubGroups();
        onItemSubGroupSelected(itemSubGroupName);
        showSuccessSnackbar('Success', response['message']);
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

    selectedHsnNo.value = item.hsnNo;
    rentItem.value = item.rentItem;
    frequencyController.text = item.frequency;
    rentRateController.text = item.rentRate > 0 ? item.rentRate.toString() : '';
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
        hsnNo: selectedHsnNo.value,
        rentItem: rentItem.value,
        frequency: rentItem.value ? frequencyController.text.trim() : '',
        rentRate: rentItem.value
            ? (double.tryParse(rentRateController.text.trim()) ?? 0.0)
            : 0.0,
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
    unitController.text = 'NOS';
    selectedCategory.value = '';
    selectedCategoryCode.value = '';
    selectedItemGroup.value = '';
    selectedItemGroupCode.value = '';
    selectedItemSubGroup.value = '';
    selectedItemSubGroupCode.value = '';

    isEditMode.value = false;
    currentICode.value = '';

    selectedHsnNo.value = '';
    rentItem.value = false;
    frequencyController.clear();
    rentRateController.clear();
  }
}
