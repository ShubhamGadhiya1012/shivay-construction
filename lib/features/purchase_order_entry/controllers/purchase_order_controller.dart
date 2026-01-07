import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/purchase_order_list_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/auth_indent_item_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/repos/purchase_order_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchaseOrderController extends GetxController {
  var isLoading = false.obs;
  final purchaseOrderFormKey = GlobalKey<FormState>();

  var dateController = TextEditingController();
  var remarksController = TextEditingController();

  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;
  var selectedGodownName = ''.obs;
  var selectedGodownCode = ''.obs;
  var selectedSiteCode = ''.obs;
  var siteNameController = TextEditingController();

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var sites = <SiteMasterDm>[].obs;

  var attachmentFiles = <PlatformFile>[].obs;
  var existingAttachmentUrls = <String>[].obs;

  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  var currentStep = 0.obs;

  var authIndentItems = <AuthIndentItemDm>[].obs;
  var isSelectionMode = false.obs;
  var expandedItemIndices = <int>[].obs;

  Future<void> getSites() async {
    try {
      isLoading.value = true;
      final fetchedSites = await SiteMasterListRepo.getSites();
      sites.assignAll(fetchedSites);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGodowns() async {
    try {
      isLoading.value = true;
      await getSites();
      final fetchedGodowns = await GodownMasterRepo.getGodowns();
      godowns.assignAll(fetchedGodowns);
      godownNames.assignAll(fetchedGodowns.map((gd) => gd.gdName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onGodownSelected(String? godownName) {
    selectedGodownName.value = godownName!;
    var selectedGodownObj = godowns.firstWhere((gd) => gd.gdName == godownName);
    selectedGodownCode.value = selectedGodownObj.gdCode;
    selectedSiteCode.value = selectedGodownObj.siteCode;

    if (selectedGodownObj.siteCode.isNotEmpty) {
      final site = sites.firstWhereOrNull(
        (s) => s.siteCode == selectedGodownObj.siteCode,
      );
      siteNameController.text = site?.siteName ?? '';
    } else {
      siteNameController.clear();
    }
  }

  Future<void> getParties() async {
    try {
      isLoading.value = true;
      final fetchedParties = await PartyMasterListRepo.getParties();
      parties.assignAll(fetchedParties);
      partyNames.assignAll(fetchedParties.map((p) => p.accountName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onPartySelected(String? partyName) {
    selectedPartyName.value = partyName!;
    var selectedPartyObj = parties.firstWhere(
      (p) => p.accountName == partyName,
    );
    selectedPartyCode.value = selectedPartyObj.pCode;
  }

  Future<void> pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        final File file = File(photo.path);
        final bytes = await file.readAsBytes();

        final platformFile = PlatformFile(
          name: photo.name,
          size: bytes.length,
          path: photo.path,
          bytes: bytes,
        );

        attachmentFiles.add(platformFile);
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to capture image: ${e.toString()}');
    }
  }

  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'xls',
          'xlsx',
        ],
      );

      if (result != null) {
        attachmentFiles.addAll(result.files);
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to pick files: ${e.toString()}');
    }
  }

  void removeFile(int index) {
    attachmentFiles.removeAt(index);
  }

  void removeExistingAttachment(int index) {
    existingAttachmentUrls.removeAt(index);
  }

  Future<void> openAttachment(String fileUrl) async {
    String url = 'http://192.168.0.145:5020/${fileUrl.replaceAll('\\', '/')}';

    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          showErrorSnackbar('Error', 'Could not open attachment');
        }
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to open attachment: ${e.toString()}');
    }
  }

  String _convertToApiDateFormat(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  void nextStep() {
    if (currentStep.value == 0) {
      if (purchaseOrderFormKey.currentState!.validate()) {
        currentStep.value = 1;
        getAuthIndentItems();
      }
    }
  }

  void previousStep() {
    if (currentStep.value == 1) {
      currentStep.value = 0;
    }
  }

  Future<void> getAuthIndentItems() async {
    isLoading.value = true;
    try {
      final fetchedItems = await PurchaseOrderRepo.getAuthIndentItems(
        siteCode: selectedSiteCode.value,
        gdCode: selectedGodownCode.value,
      );
      authIndentItems.assignAll(fetchedItems);

      expandedItemIndices.clear();
      for (int i = 0; i < fetchedItems.length; i++) {
        expandedItemIndices.add(i);
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void toggleItemExpansion(int index) {
    if (expandedItemIndices.contains(index)) {
      expandedItemIndices.remove(index);
    } else {
      expandedItemIndices.add(index);
    }
  }

  void toggleIndentSelection(int itemIndex, int indentIndex) {
    authIndentItems[itemIndex].indents[indentIndex].isSelected =
        !authIndentItems[itemIndex].indents[indentIndex].isSelected;
    authIndentItems.refresh();

    bool anySelected = authIndentItems.any(
      (item) => item.indents.any((indent) => indent.isSelected),
    );
    isSelectionMode.value = anySelected;
  }

  void enableSelectionMode(int itemIndex, int indentIndex) {
    isSelectionMode.value = true;
    authIndentItems[itemIndex].indents[indentIndex].isSelected = true;
    authIndentItems.refresh();
  }

  void selectAllIndents() {
    for (var item in authIndentItems) {
      for (var indent in item.indents) {
        indent.isSelected = true;
      }
    }
    authIndentItems.refresh();
    isSelectionMode.value = true;
  }

  void deselectAllIndents() {
    for (var item in authIndentItems) {
      for (var indent in item.indents) {
        indent.isSelected = false;
      }
    }
    authIndentItems.refresh();
    isSelectionMode.value = false;
  }

  List<Map<String, dynamic>> getSelectedIndentsData() {
    List<Map<String, dynamic>> selectedData = [];
    int srNo = 1;

    for (var item in authIndentItems) {
      for (var indent in item.indents) {
        if (indent.isSelected) {
          selectedData.add({
            'SrNo': srNo,
            'ICode': item.iCode,
            'Unit': 'Nos',
            'Qty': indent.authoriseQty,
            'IndentNo': indent.indentNo,
            'IndentSrNo': indent.indentSrNo,
          });
          srNo++;
        }
      }
    }

    return selectedData;
  }

  final PurchaseOrderListController purchaseOrderListController =
      Get.find<PurchaseOrderListController>();

  Future<void> savePurchaseOrder() async {
    isLoading.value = true;

    try {
      final selectedItems = getSelectedIndentsData();

      if (selectedItems.isEmpty) {
        showErrorSnackbar('Error', 'Please select at least one indent');
        return;
      }

      var response = await PurchaseOrderRepo.savePurchaseOrder(
        invNo: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),
        gdCode: selectedGodownCode.value,
        pCode: selectedPartyCode.value,
        remarks: remarksController.text.trim(),
        siteCode: selectedSiteCode.value,
        itemData: selectedItems,
        newFiles: attachmentFiles.toList(),
        existingAttachments: existingAttachmentUrls.toList(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        purchaseOrderListController.getPurchaseOrders();
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

  void clearAll() {
    currentInvNo.value = '';
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    remarksController.clear();
    siteNameController.clear();

    selectedGodownName.value = '';
    selectedGodownCode.value = '';
    selectedSiteCode.value = '';
    selectedPartyName.value = '';
    selectedPartyCode.value = '';

    attachmentFiles.clear();
    existingAttachmentUrls.clear();
    authIndentItems.clear();

    currentStep.value = 0;
    isEditMode.value = false;
    isSelectionMode.value = false;
    expandedItemIndices.clear();
  }
}
