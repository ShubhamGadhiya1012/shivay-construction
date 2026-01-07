import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/opening_stock_entry/models/opening_stock_dm.dart';
import 'package:shivay_construction/features/opening_stock_entry/repos/opening_stocks_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class OpeningStocksController extends GetxController {
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var isFetchingData = false;

  var currentPage = 1;
  var pageSize = 10;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  var openingStocks = <OpeningStockDm>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await getOpeningStocks();
    debounceSearchQuery();
  }

  void debounceSearchQuery() {
    debounce(
      searchQuery,
      (_) => getOpeningStocks(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> getOpeningStocks({bool loadMore = false}) async {
    if (loadMore && !hasMoreData.value) return;
    if (isFetchingData) return;

    try {
      isFetchingData = true;
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        openingStocks.clear();
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      var fetchedOpeningStocks = await OpeningStocksRepo.getOpeningStocks(
        pageNumber: currentPage,
        pageSize: pageSize,
        searchText: searchQuery.value,
      );

      if (fetchedOpeningStocks.isNotEmpty) {
        openingStocks.addAll(fetchedOpeningStocks);
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
}
