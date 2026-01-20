import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/item_help/models/item_help_last_grn_dm.dart';
import 'package:shivay_construction/features/item_help/repos/item_help_repo.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class ItemHelpLastGrnController extends GetxController {
  var isLoading = false.obs;
  var count = 5.obs;
  var lastGrnList = <ItemHelpLastGrnDm>[].obs;

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedParty = ''.obs;
  var selectedPartyCode = ''.obs;

  final countController = TextEditingController(text: '5');

  @override
  void onInit() {
    super.onInit();
    getParties();
  }

  Future<void> getParties() async {
    try {
      isLoading.value = true;
      final fetchedParties = await PartyMasterListRepo.getParties();
      parties.assignAll(fetchedParties);
      partyNames.assignAll(fetchedParties.map((party) => party.accountName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onPartySelected(String? partyName, String iCode) async {
    if (partyName == null || partyName.isEmpty) {
      selectedParty.value = '';
      selectedPartyCode.value = '';
      await getLastGrn(iCode: iCode);
      return;
    }

    selectedParty.value = partyName;
    final selectedPartyObj = parties.firstWhere(
      (party) => party.accountName == partyName,
    );
    selectedPartyCode.value = selectedPartyObj.pCode;

    await getLastGrn(iCode: iCode);
  }

  Future<void> getLastGrn({required String iCode}) async {
    isLoading.value = true;
    try {
      final fetchedLastGrn = await ItemHelpRepo.getLastGrn(
        iCode: iCode,
        pCode: selectedPartyCode.value,
        count: count.value.toString(),
      );
      lastGrnList.assignAll(fetchedLastGrn);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void incrementCount(String iCode) {
    count.value++;
    countController.text = count.value.toString();
    getLastGrn(iCode: iCode);
  }

  void decrementCount(String iCode) {
    if (count.value > 1) {
      count.value--;
      countController.text = count.value.toString();
      getLastGrn(iCode: iCode);
    }
  }

  void onCountChanged(String value, String iCode) {
    final entered = int.tryParse(value);
    if (entered != null && entered > 0) {
      count.value = entered;
      getLastGrn(iCode: iCode);
    }
  }
}
