import 'package:get/get.dart';
import 'package:shivay_construction/features/indent_entry/models/site_wise_stock_dm.dart';
import 'package:shivay_construction/features/indent_entry/repos/site_wise_stock_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class SiteWiseStockController extends GetxController {
  var isLoading = false.obs;
  var stockList = <SiteWiseStockDm>[].obs;
  var filteredStockList = <SiteWiseStockDm>[].obs;

  Future<void> getSiteWiseStock({String? iCode}) async {
    try {
      isLoading.value = true;
      final fetchedStock = await SiteWiseStockRepo.getSiteWiseStock(
        iCode: iCode,
      );
      stockList.assignAll(fetchedStock);
      filteredStockList.assignAll(fetchedStock);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
