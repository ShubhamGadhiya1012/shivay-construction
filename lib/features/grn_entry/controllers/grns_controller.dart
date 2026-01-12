import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/grn_entry/models/grn_dm.dart';
import 'package:shivay_construction/features/grn_entry/models/grn_detail_dm.dart';
import 'package:shivay_construction/features/grn_entry/repos/grns_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class GrnsController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var isFetchingData = false;

  var currentPage = 1;
  var pageSize = 10;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  var grns = <GrnDm>[].obs;
  var grnDetails = <GrnDetailDm>[].obs;
  var isAdmin = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await checkAdminStatus();
    await getGrns();
    debounceSearchQuery();
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => getGrns(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> checkAdminStatus() async {
    String? userType = await SecureStorageHelper.read('userType');
    isAdmin.value = userType == '0';
  }

  Future<void> getGrns({bool loadMore = false}) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        grns.clear();
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      var fetchedGrns = await GrnsRepo.getGrns(
        pageNumber: currentPage,
        pageSize: pageSize,
        searchText: searchQuery.value,
      );

      if (fetchedGrns.isNotEmpty) {
        grns.addAll(fetchedGrns);
        currentPage++;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
      isFetchingData = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> getGrnDetails({required String invNo}) async {
    isLoading.value = true;
    try {
      final fetchedGrnDetails = await GrnsRepo.getGrnDetails(invNo: invNo);

      grnDetails.assignAll(fetchedGrnDetails);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGrn(String invNo) async {
    try {
      isLoading.value = true;
      final response = await GrnsRepo.deleteGrn(invNo: invNo);

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getGrns();
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
