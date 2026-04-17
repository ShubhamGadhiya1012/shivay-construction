import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/issue_entry/models/issue_dm.dart';
import 'package:shivay_construction/features/issue_entry/models/issue_detail_dm.dart';
import 'package:shivay_construction/features/issue_entry/repos/issues_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class IssuesController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var isFetchingData = false;

  var currentPage = 1;
  var pageSize = 10;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  var issues = <IssueDm>[].obs;
  var issueDetails = <IssueDetailDm>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await getIssues();
    debounceSearchQuery();
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => getIssues(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> getIssues({bool loadMore = false}) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        issues.clear();
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      var fetchedIssues = await IssuesRepo.getIssues(
        pageNumber: currentPage,
        pageSize: pageSize,
        searchText: searchQuery.value,
      );

      if (fetchedIssues.isNotEmpty) {
        issues.addAll(fetchedIssues);
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

  Future<void> getIssueDetails({required String invNo}) async {
    isLoading.value = true;
    try {
      final fetchedDetails = await IssuesRepo.getIssueDetails(invNo: invNo);
      issueDetails.assignAll(fetchedDetails);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
