import 'package:get/get.dart';
import 'package:shivay_construction/features/item_help/models/item_help_detail_dm.dart';
import 'package:shivay_construction/features/item_help/repos/item_help_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class ItemHelpDetailController extends GetxController {
  var isLoading = false.obs;
  var itemDetails = <ItemHelpDetailDm>[].obs;

  Future<void> getItemDetails({required String iCode}) async {
    isLoading.value = true;
    try {
      final fetchedDetails = await ItemHelpRepo.getItemDetails(iCode: iCode);
      itemDetails.assignAll(fetchedDetails);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
