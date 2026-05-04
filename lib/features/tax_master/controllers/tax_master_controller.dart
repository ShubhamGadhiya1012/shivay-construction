import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/tax_master/controllers/tax_master_list_controller.dart';
import 'package:shivay_construction/features/tax_master/models/tax_master_dm.dart';
import 'package:shivay_construction/features/tax_master/repos/tax_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class TaxMasterController extends GetxController {
  var isLoading = false.obs;
  final taxFormKey = GlobalKey<FormState>();

  var taxNameController = TextEditingController();

  var igst = false.obs;
  var cgst = false.obs;
  var sgst = false.obs;

  var isEditMode = false.obs;
  var currentTCode = ''.obs;

  void toggleIgst(bool? value) => igst.value = value ?? false;
  void toggleCgst(bool? value) => cgst.value = value ?? false;
  void toggleSgst(bool? value) => sgst.value = value ?? false;

  void autoFillDataForEdit(TaxMasterDm tax) {
    isEditMode.value = true;
    currentTCode.value = tax.tCode;
    taxNameController.text = tax.taxName;
    igst.value = tax.igst;
    cgst.value = tax.cgst;
    sgst.value = tax.sgst;
  }

  Future<void> addUpdateTaxMaster() async {
    isLoading.value = true;
    try {
      final response = await TaxMasterRepo.addUpdateTaxMaster(
        tCode: currentTCode.value,
        taxName: taxNameController.text.trim(),
        igst: igst.value,
        cgst: cgst.value,
        sgst: sgst.value,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        showSuccessSnackbar('Success', message);

        if (Get.isRegistered<TaxMasterListController>()) {
          final listController = Get.find<TaxMasterListController>();
          await listController.getTaxList();
          listController.filterTaxList(listController.searchController.text);
        }

        clearAll();
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

  void clearAll() {
    taxNameController.clear();
    igst.value = false;
    cgst.value = false;
    sgst.value = false;
    isEditMode.value = false;
    currentTCode.value = '';
  }
}
