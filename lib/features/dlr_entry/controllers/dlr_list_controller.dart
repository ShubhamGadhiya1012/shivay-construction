import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/dlr_entry/models/dlr_dm.dart';
import 'package:shivay_construction/features/dlr_entry/repos/dlr_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class DlrListController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var isFetchingData = false;

  var currentPage = 1;
  var pageSize = 10;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  var dlrList = <DlrDm>[].obs;

  var sites = <SiteMasterDm>[].obs;
  var siteNames = <String>[].obs;
  var selectedSiteName = ''.obs;
  var selectedSiteCode = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await getSites();
    await getDlrList();
    debounceSearchQuery();
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => getDlrList(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> getSites() async {
    isLoading.value = true;
    try {
      final fetchedSites = await SiteMasterListRepo.getSites();
      sites.assignAll(fetchedSites);
      siteNames.assignAll(fetchedSites.map((site) => site.siteName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSiteSelected(String? siteName) async {
    selectedSiteName.value = siteName ?? '';
    var selectedSiteObj = sites.firstWhereOrNull(
      (site) => site.siteName == siteName,
    );
    selectedSiteCode.value = selectedSiteObj?.siteCode ?? '';
  }

  Future<void> getDlrList({bool loadMore = false}) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        dlrList.clear();
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      var fetchedDlrList = await DlrRepo.getDlrList(
        pageNumber: currentPage,
        pageSize: pageSize,
        searchText: searchQuery.value,
        siteCode: selectedSiteCode.value,
      );

      if (fetchedDlrList.isNotEmpty) {
        dlrList.addAll(fetchedDlrList);
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

  Future<void> deleteDlr(String invno) async {
    isLoading.value = true;
    try {
      final response = await DlrRepo.deleteDlr(invno: invno);
      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getDlrList();
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

  void clearFilters() {
    selectedSiteName.value = '';
    selectedSiteCode.value = '';
    getDlrList();
  }
}
