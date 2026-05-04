import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/hsn_master/controllers/hsn_master_list_controller.dart';
import 'package:shivay_construction/features/hsn_master/models/hsn_master_dm.dart';
import 'package:shivay_construction/features/hsn_master/repos/hsn_master_repo.dart';
import 'package:shivay_construction/features/tax_master/models/tax_master_dm.dart';
import 'package:shivay_construction/features/tax_master/repos/tax_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class HsnMasterController extends GetxController {
  var isLoading = false.obs;
  final hsnFormKey = GlobalKey<FormState>();

  var hsnNoController = TextEditingController();
  var orgHsnNoController = TextEditingController();
  var chapterNoController = TextEditingController();
  var unitController = TextEditingController();
  var ewbUnitController = TextEditingController();
  var descriptionController = TextEditingController();
  var effectDateController = TextEditingController();
  var igstController = TextEditingController();
  var sgstController = TextEditingController();
  var cgstController = TextEditingController();

  var taxList = <TaxMasterDm>[].obs;
  var taxNames = <String>[].obs;
  var selectedTaxName = ''.obs;
  var selectedTCode = ''.obs;

  var sac = false.obs;

  var isEditMode = false.obs;

  void toggleSac() {
    sac.value = !sac.value;
  }

  @override
  void onInit() async {
    super.onInit();
    await fetchTaxList();
  }

  Future<void> fetchTaxList() async {
    try {
      final data = await TaxMasterListRepo.getTaxList();
      taxList.assignAll(data);
      taxNames.assignAll(data.map((e) => e.taxName));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  // FULL onTaxSelected - NEW METHOD
  void onTaxSelected(String? taxName) {
    if (taxName != null && taxName.isNotEmpty) {
      selectedTaxName.value = taxName;
      final selected = taxList.firstWhere((e) => e.taxName == taxName);
      selectedTCode.value = selected.tCode;
    }
  }

  void autoFillDataForEdit(HsnMasterDm hsn) {
    isEditMode.value = true;

    hsnNoController.text = hsn.hsnNo;
    orgHsnNoController.text = hsn.orgHsnNo;
    chapterNoController.text = hsn.chapterNo;
    unitController.text = hsn.unit;
    ewbUnitController.text = hsn.ewbUnit;
    descriptionController.text = hsn.description;
    sac.value = hsn.sac;
  }

  void fillDetailData({
    required double igst,
    required double sgst,
    required double cgst,
    required String effectDate,
    required String tCode,
    required String tName, // ADD THIS
  }) {
    igstController.text = igst.toString();
    sgstController.text = sgst.toString();
    cgstController.text = cgst.toString();
    effectDateController.text = _convertyyyyMMddToddMMyyyy(effectDate);

    selectedTCode.value = tCode;
    selectedTaxName.value =
        tName; // USE tName DIRECTLY — no need to search taxList
  }

  String _convertyyyyMMddToddMMyyyy(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length < 3) return dateStr;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  String _convertToApiDateFormat(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length < 3) return dateStr;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Future<void> addUpdateHsnMaster() async {
    isLoading.value = true;
    try {
      final response = await HsnMasterRepo.addUpdateHsnMaster(
        hsnNo: hsnNoController.text,
        orgHsnNo: orgHsnNoController.text.trim(),
        chapterNo: chapterNoController.text.trim(),
        unit: unitController.text.trim(),
        ewbUnit: ewbUnitController.text.trim(),
        description: descriptionController.text.trim(),
        effectDate: _convertToApiDateFormat(effectDateController.text.trim()),
        igst: double.tryParse(igstController.text.trim()) ?? 0.0,
        sgst: double.tryParse(sgstController.text.trim()) ?? 0.0,
        cgst: double.tryParse(cgstController.text.trim()) ?? 0.0,
        sac: sac.value,
        tCode: selectedTCode.value,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        showSuccessSnackbar('Success', message);
        if (Get.isRegistered<HsnMasterListController>()) {
          final listController = Get.find<HsnMasterListController>();
          await listController.getHsnList();
          listController.filterHsnList(listController.searchController.text);
          listController.resetExpandedIndex();
        }
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

  void clearAll() {
    hsnNoController.clear();
    orgHsnNoController.clear();
    chapterNoController.clear();
    unitController.clear();
    ewbUnitController.clear();
    descriptionController.clear();
    effectDateController.clear();
    igstController.clear();
    sgstController.clear();
    cgstController.clear();
    sac.value = false;
    isEditMode.value = false;
    selectedTaxName.value = '';
    selectedTCode.value = '';
  }
}
