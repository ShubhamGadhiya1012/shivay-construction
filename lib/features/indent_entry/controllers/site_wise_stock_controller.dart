import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/indent_entry/models/site_wise_stock_dm.dart';
import 'package:shivay_construction/features/indent_entry/repos/site_wise_stock_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class SiteWiseStockController extends GetxController {
  var isLoading = false.obs;
  var stockList = <SiteWiseStockDm>[].obs;
  var filteredStockList = <SiteWiseStockDm>[].obs;
  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  // Group stocks by site
  Map<String, List<SiteWiseStockDm>> get groupedBySite {
    final Map<String, List<SiteWiseStockDm>> grouped = {};
    for (var stock in filteredStockList) {
      if (!grouped.containsKey(stock.siteCode)) {
        grouped[stock.siteCode] = [];
      }
      grouped[stock.siteCode]!.add(stock);
    }
    return grouped;
  }

  @override
  void onInit() {
    super.onInit();
    getSiteWiseStock();
    debounceSearch();
  }

  void debounceSearch() {
    debounce(
      searchQuery,
      (_) => filterStock(),
      time: const Duration(milliseconds: 300),
    );
  }

  void filterStock() {
    if (searchQuery.value.isEmpty) {
      filteredStockList.assignAll(stockList);
    } else {
      filteredStockList.assignAll(
        stockList.where((stock) {
          final query = searchQuery.value.toLowerCase();
          return stock.siteName.toLowerCase().contains(query) ||
              stock.iName.toLowerCase().contains(query) ||
              stock.iCode.toLowerCase().contains(query);
        }).toList(),
      );
    }
  }

  Future<void> getSiteWiseStock() async {
    try {
      isLoading.value = true;
      final fetchedStock = await SiteWiseStockRepo.getSiteWiseStock();
      stockList.assignAll(fetchedStock);
      filteredStockList.assignAll(fetchedStock);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
