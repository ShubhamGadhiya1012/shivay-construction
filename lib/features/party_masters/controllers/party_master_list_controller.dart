import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

enum PartyFilterType { all, vendor, contractor }

class PartyMasterListController extends GetxController {
  var isLoading = false.obs;

  var parties = <PartyMasterDm>[].obs;
  var filteredParties = <PartyMasterDm>[].obs;
  var searchController = TextEditingController();

  var selectedFilter = PartyFilterType.all.obs;

  @override
  void onInit() async {
    super.onInit();
    await getParties();
  }

  Future<void> getParties() async {
    isLoading.value = true;
    try {
      bool? isContSubCont;
      if (selectedFilter.value == PartyFilterType.vendor) {
        isContSubCont = false;
      } else if (selectedFilter.value == PartyFilterType.contractor) {
        isContSubCont = true;
      }

      final fetchedParties = await PartyMasterListRepo.getParties(
        isContSubCont: isContSubCont,
      );
      parties.assignAll(fetchedParties);
      filteredParties.assignAll(fetchedParties);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onFilterChanged(PartyFilterType filter) async {
    selectedFilter.value = filter;
    searchController.clear();
    await getParties();
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

  Future<void> deletePartyMaster(String pCode) async {
    isLoading.value = true;
    try {
      final response = await PartyMasterListRepo.deletePartyMaster(
        code: pCode,
        typeMast: 'Party',
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getParties();
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
