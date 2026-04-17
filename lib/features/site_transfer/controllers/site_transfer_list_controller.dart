import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/site_transfer/models/site_transfer_dm.dart';
import 'package:shivay_construction/features/site_transfer/models/site_transfer_detail_dm.dart';
import 'package:shivay_construction/features/site_transfer/repos/site_transfer_list_repo.dart';
import 'package:shivay_construction/features/site_transfer/repos/site_transfer_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';

class SiteTransferListController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var isFetchingData = false;

  var currentPage = 1;
  var pageSize = 10;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  var siteTransfers = <SiteTransferDm>[].obs;
  var transferDetails = <SiteTransferDetailDm>[].obs;

  final filters = {'All': 'All', 'PENDING': 'Pending', 'COMPLETE': 'Complete'};
  var selectedFilter = 'All'.obs;

  var dateController = TextEditingController();
  var remarksController = TextEditingController();
  Map<int, TextEditingController> receiveControllers = {};

  @override
  void onInit() async {
    super.onInit();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    await getSiteTransfers();
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
      (_) => getSiteTransfers(),
      time: const Duration(milliseconds: 300),
    );
  }

  void onFilterSelected(String filterKey) {
    selectedFilter.value = filters[filterKey]!;
    getSiteTransfers();
  }

  Future<void> getSiteTransfers({bool loadMore = false}) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        siteTransfers.clear();
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      var fetchedTransfers = await SiteTransferListRepo.getSiteTransfers(
        pageNumber: currentPage,
        pageSize: pageSize,
        searchText: searchQuery.value,
        status: selectedFilter.value,
      );

      if (fetchedTransfers.isNotEmpty) {
        siteTransfers.addAll(fetchedTransfers);
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

  Future<void> getTransferDetails({required String invNo}) async {
    try {
      final fetchedDetails = await SiteTransferListRepo.getSiteTransferDetails(
        invNo: invNo,
      );
      transferDetails.assignAll(fetchedDetails);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void prepareReceiveDialog(SiteTransferDm transfer) {
    for (var controller in receiveControllers.values) {
      controller.dispose();
    }
    receiveControllers.clear();

    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    remarksController.clear();

    for (var detail in transferDetails) {
      receiveControllers[detail.srNo] = TextEditingController();
    }
  }

  Future<void> saveReceiveTransfer({
    required SiteTransferDm transfer,
    required GlobalKey<FormState> formKey,
  }) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final itemData = <Map<String, dynamic>>[];

      for (var detail in transferDetails) {
        final controller = receiveControllers[detail.srNo];
        if (controller != null && controller.text.isNotEmpty) {
          itemData.add({
            "SrNo": detail.srNo,
            "ICode": detail.iCode,
            "Qty": double.parse(controller.text),
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

      final response = await SiteTransferRepo.receiveSiteTransfer(
        refInvNo: transfer.invNo,
        date: convertToApiDateFormat(dateController.text),
        fromSite: transfer.fromSiteCode,
        fromGDCode: transfer.fromGDCode,
        toSite: transfer.toSiteCode,
        toGDCode: transfer.toGDCode,
        itemData: itemData,
        remarks: remarksController.text.trim(),
      );

      if (response != null && response.containsKey('message')) {
        Get.back();
        showSuccessSnackbar('Success', response['message']);
        await getSiteTransfers();
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

  Future<void> deleteSiteTransfer(String invNo) async {
    isLoading.value = true;
    try {
      final response = await SiteTransferRepo.deleteSiteTransfer(invNo: invNo);

      if (response != null && response.containsKey('message')) {
        showSuccessSnackbar('Success', response['message']);
        await getSiteTransfers();
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
