import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/hsn_master/models/hsn_master_dm.dart';
import 'package:shivay_construction/features/hsn_master/models/hsn_master_detail_dm.dart';
import 'package:shivay_construction/features/hsn_master/repos/hsn_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class HsnMasterListController extends GetxController {
  var isLoading = false.obs;

  var hsnList = <HsnMasterDm>[].obs;
  var filteredHsnList = <HsnMasterDm>[].obs;
  var hsnDetails = <HsnMasterDetailDm>[].obs;

  var searchController = TextEditingController();

  var expandedIndex = Rxn<int>();

  void resetExpandedIndex() {
    expandedIndex.value = null;
  }

  @override
  void onInit() async {
    super.onInit();
    await getHsnList();
  }

  Future<void> getHsnList() async {
    isLoading.value = true;
    try {
      final fetchedList = await HsnMasterListRepo.getHsnList();
      hsnList.assignAll(fetchedList);
      filteredHsnList.assignAll(fetchedList);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterHsnList(String query) {
    if (query.isEmpty) {
      filteredHsnList.assignAll(hsnList);
    } else {
      filteredHsnList.assignAll(
        hsnList.where((hsn) {
          return hsn.hsnNo.toLowerCase().contains(query.toLowerCase()) ||
              hsn.description.toLowerCase().contains(query.toLowerCase()) ||
              hsn.chapterNo.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  Future<void> getHsnDetail({required String hsnNo}) async {
    isLoading.value = true;
    try {
      final fetchedDetails = await HsnMasterListRepo.getHsnDetail(hsnNo: hsnNo);
      hsnDetails.assignAll(fetchedDetails);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteHsn(String hsnNo) async {
    isLoading.value = true;
    try {
      final response = await HsnMasterListRepo.deleteHsn(hsnno: hsnNo);

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getHsnList();
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
