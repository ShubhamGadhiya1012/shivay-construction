import 'package:get/get.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/last_purchase_rate_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/repos/last_purchase_rate_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class LastPurchaseRateController extends GetxController {
  var isLoading = false.obs;
  var purchaseRateList = <LastPurchaseRateDm>[].obs;

  Future<void> getLastPurchaseRate({required String iCode}) async {
    try {
      isLoading.value = true;
      final fetchedData = await LastPurchaseRateRepo.getLastPurchaseRate(
        iCode: iCode,
      );
      purchaseRateList.assignAll(fetchedData);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
