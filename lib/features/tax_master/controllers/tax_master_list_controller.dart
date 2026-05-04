import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/tax_master/models/tax_master_dm.dart';
import 'package:shivay_construction/features/tax_master/repos/tax_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class TaxMasterListController extends GetxController {
  var isLoading = false.obs;

  var taxList = <TaxMasterDm>[].obs;
  var filteredTaxList = <TaxMasterDm>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getTaxList();
  }

  Future<void> getTaxList() async {
    isLoading.value = true;
    try {
      final fetched = await TaxMasterListRepo.getTaxList();
      taxList.assignAll(fetched);
      filteredTaxList.assignAll(fetched);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterTaxList(String query) {
    if (query.isEmpty) {
      filteredTaxList.assignAll(taxList);
    } else {
      filteredTaxList.assignAll(
        taxList.where((tax) {
          return tax.taxName.toLowerCase().contains(query.toLowerCase()) ||
              tax.tCode.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  Future<void> deleteTax(String tCode) async {
    isLoading.value = true;
    try {
      final response = await TaxMasterListRepo.deleteTax(
        code: tCode,
        typeMast: 'Tax',
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getTaxList();
        showSuccessSnackbar('Success', message);
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
}
