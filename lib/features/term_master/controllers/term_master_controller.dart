import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/term_master/controllers/term_master_list_controller.dart';
import 'package:shivay_construction/features/term_master/models/term_master_dm.dart';
import 'package:shivay_construction/features/term_master/repos/term_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class TermMasterController extends GetxController {
  var isLoading = false.obs;
  final termFormKey = GlobalKey<FormState>();

  var termNameController = TextEditingController();
  var isFix = false.obs;
  var termType = 'PO'.obs;

  var isEditMode = false.obs;
  var currentTermCode = ''.obs;

  void autoFillDataForEdit(TermMasterDm term) {
    isEditMode.value = true;
    currentTermCode.value = term.termCode;
    termNameController.text = term.termName;
    isFix.value = term.isFix;
    termType.value = term.termType;
  }

  Future<void> addUpdateTerm() async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "TermCode": currentTermCode.value,
        "TermName": termNameController.text.trim(),
        "IsFix": isFix.value,
        "TermType": termType.value,
      };

      final response = await TermMasterRepo.addUpdateTerm(
        requestBody: requestBody,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        showSuccessSnackbar('Success', message);

        if (Get.isRegistered<TermMasterListController>()) {
          final listController = Get.find<TermMasterListController>();
          await listController.getTerms();
          listController.filterTerms(listController.searchController.text);
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
    termNameController.clear();
    isFix.value = false;
    termType.value = 'PO';
    isEditMode.value = false;
    currentTermCode.value = '';
  }
}
