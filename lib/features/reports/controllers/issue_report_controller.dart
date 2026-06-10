import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_list_repo.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/features/reports/repos/issue_report_repo.dart';
import 'package:shivay_construction/features/reports/widgets/issue_report_pdf_screen.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class IssueReportController extends GetxController {
  var isLoading = false.obs;
  final reportFormKey = GlobalKey<FormState>();

  var fromDateController = TextEditingController();
  var toDateController = TextEditingController();

  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;
  var selectedGodownNames = <String>[].obs;
  var selectedGodownCodes = <String>[].obs;
  var searchGodownController = TextEditingController();

  var items = <ItemMasterDm>[].obs;
  var filteredItems = <ItemMasterDm>[].obs;
  var selectedItemNames = <String>[].obs;
  var selectedItemCodes = <String>[].obs;
  var searchItemController = TextEditingController();

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyNames = <String>[].obs;
  var selectedPartyCodes = <String>[].obs;
  var searchPartyController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    final now = DateTime.now();
    final currentYear = now.month >= 4 ? now.year : now.year - 1;
    final financialYearStart = DateTime(currentYear, 4, 1);
    final formatter = DateFormat('dd-MM-yyyy');
    fromDateController.text = formatter.format(financialYearStart);
    toDateController.text = formatter.format(now);

    await getParties();
    await getGodowns();
    await getItems();
  }

  Future<void> getParties() async {
    try {
      isLoading.value = true;
      final fetchedParties = await PartyMasterListRepo.getParties(
        isContSubCont: true,
      );
      parties.assignAll(fetchedParties);
      partyNames.assignAll(fetchedParties.map((p) => p.accountName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGodowns() async {
    try {
      isLoading.value = true;
      final fetchedGodowns = await GodownMasterRepo.getGodowns(siteCode: '');
      godowns.assignAll(fetchedGodowns);
      godownNames.assignAll(fetchedGodowns.map((gd) => gd.gdName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getItems() async {
    try {
      isLoading.value = true;
      final fetchedItems = await ItemMasterListRepo.getItems();
      items.assignAll(fetchedItems);
      filteredItems.assignAll(fetchedItems);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void togglePartySelection(bool selected, String partyName) {
    if (selected) {
      selectedPartyNames.add(partyName);
      final partyObj = parties.firstWhereOrNull(
        (p) => p.accountName == partyName,
      );
      if (partyObj != null) {
        selectedPartyCodes.add(partyObj.pCode);
      }
    } else {
      selectedPartyNames.remove(partyName);
      final partyObj = parties.firstWhereOrNull(
        (p) => p.accountName == partyName,
      );
      if (partyObj != null) {
        selectedPartyCodes.remove(partyObj.pCode);
      }
    }
  }

  void toggleGodownSelection(bool selected, String godownName) {
    if (selected) {
      selectedGodownNames.add(godownName);
      final godownObj = godowns.firstWhereOrNull((g) => g.gdName == godownName);
      if (godownObj != null) {
        selectedGodownCodes.add(godownObj.gdCode);
      }
    } else {
      selectedGodownNames.remove(godownName);
      final godownObj = godowns.firstWhereOrNull((g) => g.gdName == godownName);
      if (godownObj != null) {
        selectedGodownCodes.remove(godownObj.gdCode);
      }
    }
  }

  void toggleItemSelection(bool selected, String itemCode, String itemName) {
    if (selected) {
      selectedItemCodes.add(itemCode);
      selectedItemNames.add(itemName);
    } else {
      selectedItemCodes.remove(itemCode);
      selectedItemNames.remove(itemName);
    }
  }

  void selectAllParties() {
    selectedPartyNames.assignAll(partyNames);
    selectedPartyCodes.assignAll(parties.map((p) => p.pCode).toList());
  }

  void clearAllParties() {
    selectedPartyNames.clear();
    selectedPartyCodes.clear();
  }

  void selectAllGodowns() {
    selectedGodownNames.assignAll(godownNames);
    selectedGodownCodes.assignAll(godowns.map((g) => g.gdCode).toList());
  }

  void clearAllGodowns() {
    selectedGodownNames.clear();
    selectedGodownCodes.clear();
  }

  void selectAllItems() {
    selectedItemCodes.assignAll(
      filteredItems.map((item) => item.iCode).toList(),
    );
    selectedItemNames.assignAll(
      filteredItems.map((item) => item.iName).toList(),
    );
  }

  void clearAllItems() {
    selectedItemCodes.clear();
    selectedItemNames.clear();
  }

  Future<void> generateReport() async {
    final fromDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateFormat('dd-MM-yyyy').parse(fromDateController.text));

    final toDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateFormat('dd-MM-yyyy').parse(toDateController.text));

    try {
      isLoading.value = true;
      final response = await IssueReportRepo.getIssueReport(
        fromDate: fromDate,
        toDate: toDate,
        pCode: selectedPartyCodes.join(','),
        gdCode: selectedGodownCodes.join(','),
        iCode: selectedItemCodes.join(','),
      );

      if (response.isEmpty) {
        showErrorSnackbar(
          'No Data',
          'No records found for the selected filters.',
        );
        return;
      }

      await IssueReportPdfScreen.generateIssueReportPdf(
        reportData: response,
        fromDate: fromDateController.text,
        toDate: toDateController.text,
      );
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

  Future<void> clearAll() async {
    final now = DateTime.now();
    final currentYear = now.month >= 4 ? now.year : now.year - 1;
    final financialYearStart = DateTime(currentYear, 4, 1);
    final formatter = DateFormat('dd-MM-yyyy');
    fromDateController.text = formatter.format(financialYearStart);
    toDateController.text = formatter.format(now);

    selectedPartyNames.clear();
    selectedPartyCodes.clear();
    selectedGodownNames.clear();
    selectedGodownCodes.clear();
    selectedItemCodes.clear();
    selectedItemNames.clear();
  }
}
