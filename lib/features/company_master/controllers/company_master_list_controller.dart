import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/company_master/models/company_master_dm.dart';
import 'package:shivay_construction/features/company_master/repos/company_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class CompanyMasterListController extends GetxController {
  var isLoading = false.obs;

  var companies = <CompanyMasterDm>[].obs;
  var filteredCompanies = <CompanyMasterDm>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getCompanies();
  }

  Future<void> getCompanies() async {
    isLoading.value = true;
    try {
      final fetchedCompanies = await CompanyMasterListRepo.getCompanies();
      companies.assignAll(fetchedCompanies);
      filteredCompanies.assignAll(fetchedCompanies);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterCompanies(String query) {
    if (query.isEmpty) {
      filteredCompanies.assignAll(companies);
    } else {
      filteredCompanies.assignAll(
        companies.where((company) {
          return company.name.toLowerCase().contains(query.toLowerCase()) ||
              company.city.toLowerCase().contains(query.toLowerCase()) ||
              company.state.toLowerCase().contains(query.toLowerCase()) ||
              company.gstNumber.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  Future<void> deleteCompanyMaster(int coCode) async {
    isLoading.value = true;
    try {
      final response = await CompanyMasterListRepo.deleteCompanyMaster(
        code: coCode.toString(),
        typeMast: 'Company',
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getCompanies();
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
