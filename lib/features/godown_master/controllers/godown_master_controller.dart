import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class GodownMasterController extends GetxController {
  var isLoading = false.obs;
  final godownFormKey = GlobalKey<FormState>();

  var godowns = <GodownMasterDm>[].obs;
  var filteredGodowns = <GodownMasterDm>[].obs;
  var sites = <SiteMasterDm>[].obs;

  var searchController = TextEditingController();
  final gdNameController = TextEditingController();

  var siteNames = <String>[].obs;
  var selectedSiteName = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await getSites();
    await getGodowns();
  }

  Future<void> getSites() async {
    isLoading.value = true;
    try {
      final fetchedSites = await SiteMasterListRepo.getSites();
      sites.assignAll(fetchedSites);
      siteNames.assignAll(fetchedSites.map((e) => e.siteName)); // Add this line
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGodowns() async {
    isLoading.value = true;
    try {
      final fetchedGodowns = await GodownMasterRepo.getGodowns();
      godowns.assignAll(fetchedGodowns);
      filteredGodowns.assignAll(fetchedGodowns);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterGodowns(String query) {
    if (query.isEmpty) {
      filteredGodowns.assignAll(godowns);
    } else {
      filteredGodowns.assignAll(
        godowns.where((godown) {
          return godown.gdName.toLowerCase().contains(query.toLowerCase()) ||
              godown.gdCode.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  void onSiteSelected(String? siteName) {
    selectedSiteName.value = siteName ?? '';
  }

  String getSiteCodeByName(String siteName) {
    final site = sites.firstWhereOrNull((s) => s.siteName == siteName);
    return site?.siteCode ?? '';
  }

  Future<void> addUpdateGodown({
    required String gdCode,
    required String gdName,
    required String siteCode,
  }) async {
    isLoading.value = true;
    try {
      final response = await GodownMasterRepo.addUpdateGodown(
        gdCode: gdCode,
        gdName: gdName,
        siteCode: siteCode,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getGodowns();
        filterGodowns(searchController.text);
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
