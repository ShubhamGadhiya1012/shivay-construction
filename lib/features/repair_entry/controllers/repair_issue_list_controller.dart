// controllers/repair_issue_list_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/repair_entry/models/repair_issue_dm.dart';
import 'package:shivay_construction/features/repair_entry/models/repair_issue_detail_dm.dart';
import 'package:shivay_construction/features/repair_entry/repos/repair_entry_repo.dart';
import 'package:shivay_construction/features/repair_entry/repos/repair_issue_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';

class RepairIssueListController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var isFetchingData = false;

  var currentPage = 1;
  var pageSize = 10;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  var repairIssues = <RepairIssueDm>[].obs;
  var issueDetails = <RepairIssueDetailDm>[].obs;

  final filters = {'All': 'All', 'PENDING': 'Pending', 'COMPLETE': 'Complete'};
  var selectedFilter = 'All'.obs;

  // For receive dialog
  var dateController = TextEditingController();
  var remarksController = TextEditingController();
  Map<int, TextEditingController> receiveControllers = {};

  @override
  void onInit() async {
    super.onInit();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    await getRepairIssues();
    debounceSearchQuery();
  }

  @override
  void onClose() {
    searchController.dispose();
    dateController.dispose();
    remarksController.dispose();
    for (var controller in receiveControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => getRepairIssues(),
      time: const Duration(milliseconds: 300),
    );
  }

  void onFilterSelected(String filterKey) {
    selectedFilter.value = filters[filterKey]!;
    getRepairIssues();
  }

  Future<void> getRepairIssues({bool loadMore = false}) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        repairIssues.clear();
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      var fetchedIssues = await RepairIssueListRepo.getRepairIssues(
        pageNumber: currentPage,
        pageSize: pageSize,
        searchText: searchQuery.value,
        status: selectedFilter.value,
      );

      if (fetchedIssues.isNotEmpty) {
        repairIssues.addAll(fetchedIssues);
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
    try {
      final fetchedDetails = await RepairIssueListRepo.getRepairIssueDetails(
        invNo: invNo,
      );
      issueDetails.assignAll(fetchedDetails);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void prepareReceiveDialog(RepairIssueDm issue) {
    // Clear previous controllers
    for (var controller in receiveControllers.values) {
      controller.dispose();
    }
    receiveControllers.clear();

    // Reset date and remarks
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    remarksController.clear();

    // Create controllers for each item
    for (var detail in issueDetails) {
      receiveControllers[detail.srNo] = TextEditingController();
    }
  }

  Future<void> saveReceiveRepair({
    required RepairIssueDm issue,
    required GlobalKey<FormState> formKey,
  }) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final itemData = <Map<String, dynamic>>[];

      for (var detail in issueDetails) {
        final controller = receiveControllers[detail.srNo];
        if (controller != null && controller.text.isNotEmpty) {
          itemData.add({
            "SrNo": detail.srNo,
            "iCode": detail.iCode,
            "qty": double.parse(controller.text),
          });
        }
      }

      if (itemData.isEmpty) {
        showErrorSnackbar(
          'Error',
          'Please enter received qty for at least one item',
        );
        return;
      }

      final response = await RepairEntryRepo.receiveRepair(
        refInvNo: issue.invNo,
        date: convertToApiDateFormat(dateController.text),
        pCode: issue.pCode,
        toSite: issue.site,
        toGDCode: issue.gdCode,
        itemData: itemData,
        remarks: remarksController.text.trim(),
      );

      if (response != null && response.containsKey('message')) {
        Get.back();
        showSuccessSnackbar('Success', response['message']);
        await getRepairIssues();
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

  void clearReceiveForm() {
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    remarksController.clear();
    for (var controller in receiveControllers.values) {
      controller.clear();
    }
  }
}
