import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/party%20masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party%20masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class PartyMasterListController extends GetxController {
  var isLoading = false.obs;

  var parties = <PartyMasterDm>[].obs;
  var filteredParties = <PartyMasterDm>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getParties();
  }

  Future<void> getParties() async {
    isLoading.value = true;
    try {
      final fetchedParties = await PartyMasterListRepo.getParties();
      parties.assignAll(fetchedParties);
      filteredParties.assignAll(fetchedParties);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterParties(String query) {
    if (query.isEmpty) {
      filteredParties.assignAll(parties);
    } else {
      filteredParties.assignAll(
        parties.where((party) {
          return party.accountName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              party.pCode.toLowerCase().contains(query.toLowerCase()) ||
              party.printName.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }
}
