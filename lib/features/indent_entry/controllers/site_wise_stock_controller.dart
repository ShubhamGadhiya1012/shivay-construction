import 'package:get/get.dart';
import 'package:shivay_construction/features/indent_entry/models/site_wise_stock_dm.dart';
import 'package:shivay_construction/features/indent_entry/repos/site_wise_stock_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class SiteWiseStockController extends GetxController {
  var isLoading = false.obs;
  var stockList = <SiteWiseStockDm>[].obs;
  var groupedStockList = <SiteStockGroup>[].obs;
  var expandedSiteIndices = <int>[].obs;
  var isSingleItemMode = false.obs;
  var itemName = ''.obs;
  var itemUnit = ''.obs;
  var totalItemStock = 0.0.obs;

  Future<void> getSiteWiseStock({String? iCode}) async {
    try {
      isLoading.value = true;
      final fetchedStock = await SiteWiseStockRepo.getSiteWiseStock(
        iCode: iCode,
      );
      stockList.assignAll(fetchedStock);

      isSingleItemMode.value = iCode != null && iCode.isNotEmpty;

      if (isSingleItemMode.value && stockList.isNotEmpty) {
        itemName.value = stockList.first.iName;
        itemUnit.value = stockList.first.unit;
        // Calculate total stock for the item
        totalItemStock.value = stockList.fold(
          0.0,
          (sum, item) => sum + item.stockQty,
        );
      } else {
        itemName.value = '';
        itemUnit.value = '';
        totalItemStock.value = 0.0;
      }

      _groupStockBySite();
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _groupStockBySite() {
    Map<String, List<SiteWiseStockDm>> siteMap = {};

    for (var stock in stockList) {
      if (!siteMap.containsKey(stock.siteCode)) {
        siteMap[stock.siteCode] = [];
      }
      siteMap[stock.siteCode]!.add(stock);
    }

    List<SiteStockGroup> groups = [];

    siteMap.forEach((siteCode, stocks) {
      Map<String, List<SiteWiseStockDm>> godownMap = {};

      for (var stock in stocks) {
        if (!godownMap.containsKey(stock.gdCode)) {
          godownMap[stock.gdCode] = [];
        }
        godownMap[stock.gdCode]!.add(stock);
      }

      List<GodownStockGroup> godowns = [];
      godownMap.forEach((gdCode, items) {
        double godownTotal = items.fold(
          0.0,
          (sum, item) => sum + item.stockQty,
        );
        godowns.add(
          GodownStockGroup(
            gdCode: gdCode,
            gdName: items.first.gdName,
            items: items,
            totalStock: godownTotal,
          ),
        );
      });

      double siteTotal = stocks.fold(0.0, (sum, item) => sum + item.stockQty);

      groups.add(
        SiteStockGroup(
          siteCode: siteCode,
          siteName: stocks.first.siteName,
          godowns: godowns,
          totalStock: siteTotal,
        ),
      );
    });

    groupedStockList.assignAll(groups);
  }

  void toggleSiteExpansion(int index) {
    if (expandedSiteIndices.contains(index)) {
      expandedSiteIndices.remove(index);
    } else {
      expandedSiteIndices.add(index);
    }
  }
}
