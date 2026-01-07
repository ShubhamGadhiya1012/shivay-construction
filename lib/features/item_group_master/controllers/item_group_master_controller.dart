import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/item_group_master/models/item_group_master_dm.dart';
import 'package:shivay_construction/features/item_group_master/repos/item_group_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class ItemGroupMasterController extends GetxController {
  var isLoading = false.obs;
  final itemGroupFormKey = GlobalKey<FormState>();

  var itemGroups = <ItemGroupMasterDm>[].obs;
  var filteredItemGroups = <ItemGroupMasterDm>[].obs;
  var searchController = TextEditingController();
  final igNameController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getItemGroups();
  }

  Future<void> getItemGroups() async {
    isLoading.value = true;
    try {
      final fetchedItemGroups = await ItemGroupMasterRepo.getItemGroups();
      itemGroups.assignAll(fetchedItemGroups);
      filteredItemGroups.assignAll(fetchedItemGroups);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterItemGroups(String query) {
    if (query.isEmpty) {
      filteredItemGroups.assignAll(itemGroups);
    } else {
      filteredItemGroups.assignAll(
        itemGroups.where((itemGroup) {
          return itemGroup.igName.toLowerCase().contains(query.toLowerCase()) ||
              itemGroup.igCode.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  Future<void> deleteItemGroup(String igCode) async {
    isLoading.value = true;
    try {
      final response = await ItemGroupMasterRepo.deleteItemGroup(
        code: igCode,
        typeMast: 'Group',
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getItemGroups();
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

  Future<void> addUpdateItemGroup({
    required String igCode,
    required String igName,
  }) async {
    isLoading.value = true;
    try {
      final response = await ItemGroupMasterRepo.addUpdateItemGroup(
        igCode: igCode,
        igName: igName,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getItemGroups();
        filterItemGroups(searchController.text);
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
