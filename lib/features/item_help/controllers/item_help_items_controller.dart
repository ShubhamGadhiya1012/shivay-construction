import 'package:get/get.dart';
import 'package:shivay_construction/features/item_help/models/item_help_item_dm.dart';
import 'package:shivay_construction/features/item_help/repos/item_help_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class ItemHelpItemsController extends GetxController {
  var isLoading = false.obs;
  var items = <ItemHelpItemDm>[].obs;

  Future<void> getItems({
    required String cCode,
    required String igCode,
    required String icCode,
    required String iCode,
  }) async {
    isLoading.value = true;
    try {
      final fetchedItems = await ItemHelpRepo.getItems(
        cCode: cCode,
        igCode: igCode,
        icCode: icCode,
        iCode: iCode,
      );
      items.assignAll(fetchedItems);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
