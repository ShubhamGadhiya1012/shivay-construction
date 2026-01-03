import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/item%20sub%20group%20master/models/item_sub_group_master_dm.dart';
import 'package:shivay_construction/features/item%20sub%20group%20master/repos/item_sub_group_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class ItemSubGroupMasterController extends GetxController {
  var isLoading = false.obs;
  final itemSubGroupFormKey = GlobalKey<FormState>();

  var itemSubGroups = <ItemSubGroupMasterDm>[].obs;
  var filteredItemSubGroups = <ItemSubGroupMasterDm>[].obs;

  var searchController = TextEditingController();
  final icNameController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();

    await getItemSubGroups();
  }

  Future<void> getItemSubGroups() async {
    isLoading.value = true;
    try {
      final fetchedItemSubGroups =
          await ItemSubGroupMasterRepo.getItemSubGroups();
      itemSubGroups.assignAll(fetchedItemSubGroups);
      filteredItemSubGroups.assignAll(fetchedItemSubGroups);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterItemSubGroups(String query) {
    if (query.isEmpty) {
      filteredItemSubGroups.assignAll(itemSubGroups);
    } else {
      filteredItemSubGroups.assignAll(
        itemSubGroups.where((itemSubGroup) {
          return itemSubGroup.icName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              itemSubGroup.icCode.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  Future<void> addUpdateItemSubGroup({
    required String icCode,
    required String icName,
  }) async {
    isLoading.value = true;
    try {
      final response = await ItemSubGroupMasterRepo.addUpdateItemSubGroup(
        icCode: icCode,
        icName: icName,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getItemSubGroups();
        filterItemSubGroups(searchController.text);
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
