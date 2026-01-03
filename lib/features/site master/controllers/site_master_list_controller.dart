import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/site%20master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site%20master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class SiteMasterListController extends GetxController {
  var isLoading = false.obs;

  var sites = <SiteMasterDm>[].obs;
  var filteredSites = <SiteMasterDm>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getSites();
  }

  Future<void> getSites() async {
    isLoading.value = true;
    try {
      final fetchedSites = await SiteMasterListRepo.getSites();
      sites.assignAll(fetchedSites);
      filteredSites.assignAll(fetchedSites);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterSites(String query) {
    if (query.isEmpty) {
      filteredSites.assignAll(sites);
    } else {
      filteredSites.assignAll(
        sites.where((site) {
          return site.siteName.toLowerCase().contains(query.toLowerCase()) ||
              site.siteCode.toLowerCase().contains(query.toLowerCase()) ||
              site.city.toLowerCase().contains(query.toLowerCase()) ||
              site.state.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }
}
