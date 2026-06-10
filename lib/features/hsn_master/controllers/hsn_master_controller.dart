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
  final hsnDetailItemFormKey = GlobalKey<FormState>();

  var hsnNoController = TextEditingController();
  var orgHsnNoController = TextEditingController();
  var chapterNoController = TextEditingController();
  var unitController = TextEditingController();
  var ewbUnitController = TextEditingController();
  var descriptionController = TextEditingController();

  // Tax detail item form fields
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

  // HSN Detail items list (like itemsToSend in IndentEntryController)
  var hsnDetails = <Map<String, dynamic>>[].obs;
  var isEditingDetail = false.obs;
  var editingDetailIndex = (-1).obs;

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

  void loadHsnDetailsFromApi(List<dynamic> details) {
    // details: List<HsnMasterDetailDm>
    hsnDetails.assignAll(
      details
          .map(
            (d) => {
              "TCode": d.tCode,
              "TName": d.tName,
              "EffectDate": d.effectDate, // yyyy-MM-dd or as returned
              "IGST": d.igst,
              "SGST": d.sgst,
              "CGST": d.cgst,
            },
          )
          .toList(),
    );
  }

  // Prepare to add a new detail item
  void prepareAddDetail() {
    clearDetailForm();
    isEditingDetail.value = false;
    editingDetailIndex.value = -1;
  }

  // Prepare to edit an existing detail item
  void prepareEditDetail(int index) {
    isLoading.value = true;
    try {
      final detail = hsnDetails[index];
      selectedTCode.value = detail['TCode'] ?? '';
      selectedTaxName.value = detail['TName'] ?? '';
      igstController.text = (detail['IGST'] ?? 0.0).toString();
      sgstController.text = (detail['SGST'] ?? 0.0).toString();
      cgstController.text = (detail['CGST'] ?? 0.0).toString();

      final rawDate = detail['EffectDate']?.toString() ?? '';
      // Support both dd-MM-yyyy and yyyy-MM-dd
      effectDateController.text = rawDate.isNotEmpty
          ? _ensureDdMmYyyy(rawDate)
          : '';

      isEditingDetail.value = true;
      editingDetailIndex.value = index;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void clearDetailForm() {
    effectDateController.clear();
    igstController.clear();
    sgstController.clear();
    cgstController.clear();
    selectedTaxName.value = '';
    selectedTCode.value = '';
  }

  void addOrUpdateDetail() {
    final Map<String, dynamic> detailData = {
      "TCode": selectedTCode.value,
      "TName": selectedTaxName.value,
      "EffectDate": _convertToApiDateFormat(effectDateController.text),
      "IGST": double.tryParse(igstController.text.trim()) ?? 0.0,
      "SGST": double.tryParse(sgstController.text.trim()) ?? 0.0,
      "CGST": double.tryParse(cgstController.text.trim()) ?? 0.0,
    };

    if (isEditingDetail.value) {
      hsnDetails[editingDetailIndex.value] = detailData;
    } else {
      hsnDetails.add(detailData);
    }

    Get.back();
  }

  void deleteDetail(int index) {
    if (index >= 0 && index < hsnDetails.length) {
      hsnDetails.removeAt(index);
    }
  }

  String _ensureDdMmYyyy(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length < 3) return dateStr;
    // If first part length == 4, it's yyyy-MM-dd → convert
    if (parts[0].length == 4) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return dateStr; // already dd-MM-yyyy
  }

  String _convertToApiDateFormat(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length < 3) return dateStr;
    // If first part length == 4, already yyyy-MM-dd
    if (parts[0].length == 4) return dateStr;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Future<void> addUpdateHsnMaster() async {
    isLoading.value = true;
    try {
      final response = await HsnMasterRepo.addUpdateHsnMaster(
        hsnNo: hsnNoController.text.trim(),
        orgHsnNo: orgHsnNoController.text.trim(),
        chapterNo: chapterNoController.text.trim(),
        unit: unitController.text.trim(),
        ewbUnit: ewbUnitController.text.trim(),
        description: descriptionController.text.trim(),
        sac: sac.value,
        hsnDetail: hsnDetails
            .map(
              (d) => {
                "TCode": d['TCode'],
                "EffectDate": d['EffectDate'],
                "IGST": d['IGST'],
                "SGST": d['SGST'],
                "CGST": d['CGST'],
              },
            )
            .toList(),
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
    sac.value = false;
    isEditMode.value = false;
    hsnDetails.clear();
    clearDetailForm();
  }
}
