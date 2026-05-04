import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/term_master/models/term_master_dm.dart';
import 'package:shivay_construction/features/term_master/repos/term_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class TermMasterListController extends GetxController {
  var isLoading = false.obs;

  var terms = <TermMasterDm>[].obs;
  var filteredTerms = <TermMasterDm>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getTerms();
  }

  Future<void> getTerms() async {
    isLoading.value = true;
    try {
      final fetchedTerms = await TermMasterRepo.getTerms();
      terms.assignAll(fetchedTerms);
      filteredTerms.assignAll(fetchedTerms);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterTerms(String query) {
    if (query.isEmpty) {
      filteredTerms.assignAll(terms);
    } else {
      filteredTerms.assignAll(
        terms.where((term) {
          return term.termName.toLowerCase().contains(query.toLowerCase()) ||
              term.termCode.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  Future<void> deleteTerm(String termCode) async {
    isLoading.value = true;
    try {
      final response = await TermMasterRepo.deleteTerm(
        code: termCode,
        typeMast: 'Terms',
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getTerms();
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
