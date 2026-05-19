import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/issue_entry/controllers/issues_controller.dart';
import 'package:shivay_construction/features/issue_entry/models/grn_item_dm.dart';
import 'package:shivay_construction/features/issue_entry/repos/grn_items_repo.dart';
import 'package:shivay_construction/features/issue_entry/repos/issue_entry_repo.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class IssueEntryController extends GetxController {
  var isLoading = false.obs;
  final issueFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();
  var remarkController = TextEditingController();

  var currentStep = 0.obs;

  // GRN items for selection
  var grnItems = <GrnItemForIssueDm>[].obs;
  var expandedGrnIndices = <int>[].obs;
  var isInSelectionMode = false.obs;

  // Selected items - key: grnInvNo_grnSrNo
  var selectedItems = <String, Map<String, dynamic>>{}.obs;
  var qtyControllers = <String, TextEditingController>{}.obs;

  // Godowns
  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;

  // Per-item godown selection - key: grnInvNo_grnSrNo
  var selectedItemGodownCode = <String, String>{}.obs;
  var selectedItemGodownName = <String, String>{}.obs;

  // Contractors/Sub-Contractors - key: grnInvNo_grnSrNo
  var selectedItemCpCode = <String, String>{}.obs;
  var selectedItemCpName = <String, String>{}.obs;
  var contractorList = <PartyMasterDm>[].obs;
  var contractorNames = <String>[].obs;

  // Locked GRN (only one GRN's items can be selected at a time)
  var lockedGrnInvNo = ''.obs;
  var lockedGrnPCode = ''.obs;
  var lockedGrnPName = ''.obs;
  var lockedGrnSiteCode = ''.obs;
  var lockedGrnSiteName = ''.obs;

  final IssuesController issuesController = Get.find<IssuesController>();

  @override
  void onClose() {
    dateController.dispose();
    remarkController.dispose();
    _disposeQtyControllers();
    super.onClose();
  }

  void _disposeQtyControllers() {
    for (var c in qtyControllers.values) {
      c.dispose();
    }
    qtyControllers.clear();
  }

  Future<void> getGodowns() async {
    try {
      isLoading.value = true;
      final fetchedGodowns = await GodownMasterRepo.getGodowns(siteCode: "");
      godowns.assignAll(fetchedGodowns);
      godownNames.assignAll(fetchedGodowns.map((gd) => gd.gdName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getContractors() async {
    try {
      isLoading.value = true;
      // Fetch contractors and sub-contractors where isContSubCont = true
      final fetchedContractors = await PartyMasterListRepo.getParties(
        isContSubCont: true,
      );
      contractorList.assignAll(fetchedContractors);
      contractorNames.assignAll(
        fetchedContractors.map((c) => c.accountName).toList(),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGrnItems() async {
    try {
      isLoading.value = true;

      final fetched = await GrnItemsForIssueRepo.getGrnItems();
      grnItems.assignAll(fetched);

      if (fetched.isEmpty) {
        showErrorSnackbar('Info', 'No GRN items available for issue');
        return;
      }

      expandedGrnIndices.clear();
      for (int i = 0; i < fetched.length; i++) {
        expandedGrnIndices.add(i);
      }

      // Init qty controllers and default godown/contractor for each item
      for (var grn in fetched) {
        for (var item in grn.items) {
          final key = '${grn.grnInvNo}_${item.grnSrNo}';
          if (!qtyControllers.containsKey(key)) {
            qtyControllers[key] = TextEditingController(
              text: item.pendingQty.toStringAsFixed(2),
            );
          }
          // Pre-fill godown from item's gdCode/gdName
          if (!selectedItemGodownCode.containsKey(key)) {
            selectedItemGodownCode[key] = item.gdCode;
            selectedItemGodownName[key] = item.gdName;
          }
          // Pre-fill contractor from item's cpCode/cpName
          if (!selectedItemCpCode.containsKey(key)) {
            selectedItemCpCode[key] = item.cpCode;
            selectedItemCpName[key] = item.cpName;
          }
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onItemGodownSelected(String key, String? godownName) {
    selectedItemGodownName[key] = godownName ?? '';
    final gd = godowns.firstWhereOrNull((g) => g.gdName == godownName);
    selectedItemGodownCode[key] = gd?.gdCode ?? '';

    // Update selectedItems map if item is selected
    if (selectedItems.containsKey(key)) {
      selectedItems[key]!['gdCode'] = selectedItemGodownCode[key];
      selectedItems[key]!['gdName'] = godownName ?? '';
      selectedItems.refresh();
    }

    selectedItemGodownName.refresh();
    selectedItemGodownCode.refresh();
  }

  void onItemContractorSelected(String key, String? contractorName) {
    selectedItemCpName[key] = contractorName ?? '';
    final contractor = contractorList.firstWhereOrNull(
      (c) => c.accountName == contractorName,
    );
    selectedItemCpCode[key] = contractor?.pCode ?? '';

    // Update selectedItems map if item is selected
    if (selectedItems.containsKey(key)) {
      selectedItems[key]!['cpCode'] = selectedItemCpCode[key];
      selectedItems[key]!['cpName'] = contractorName ?? '';
      selectedItems.refresh();
    }

    selectedItemCpName.refresh();
    selectedItemCpCode.refresh();
  }

  void toggleGrnExpansion(int index) {
    if (expandedGrnIndices.contains(index)) {
      expandedGrnIndices.remove(index);
    } else {
      expandedGrnIndices.add(index);
    }
  }

  bool toggleItemSelection(GrnItemForIssueDm grn, GrnItemDetailDm item) {
    final key = '${grn.grnInvNo}_${item.grnSrNo}';

    if (selectedItems.containsKey(key)) {
      selectedItems.remove(key);
      _updateLockIfNoSelection();
      if (selectedItems.isEmpty) {
        isInSelectionMode.value = false;
      }
      return true;
    }

    // Lock to one GRN only
    if (lockedGrnInvNo.value.isEmpty) {
      lockedGrnInvNo.value = grn.grnInvNo;
      lockedGrnPCode.value = grn.pCode;
      lockedGrnPName.value = grn.pName;
      lockedGrnSiteCode.value = grn.siteCode;
      lockedGrnSiteName.value = grn.siteName;
    } else {
      if (grn.grnInvNo != lockedGrnInvNo.value) {
        showErrorSnackbar(
          'GRN Mismatch',
          'You can only select items from "${lockedGrnInvNo.value}". Deselect all to change.',
        );
        return false;
      }
    }

    final qtyController = qtyControllers[key];
    final issueQty =
        double.tryParse(qtyController?.text ?? '') ?? item.pendingQty;

    selectedItems[key] = {
      'grnInvNo': grn.grnInvNo,
      'grnSrNo': item.grnSrNo,
      'iCode': item.iCode,
      'iName': item.iName,
      'unit': item.unit,
      'rate': item.rate,
      'grnQty': item.grnQty,
      'issuedQty': item.issuedQty,
      'pendingQty': item.pendingQty,
      'issueQty': issueQty,
      'gdCode': selectedItemGodownCode[key] ?? item.gdCode,
      'gdName': selectedItemGodownName[key] ?? item.gdName,
      'cpCode': selectedItemCpCode[key] ?? item.cpCode,
      'cpName': selectedItemCpName[key] ?? item.cpName,
    };

    return true;
  }

  void onItemLongPress(GrnItemForIssueDm grn, GrnItemDetailDm item) {
    if (!isInSelectionMode.value) {
      isInSelectionMode.value = true;
    }
    toggleItemSelection(grn, item);
  }

  bool isItemSelected(String grnInvNo, int grnSrNo) {
    final key = '${grnInvNo}_$grnSrNo';
    return selectedItems.containsKey(key);
  }

  void updateIssueQty(String grnInvNo, int grnSrNo, double qty) {
    final key = '${grnInvNo}_$grnSrNo';
    if (selectedItems.containsKey(key)) {
      selectedItems[key]!['issueQty'] = qty;
      selectedItems.refresh();
    }
  }

  void deselectAllItems() {
    selectedItems.clear();
    _clearLock();
    isInSelectionMode.value = false;
  }

  void _clearLock() {
    lockedGrnInvNo.value = '';
    lockedGrnPCode.value = '';
    lockedGrnPName.value = '';
    lockedGrnSiteCode.value = '';
    lockedGrnSiteName.value = '';
  }

  void _updateLockIfNoSelection() {
    if (selectedItems.isEmpty) {
      _clearLock();
    }
  }

  void removeSelectedItem(String key) {
    selectedItems.remove(key);
    _updateLockIfNoSelection();
    if (selectedItems.isEmpty) {
      isInSelectionMode.value = false;
    }
  }

  void proceedToForm() {
    if (selectedItems.isEmpty) {
      showErrorSnackbar('Error', 'Please select at least one item');
      return;
    }

    bool hasError = false;
    for (var entry in selectedItems.entries) {
      final issueQty = entry.value['issueQty'] as double;
      final pendingQty = entry.value['pendingQty'] as double;
      if (issueQty <= 0) {
        showErrorSnackbar('Error', 'Issue quantity must be greater than 0');
        hasError = true;
        break;
      }
      if (issueQty > pendingQty) {
        showErrorSnackbar(
          'Error',
          'Issue quantity cannot exceed pending quantity',
        );
        hasError = true;
        break;
      }
    }
    if (!hasError) {
      currentStep.value = 1;
    }
  }

  void goBackToSelection() {
    currentStep.value = 0;
  }

  Future<void> saveIssueEntry() async {
    if (!issueFormKey.currentState!.validate()) return;

    if (selectedItems.isEmpty) {
      showErrorSnackbar('Error', 'Please select at least one item');
      return;
    }

    isLoading.value = true;

    try {
      final List<Map<String, dynamic>> issueItems = selectedItems.values
          .map(
            (item) => {
              'iCode': item['iCode'],
              'qty': item['issueQty'],
              'rate': item['rate'],
              'gdCode': item['gdCode'] ?? '',
              'cpCode': item['cpCode'] ?? '',
            },
          )
          .toList();

      final response = await IssueEntryRepo.saveIssueEntry(
        date: _convertToApiDateFormat(dateController.text),
        siteCode: lockedGrnSiteCode.value,
        pCode: lockedGrnPCode.value,
        remark: remarkController.text,
        refInvNo: lockedGrnInvNo.value,
        issueItems: issueItems,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        issuesController.getIssues();
        Get.back();
        showSuccessSnackbar('Success', message);
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

  String _convertToApiDateFormat(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Future<void> clearAll() async {
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    remarkController.clear();
    selectedItems.clear();
    grnItems.clear();
    expandedGrnIndices.clear();
    isInSelectionMode.value = false;
    currentStep.value = 0;
    _clearLock();
    _disposeQtyControllers();
    selectedItemGodownCode.clear();
    selectedItemGodownName.clear();
    selectedItemCpCode.clear();
    selectedItemCpName.clear();
  }
}
