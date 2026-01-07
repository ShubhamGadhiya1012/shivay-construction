import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_detail_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_list_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/repos/purchase_order_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

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

  final filters = {'ALL': 'ALL', 'PENDING': 'Pending', 'COMPLETE': 'Complete'};
  var selectedFilter = 'ALL'.obs;

  @override
  void onInit() async {
    super.onInit();
    await getPurchaseOrders();
    debounceSearchQuery();
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => getPurchaseOrders(),
      time: const Duration(milliseconds: 300),
    );
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
}
