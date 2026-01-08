import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/category_master/models/category_master_dm.dart';
import 'package:shivay_construction/features/category_master/repos/category_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class CategoryMasterController extends GetxController {
  var isLoading = false.obs;
  final categoryFormKey = GlobalKey<FormState>();

  var categories = <CategoryMasterDm>[].obs;
  var filteredCategories = <CategoryMasterDm>[].obs;
  var searchController = TextEditingController();
  final cNameController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getCategories();
  }

  Future<void> getCategories() async {
    isLoading.value = true;
    try {
      final fetchedCategories = await CategoryMasterRepo.getCategories();
      categories.assignAll(fetchedCategories);
      filteredCategories.assignAll(fetchedCategories);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterCategories(String query) {
    if (query.isEmpty) {
      filteredCategories.assignAll(categories);
    } else {
      filteredCategories.assignAll(
        categories.where((category) {
          return category.cName.toLowerCase().contains(query.toLowerCase()) ||
              category.cCode.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  Future<void> deleteCategory(String cCode) async {
    isLoading.value = true;
    try {
      final response = await CategoryMasterRepo.deleteCategory(
        code: cCode,
        typeMast: 'Category',
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getCategories();
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

  Future<void> addUpdateCategory({
    required String cCode,
    required String cName,
  }) async {
    isLoading.value = true;
    try {
      final response = await CategoryMasterRepo.addUpdateCategory(
        cCode: cCode,
        cName: cName,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getCategories();
        filterCategories(searchController.text);
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
