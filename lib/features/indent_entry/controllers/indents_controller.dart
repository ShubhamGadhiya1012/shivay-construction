import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/indent_entry/models/indent_dm.dart';
import 'package:shivay_construction/features/indent_entry/models/indent_detail_dm.dart';
import 'package:shivay_construction/features/indent_entry/repos/indents_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class IndentsController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var isFetchingData = false;

  var currentPage = 1;
  var pageSize = 10;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  var indents = <IndentDm>[].obs;
  var indentDetails = <IndentDetailDm>[].obs;

  var canAuthorizeIndent = false.obs;

  final filters = {
    'ALL': 'ALL',
    'PENDING': 'Pending',
    'AUTHORISED': 'Complete',
  };
  var selectedFilter = 'ALL'.obs;

  @override
  void onInit() async {
    super.onInit();
    await _loadAuthPermissions();
    await getIndents();

    debounceSearchQuery();
  }

  Future<void> _loadAuthPermissions() async {
    isLoading.value = true;
    try {
      String? indentAuthStr = await SecureStorageHelper.read('indentAuth');
      canAuthorizeIndent.value = indentAuthStr == 'true';
    } catch (e) {
      canAuthorizeIndent.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => getIndents(),
      time: const Duration(milliseconds: 300),
    );
  }

  void onFilterSelected(String filterKey) {
    selectedFilter.value = filters[filterKey]!;
    getIndents();
  }

  Future<void> getIndents({bool loadMore = false}) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        indents.clear();
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      var fetchedIndents = await IndentsRepo.getIndents(
        pageNumber: currentPage,
        pageSize: pageSize,
        searchText: searchQuery.value,
        status: selectedFilter.value,
      );

      if (fetchedIndents.isNotEmpty) {
        indents.addAll(fetchedIndents);
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

  Future<void> getIndentDetails({required String invNo}) async {
    isLoading.value = true;
    try {
      final fetchedIndentDetails = await IndentsRepo.getIndentDetails(
        invNo: invNo,
      );

      indentDetails.assignAll(fetchedIndentDetails);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> authorizeIndent({
    required String invNo,
    required List<Map<String, dynamic>> itemAuthData,
  }) async {
    isLoading.value = true;
    try {
      var response = await IndentsRepo.authorizeIndent(
        invNo: invNo,
        itemAuthData: itemAuthData,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        await getIndents();
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
