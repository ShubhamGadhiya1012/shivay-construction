import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_detail_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_list_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/repos/purchase_order_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class PurchaseOrderListController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var isFetchingData = false;

  var currentPage = 1;
  var pageSize = 10;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;
  var orderDetails = <PurchaseOrderDetailDm>[].obs;
  var purchaseOrders = <PurchaseOrderListDm>[].obs;

  final filters = {
    'ALL': 'ALL',
    'PENDING': 'Pending',
    'PARTIAL': 'Partial',
    'COMPLETE': 'Complete',
  };
  var selectedFilter = 'ALL'.obs;

  var canAuthorizePO = false.obs;
  var isAdmin = false.obs;
  @override
  void onInit() async {
    super.onInit();
    await checkAdminStatus();
    await _loadAuthPermissions();
    await getPurchaseOrders();
    debounceSearchQuery();
  }

  Future<void> checkAdminStatus() async {
    String? userType = await SecureStorageHelper.read('userType');
    isAdmin.value = userType == '0';
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => getPurchaseOrders(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> _loadAuthPermissions() async {
    isLoading.value = true;
    try {
      String? poAuthStr = await SecureStorageHelper.read('poAuth');
      canAuthorizePO.value = poAuthStr == 'true';
    } catch (e) {
      canAuthorizePO.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> authorizePurchaseOrder({required String invNo}) async {
    isLoading.value = true;
    try {
      var response = await PurchaseOrderListRepo.authorizePurchaseOrder(
        invNo: invNo,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        await getPurchaseOrders();
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

  void onFilterSelected(String filterKey) {
    selectedFilter.value = filters[filterKey]!;
    getPurchaseOrders();
  }

  Future<void> getPurchaseOrders({bool loadMore = false}) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        purchaseOrders.clear();
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      var fetchedOrders = await PurchaseOrderListRepo.getPurchaseOrders(
        pageNumber: currentPage,
        pageSize: pageSize,
        searchText: searchQuery.value,
        status: selectedFilter.value,
      );

      if (fetchedOrders.isNotEmpty) {
        purchaseOrders.addAll(fetchedOrders);
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

  Future<void> getOrderDetailsForCard(String invNo) async {
    try {
      final details = await PurchaseOrderListRepo.getPurchaseOrderDetails(
        invNo: invNo,
      );
      orderDetails.assignAll(details);
    } catch (e) {
      orderDetails.clear();
    }
  }

  Future<void> deletePurchaseOrder({required String invNo}) async {
    try {
      isLoading.value = true;

      final response = await PurchaseOrderListRepo.deletePurchaseOrder(
        invNo: invNo,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];

        await getPurchaseOrders();
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
