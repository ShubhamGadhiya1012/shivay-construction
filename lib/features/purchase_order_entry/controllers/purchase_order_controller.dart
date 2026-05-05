import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/features/party_masters/repos/party_master_list_repo.dart';
import 'package:shivay_construction/features/purchase_order_entry/controllers/purchase_order_list_controller.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/auth_indent_item_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/customise_voucher_po_dm.dart.dart';
import 'package:shivay_construction/features/purchase_order_entry/repos/purchase_order_repo.dart';
import 'package:shivay_construction/features/tax_master/models/tax_master_dm.dart';
import 'package:shivay_construction/features/tax_master/repos/tax_master_list_repo.dart';
import 'package:shivay_construction/features/term_master/models/term_master_dm.dart';
import 'package:shivay_construction/features/term_master/repos/term_master_repo.dart';
import 'package:shivay_construction/services/api_service.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../godown_master/repos/godown_master_repo.dart';

class PurchaseOrderController extends GetxController {
  var isLoading = false.obs;
  final purchaseOrderFormKey = GlobalKey<FormState>();

  var authIndentItems = <AuthIndentItemDm>[].obs;
  var isSelectionMode = false.obs;
  var expandedItemIndices = <int>[].obs;
  var selectedPurchaseItems = <Map<String, dynamic>>[].obs;
  var discountPercControllers = <String, TextEditingController>{}.obs;
  var discountAmountControllers = <String, TextEditingController>{}.obs;

  var qtyControllers = <String, TextEditingController>{}.obs;
  var priceControllers = <String, TextEditingController>{}.obs;
  var dateControllers = <String, TextEditingController>{}.obs;
  var remarkControllers = <String, TextEditingController>{}.obs;
  var _userEditingDiscountAmount = false;
  var _userEditingDiscountPerc = false;
  var godowns = <dynamic>[].obs;
  var godownNames = <String>[].obs;
  var selectedGodownName = <String, String>{}.obs;
  var selectedGodownCode = <String, String>{}.obs;

  var lockedSiteCode = ''.obs;
  var lockedSiteName = ''.obs;

  var dateController = TextEditingController();
  var remarksController = TextEditingController();

  var selectedSiteName = ''.obs;
  var selectedSiteCode = ''.obs;

  var parties = <PartyMasterDm>[].obs;
  var partyNames = <String>[].obs;
  var selectedPartyName = ''.obs;
  var selectedPartyCode = ''.obs;

  var taxTypes = <TaxMasterDm>[].obs;
  var taxTypeNames = <String>[].obs;
  var selectedTaxTypeName = ''.obs;
  var selectedTaxTypeCode = ''.obs;
  var isIGSTApplicable = false.obs;
  var isCGSTApplicable = false.obs;
  var isSGSTApplicable = false.obs;

  var attachmentFiles = <PlatformFile>[].obs;
  var existingAttachmentUrls = <String>[].obs;

  var isEditMode = false.obs;
  var currentInvNo = ''.obs;

  var customiseVoucher = <PurchaseOrderCustomiseVoucherDm>[].obs;
  var ledgerDataToSend = <Map<String, dynamic>>[].obs;
  var customiseVoucherAmountControllers = <String, TextEditingController>{}.obs;
  var customiseVoucherPercentageControllers =
      <String, TextEditingController>{}.obs;

  var grossTotal = 0.0.obs;
  var totalIgst = 0.0.obs;
  var totalCgst = 0.0.obs;
  var totalSgst = 0.0.obs;
  var valueOfGoodsToSend = 0.0.obs;
  var netTotalToSend = 0.0.obs;

  bool _isUpdatingLedger = false;

  var termsList = <TermMasterDm>[].obs;
  var selectedTermCodes = <String>[].obs;

  var editableTermDescriptions = <String, TextEditingController>{}.obs;

  var manualTermControllers = <TextEditingController>[].obs;

  var currentStep = 0.obs;

  void onPartySelected(String? partyName) {
    selectedPartyName.value = partyName!;
    final obj = parties.firstWhere((p) => p.accountName == partyName);
    selectedPartyCode.value = obj.pCode;
  }

  void onTaxTypeSelected(String? taxTypeName) {
    if (taxTypeName == null) return;
    selectedTaxTypeName.value = taxTypeName;
    final obj = taxTypes.firstWhere((t) => t.taxName == taxTypeName);
    selectedTaxTypeCode.value = obj.tCode;
    isIGSTApplicable.value = obj.igst;
    isCGSTApplicable.value = obj.cgst;
    isSGSTApplicable.value = obj.sgst;
  }

  Future<void> getParties() async {
    try {
      isLoading.value = true;
      final fetched = await PartyMasterListRepo.getParties();
      parties.assignAll(fetched);
      partyNames.assignAll(fetched.map((p) => p.accountName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTaxTypes() async {
    try {
      isLoading.value = true;
      final fetched = await TaxMasterListRepo.getTaxList();
      taxTypes.assignAll(fetched);
      taxTypeNames.assignAll(fetched.map((t) => t.taxName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTermsList() async {
    try {
      isLoading.value = true;
      final fetched = await TermMasterRepo.getTerms();
      termsList.assignAll(fetched);

      selectedTermCodes.assignAll(
        fetched.where((t) => t.isFix).map((t) => t.termCode).toList(),
      );

      for (final c in editableTermDescriptions.values) {
        c.dispose();
      }
      editableTermDescriptions.clear();

      for (final term in fetched) {
        editableTermDescriptions[term.termCode] = TextEditingController(
          text: term.termName,
        );
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTermSelection(String termCode) {
    if (selectedTermCodes.contains(termCode)) {
      selectedTermCodes.remove(termCode);
    } else {
      selectedTermCodes.add(termCode);
    }
    selectedTermCodes.refresh();
  }

  void addManualTerm() {
    manualTermControllers.add(TextEditingController());
    manualTermControllers.refresh();
  }

  void removeManualTerm(int index) {
    manualTermControllers[index].dispose();
    manualTermControllers.removeAt(index);
    manualTermControllers.refresh();
  }

  List<Map<String, dynamic>> getTermsForAPI() {
    final result = <Map<String, dynamic>>[];

    for (final termCode in selectedTermCodes) {
      final editedText = editableTermDescriptions[termCode]?.text.trim() ?? '';
      result.add({
        'TermCode': termCode,
        'Description': editedText,
        'IsManual': false,
      });
    }

    for (final ctrl in manualTermControllers) {
      final text = ctrl.text.trim();
      if (text.isNotEmpty) {
        result.add({'TermCode': '', 'Description': text, 'IsManual': true});
      }
    }

    return result;
  }

  Future<void> getGodowns([String siteCode = '']) async {
    try {
      isLoading.value = true;
      final fetched = await GodownMasterRepo.getGodowns(siteCode: siteCode);
      final parentGodowns = fetched.where((gd) => !gd.isSubGodown).toList();
      godowns.assignAll(parentGodowns);
      godownNames.assignAll(parentGodowns.map((gd) => gd.gdName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onGodownSelected(String key, String? godownName) {
    selectedGodownName[key] = godownName ?? '';
    final obj = godowns.firstWhereOrNull((gd) => gd.gdName == godownName);
    selectedGodownCode[key] = obj?.gdCode ?? '';
    selectedGodownName.refresh();
    selectedGodownCode.refresh();
  }

  Future<void> pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        final file = File(photo.path);
        final bytes = await file.readAsBytes();
        attachmentFiles.add(
          PlatformFile(
            name: photo.name,
            size: bytes.length,
            path: photo.path,
            bytes: bytes,
          ),
        );
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to capture image: ${e.toString()}');
    }
  }

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
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

  void removeFile(int index) => attachmentFiles.removeAt(index);
  void removeExistingAttachment(int index) =>
      existingAttachmentUrls.removeAt(index);

  Future<void> openAttachment(String fileUrl) async {
    final url =
        '${ApiService.kBaseUrl.replaceAll('/api', '')}/${fileUrl.replaceAll('\\', '/')}';
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to open attachment: ${e.toString()}');
    }
  }

  void proceedToForm() {
    if (selectedPurchaseItems.isEmpty) {
      showErrorSnackbar('Error', 'Please select at least one indent');
      return;
    }
    currentStep.value = 1;
  }

  void goBackToSelection() => currentStep.value = 0;

  Future<void> proceedToLedger() async {
    if (!purchaseOrderFormKey.currentState!.validate()) return;
    if (selectedPartyCode.value.isEmpty) {
      showErrorSnackbar('Error', 'Please select a party');
      return;
    }
    if (selectedTaxTypeCode.value.isEmpty) {
      showErrorSnackbar('Error', 'Please select a tax type');
      return;
    }

    isLoading.value = true;
    try {
      for (var item in selectedPurchaseItems) {
        final key = '${item['IndentNo']}_${item['IndentSrNo']}';
        final qty = double.tryParse(qtyControllers[key]?.text ?? '');
        final price = double.tryParse(priceControllers[key]?.text ?? '');
        if (qty != null) item['Qty'] = qty;
        if (price != null) item['Price'] = price;
      }
      selectedPurchaseItems.refresh();

      for (var item in selectedPurchaseItems) {
        final iCode = item['ICode'] as String;
        final taxData = await PurchaseOrderRepo.getItemTax(
          tCode: selectedTaxTypeCode.value,
          iCode: iCode,
        );
        if (taxData.isNotEmpty) {
          final td = taxData.first;
          item['IGSTPerc'] = td.igst;
          item['CGSTPerc'] = td.cgst;
          item['SGSTPerc'] = td.sgst;
          item['HSNNo'] = td.hsnNo ?? '';
        } else {
          item['IGSTPerc'] = 0.0;
          item['CGSTPerc'] = 0.0;
          item['SGSTPerc'] = 0.0;
          item['HSNNo'] = '';
        }
      }
      selectedPurchaseItems.refresh();

      updateGrossTotal();

      final bookCode = '1001';
      final vouchers = await PurchaseOrderRepo.getCustomiseVoucher(
        bookCode: bookCode,
        dbc: 'PURC',
      );
      customiseVoucher.assignAll(vouchers);
      _fillLedgerDataToSend();
      _syncLedgerTotals();
      updateLedger();

      currentStep.value = 2;
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void proceedToTerms() async {
    await getTermsList();
    currentStep.value = 3;
  }

  void goBackToLedger() => currentStep.value = 2;
  void goBackToForm() => currentStep.value = 1;

  void updateGrossTotal() {
    grossTotal.value = 0.0;

    for (var item in selectedPurchaseItems) {
      final qty = (item['Qty'] as num?)?.toDouble() ?? 0.0;
      final price = (item['Price'] as num?)?.toDouble() ?? 0.0;
      final amount = qty * price;
      item['Amount'] = amount;
      grossTotal.value += amount;
    }

    totalIgst.value = 0.0;
    totalCgst.value = 0.0;
    totalSgst.value = 0.0;
  }

  String _resolvePCode(String? pCodeFromApi) {
    if (pCodeFromApi == null || pCodeFromApi.trim().isEmpty) {
      return selectedPartyCode.value;
    }
    if (pCodeFromApi.trim() == '< PURCHASE >') {
      return selectedPartyCode.value;
    }
    return pCodeFromApi;
  }

  void _fillLedgerDataToSend() {
    ledgerDataToSend.clear();
    for (final c in customiseVoucherAmountControllers.values) {
      c.dispose();
    }
    for (final c in customiseVoucherPercentageControllers.values) {
      c.dispose();
    }
    customiseVoucherAmountControllers.clear();
    customiseVoucherPercentageControllers.clear();

    ledgerDataToSend.add({
      'SRNO': 2,
      'DESC': 'Gross Total',
      'FORMULA': '',
      'VISIBLE': true,
      'PR': 'R',
      'PERC': '0',
      'AMOUNT': grossTotal.value.toStringAsFixed(2),
      'NT': 'D',
      'PCODE': selectedPartyCode.value,
      'PCODEC': selectedPartyCode.value,
      'ADDLESS': 0,
      'DBC': 'PURC',
    });

    for (var v in customiseVoucher.where((v) => v.srNo != 15)) {
      ledgerDataToSend.add({
        'SRNO': v.srNo + 2,
        'DESC': v.description,
        'FORMULA': v.formula,
        'VISIBLE': v.visible,
        'PR': v.pr,
        'PERC': '0',
        'AMOUNT': '0',
        'NT': v.nt,
        'PCODE': _resolvePCode(v.pCode),
        'PCODEC': '',
        'ADDLESS': v.addLess,
        'DBC': 'PURC',
      });
    }

    ledgerDataToSend.add({
      'SRNO': 1,
      'DESC': 'Net Total',
      'FORMULA':
          'GrossAmt - Discount + P.F. + Freight + Other + IGST + SGST + CGST + NoTaxOth - NoTaxDisc + TCS. - Round [-] + Round [+] + TCS_IT',
      'VISIBLE': true,
      'PR': 'R',
      'PERC': '0',
      'AMOUNT': '0',
      'NT': 'C',
      'PCODE': selectedPartyCode.value,
      'PCODEC': selectedPartyCode.value,
      'ADDLESS': 0,
      'DBC': 'PURC',
    });

    _attachLedgerListeners();
  }

  void _attachLedgerListeners() {
    for (var voucher in ledgerDataToSend) {
      final amtCtrl = TextEditingController(text: voucher['AMOUNT']);
      amtCtrl.addListener(() {
        if (_isUpdatingLedger) return;
        voucher['AMOUNT'] = amtCtrl.text;
        if (voucher['DESC'] == 'Discount') {
          _userEditingDiscountAmount = true;
          _userEditingDiscountPerc = false;
        }
        updateLedger();
      });
      customiseVoucherAmountControllers[voucher['DESC']] = amtCtrl;

      final percCtrl = TextEditingController(text: voucher['PERC']);
      percCtrl.addListener(() {
        if (_isUpdatingLedger) return;
        voucher['PERC'] = percCtrl.text;
        if (voucher['DESC'] == 'Discount') {
          _userEditingDiscountPerc = true;
          _userEditingDiscountAmount = false;
        }
        updateLedger();
      });
      customiseVoucherPercentageControllers[voucher['DESC']] = percCtrl;
    }
  }

  void _syncLedgerTotals() {
    customiseVoucherAmountControllers['Gross Total']?.text = grossTotal.value
        .toStringAsFixed(2);
    if (isIGSTApplicable.value) {
      customiseVoucherAmountControllers['IGST']?.text = totalIgst.value
          .toStringAsFixed(2);
    }
    if (isSGSTApplicable.value) {
      customiseVoucherAmountControllers['SGST']?.text = totalSgst.value
          .toStringAsFixed(2);
    }
    if (isCGSTApplicable.value) {
      customiseVoucherAmountControllers['CGST']?.text = totalCgst.value
          .toStringAsFixed(2);
    }
  }

  void updateLedger() {
    if (_isUpdatingLedger) return;
    _isUpdatingLedger = true;
    try {
      customiseVoucherAmountControllers['Gross Total']?.text = grossTotal.value
          .toStringAsFixed(2);

      final discountPercText =
          customiseVoucherPercentageControllers['Discount']?.text.trim() ?? '0';
      final discountAmtText =
          customiseVoucherAmountControllers['Discount']?.text.trim() ?? '0';
      final discountPercentage = double.tryParse(discountPercText) ?? 0.0;

      double discountAmount;
      if (_userEditingDiscountPerc) {
        discountAmount = (grossTotal.value * discountPercentage) / 100;
        customiseVoucherAmountControllers['Discount']?.text = discountAmount
            .toStringAsFixed(2);
      } else if (_userEditingDiscountAmount) {
        discountAmount = double.tryParse(discountAmtText) ?? 0.0;
        if (grossTotal.value > 0 && discountAmount > 0) {
          final calcPerc = (discountAmount / grossTotal.value) * 100;
          customiseVoucherPercentageControllers['Discount']?.text = calcPerc
              .toStringAsFixed(2);
        } else {
          customiseVoucherPercentageControllers['Discount']?.text = '0';
        }
      } else {
        discountAmount = 0.0;
      }
      final pf =
          double.tryParse(
            customiseVoucherAmountControllers['P.F.']?.text ?? '0',
          ) ??
          0.0;
      final freight =
          double.tryParse(
            customiseVoucherAmountControllers['Freight']?.text ?? '0',
          ) ??
          0.0;
      final other =
          double.tryParse(
            customiseVoucherAmountControllers['Other']?.text ?? '0',
          ) ??
          0.0;
      final noTaxOth =
          double.tryParse(
            customiseVoucherAmountControllers['NoTaxOth']?.text ?? '0',
          ) ??
          0.0;
      final noTaxDisc =
          double.tryParse(
            customiseVoucherAmountControllers['NoTaxDisc']?.text ?? '0',
          ) ??
          0.0;
      final tcsPercentage =
          double.tryParse(
            customiseVoucherPercentageControllers['TCS.']?.text ?? '0',
          ) ??
          0.0;
      final tcsItPercentage =
          double.tryParse(
            customiseVoucherPercentageControllers['TCS_IT']?.text ?? '0',
          ) ??
          0.0;

      bool addToBase(String nt) => nt == 'D';

      String ntOf(String desc) =>
          ledgerDataToSend.firstWhereOrNull((v) => v['DESC'] == desc)?['NT'] ??
          'D';

      final pfNT = ntOf('P.F.');
      final freightNT = ntOf('Freight');
      final otherNT = ntOf('Other');
      final igstNT = ntOf('IGST');
      final sgstNT = ntOf('SGST');
      final cgstNT = ntOf('CGST');
      final noTaxOthNT = ntOf('NoTaxOth');
      final noTaxDiscNT = ntOf('NoTaxDisc');
      final tcsNT = ntOf('TCS.');
      final tcsItNT = ntOf('TCS_IT');

      final totalOriginal = selectedPurchaseItems.fold(0.0, (sum, item) {
        final qty = (item['Qty'] as num?)?.toDouble() ?? 0.0;
        final price = (item['Price'] as num?)?.toDouble() ?? 0.0;
        return sum + qty * price;
      });

      totalIgst.value = 0.0;
      totalSgst.value = 0.0;
      totalCgst.value = 0.0;

      for (var item in selectedPurchaseItems) {
        final qty = (item['Qty'] as num?)?.toDouble() ?? 0.0;
        final price = (item['Price'] as num?)?.toDouble() ?? 0.0;
        final originalAmount = qty * price;

        final itemDiscount = totalOriginal > 0
            ? (originalAmount / totalOriginal) * discountAmount
            : 0.0;
        final discountedAmount = originalAmount - itemDiscount;
        final pfShare = totalOriginal > 0
            ? (originalAmount / totalOriginal) * pf
            : 0.0;
        final freightShare = totalOriginal > 0
            ? (originalAmount / totalOriginal) * freight
            : 0.0;
        final otherShare = totalOriginal > 0
            ? (originalAmount / totalOriginal) * other
            : 0.0;

        double base = discountedAmount;
        base += addToBase(pfNT) ? pfShare : -pfShare;
        base += addToBase(freightNT) ? freightShare : -freightShare;
        base += addToBase(otherNT) ? otherShare : -otherShare;

        final igstRate = (item['IGSTPerc'] as num?)?.toDouble() ?? 0.0;
        final cgstRate = (item['CGSTPerc'] as num?)?.toDouble() ?? 0.0;
        final sgstRate = (item['SGSTPerc'] as num?)?.toDouble() ?? 0.0;

        if (isIGSTApplicable.value) {
          totalIgst.value += (base * igstRate) / 100;
        }
        if (isCGSTApplicable.value) {
          totalCgst.value += (base * cgstRate) / 100;
        }
        if (isSGSTApplicable.value) {
          totalSgst.value += (base * sgstRate) / 100;
        }
      }

      double valueOfGoods = grossTotal.value - discountAmount;
      valueOfGoods += addToBase(pfNT) ? pf : -pf;
      valueOfGoods += addToBase(freightNT) ? freight : -freight;
      valueOfGoods += addToBase(otherNT) ? other : -other;
      valueOfGoodsToSend.value = valueOfGoods;

      double netTotal = valueOfGoods;

      if (customiseVoucherAmountControllers.containsKey('IGST')) {
        if (isIGSTApplicable.value) {
          customiseVoucherAmountControllers['IGST']!.text = totalIgst.value
              .toStringAsFixed(2);
          netTotal += addToBase(igstNT) ? totalIgst.value : -totalIgst.value;
        } else {
          customiseVoucherAmountControllers['IGST']!.text = '0.00';
          totalIgst.value = 0.0;
        }
      }

      if (customiseVoucherAmountControllers.containsKey('CGST')) {
        if (isCGSTApplicable.value) {
          customiseVoucherAmountControllers['CGST']!.text = totalCgst.value
              .toStringAsFixed(2);
          netTotal += addToBase(cgstNT) ? totalCgst.value : -totalCgst.value;
        } else {
          customiseVoucherAmountControllers['CGST']!.text = '0.00';
          totalCgst.value = 0.0;
        }
      }

      if (customiseVoucherAmountControllers.containsKey('SGST')) {
        if (isSGSTApplicable.value) {
          customiseVoucherAmountControllers['SGST']!.text = totalSgst.value
              .toStringAsFixed(2);
          netTotal += addToBase(sgstNT) ? totalSgst.value : -totalSgst.value;
        } else {
          customiseVoucherAmountControllers['SGST']!.text = '0.00';
          totalSgst.value = 0.0;
        }
      }

      netTotal += addToBase(noTaxOthNT) ? noTaxOth : -noTaxOth;
      netTotal += addToBase(noTaxDiscNT) ? noTaxDisc : -noTaxDisc;

      final tcs = grossTotal.value * tcsPercentage / 100;
      customiseVoucherAmountControllers['TCS.']?.text = tcs.toStringAsFixed(2);
      netTotal += addToBase(tcsNT) ? tcs : -tcs;

      double tcsItBase = grossTotal.value - discountAmount;
      tcsItBase += addToBase(pfNT) ? pf : -pf;
      tcsItBase += addToBase(freightNT) ? freight : -freight;
      tcsItBase += addToBase(otherNT) ? other : -other;
      tcsItBase += addToBase(igstNT) ? totalIgst.value : -totalIgst.value;
      tcsItBase += addToBase(sgstNT) ? totalSgst.value : -totalSgst.value;
      tcsItBase += addToBase(cgstNT) ? totalCgst.value : -totalCgst.value;
      tcsItBase += addToBase(noTaxOthNT) ? noTaxOth : -noTaxOth;
      tcsItBase += addToBase(noTaxDiscNT) ? noTaxDisc : -noTaxDisc;
      tcsItBase += addToBase(tcsNT) ? tcs : -tcs;

      final tcsIt = tcsItBase * tcsItPercentage / 100;
      customiseVoucherAmountControllers['TCS_IT']?.text = tcsIt.toStringAsFixed(
        2,
      );
      netTotal += addToBase(tcsItNT) ? tcsIt : -tcsIt;

      final decimalPart = netTotal - netTotal.floorToDouble();
      if (decimalPart < 0.5) {
        customiseVoucherAmountControllers['Round [-]']?.text = decimalPart
            .toStringAsFixed(2);
        customiseVoucherAmountControllers['Round [+]']?.text = '0.00';
        netTotal -= decimalPart;
      } else {
        customiseVoucherAmountControllers['Round [+]']?.text =
            (1.0 - decimalPart).toStringAsFixed(2);
        customiseVoucherAmountControllers['Round [-]']?.text = '0.00';
        netTotal = netTotal.floorToDouble() + 1.0;
      }

      netTotalToSend.value = netTotal;
      customiseVoucherAmountControllers['Net Total']?.text = netTotal
          .toStringAsFixed(2);
    } finally {
      _isUpdatingLedger = false;
    }
  }

  List<Map<String, dynamic>> _getLedgerForAPI() {
    return ledgerDataToSend.map((ledger) {
      return {
        'SRNO': ledger['SRNO'].toString(),
        'PERC': ledger['PERC'].toString(),
        'AMOUNT':
            customiseVoucherAmountControllers[ledger['DESC']]?.text ??
            ledger['AMOUNT'].toString(),
        'NT': ledger['NT'],
        'PCODE': ledger['PCODE'],
      };
    }).toList();
  }

  bool toggleIndentSelection(int itemIndex, int indentIndex) {
    final indent = authIndentItems[itemIndex].items[indentIndex];

    if (lockedSiteCode.value.isEmpty) {
      lockedSiteCode.value = indent.siteCode;
      lockedSiteName.value = indent.siteName;
    } else if (indent.siteCode != lockedSiteCode.value) {
      showErrorSnackbar(
        'Site Mismatch',
        'You can only select indents from "${lockedSiteName.value}".',
      );
      return false;
    }

    indent.isSelected = !indent.isSelected;
    authIndentItems.refresh();
    _syncSelectedPurchaseItems();
    _updateLockIfNoSelection();
    _updateSelectionMode();
    return true;
  }

  void enableSelectionMode(int itemIndex, int indentIndex) {
    final indent = authIndentItems[itemIndex].items[indentIndex];
    if (lockedSiteCode.value.isNotEmpty &&
        indent.siteCode != lockedSiteCode.value) {
      showErrorSnackbar(
        'Site Mismatch',
        'You can only select indents from "${lockedSiteName.value}".',
      );
      return;
    }
    if (lockedSiteCode.value.isEmpty) {
      lockedSiteCode.value = indent.siteCode;
      lockedSiteName.value = indent.siteName;
    }
    isSelectionMode.value = true;
    indent.isSelected = true;
    authIndentItems.refresh();
    _syncSelectedPurchaseItems();
    _updateSelectionMode();
  }

  void selectAllIndents() {
    for (var item in authIndentItems) {
      for (var indent in item.items) {
        if (lockedSiteCode.value.isEmpty) {
          lockedSiteCode.value = indent.siteCode;
          lockedSiteName.value = indent.siteName;
        }
        if (indent.siteCode == lockedSiteCode.value) {
          indent.isSelected = true;
        }
      }
    }
    authIndentItems.refresh();
    _syncSelectedPurchaseItems();
    _updateSelectionMode();
  }

  void deselectAllIndents() {
    for (var item in authIndentItems) {
      for (var indent in item.items) {
        indent.isSelected = false;
      }
    }
    authIndentItems.refresh();
    lockedSiteCode.value = '';
    lockedSiteName.value = '';
    selectedPurchaseItems.clear();
    isSelectionMode.value = false;
  }

  void _updateSelectionMode() {
    isSelectionMode.value = authIndentItems.any(
      (item) => item.items.any((indent) => indent.isSelected),
    );
  }

  void _updateLockIfNoSelection() {
    final anySelected = authIndentItems.any(
      (item) => item.items.any((indent) => indent.isSelected),
    );
    if (!anySelected) {
      lockedSiteCode.value = '';
      lockedSiteName.value = '';
    }
  }

  void _syncSelectedPurchaseItems() {
    selectedPurchaseItems.clear();
    int srNo = 1;
    for (var item in authIndentItems) {
      for (var indent in item.items) {
        if (indent.isSelected) {
          final key = '${item.indentNo}_${indent.indentSrNo}';
          _ensureControllers(key, indent);
          selectedPurchaseItems.add({
            'SrNo': srNo++,
            'ICode': indent.iCode,
            'iName': indent.iName,
            'Unit': 'Nos',
            'Qty':
                double.tryParse(qtyControllers[key]?.text ?? '') ??
                indent.authoriseQty,
            'Price':
                double.tryParse(priceControllers[key]?.text ?? '') ??
                indent.rate,
            'IndentNo': item.indentNo,
            'IndentSrNo': indent.indentSrNo,
            'ReqDate':
                dateControllers[key]?.text ??
                convertyyyyMMddToddMMyyyy(indent.reqDate),
            'GDCode': selectedGodownCode[key] ?? indent.gCode,
            'GDName': selectedGodownName[key] ?? indent.gdName,
            'IndentRemark': remarkControllers[key]?.text ?? indent.indentRemark,
            'SiteCode': indent.siteCode,
            'SiteName': indent.siteName,
            'IGSTPerc': 0.0,
            'CGSTPerc': 0.0,
            'SGSTPerc': 0.0,
            'HSNNo': '',
            'Dis_P':
                double.tryParse(discountPercControllers[key]?.text ?? '0') ??
                0.0,
            'Dis_A':
                double.tryParse(discountAmountControllers[key]?.text ?? '0') ??
                0.0,
          });
        }
      }
    }
    selectedPurchaseItems.refresh();

    if (lockedSiteCode.value.isNotEmpty) {
      selectedSiteCode.value = lockedSiteCode.value;
      selectedSiteName.value = lockedSiteName.value;
    }
  }

  void _ensureControllers(String key, IndentDm indent) {
    if (!qtyControllers.containsKey(key)) {
      qtyControllers[key] = TextEditingController(
        text: indent.authoriseQty.toStringAsFixed(2),
      );
    }
    if (!priceControllers.containsKey(key)) {
      priceControllers[key] = TextEditingController(
        text: indent.rate.toStringAsFixed(2),
      );
    }

    if (!discountPercControllers.containsKey(key)) {
      discountPercControllers[key] = TextEditingController(text: '0.00');
    }
    if (!discountAmountControllers.containsKey(key)) {
      discountAmountControllers[key] = TextEditingController(text: '0.00');
    }
    if (!dateControllers.containsKey(key)) {
      dateControllers[key] = TextEditingController(
        text: convertyyyyMMddToddMMyyyy(indent.reqDate),
      );
    }
    if (!selectedGodownCode.containsKey(key)) {
      selectedGodownCode[key] = indent.gCode;
      selectedGodownName[key] = indent.gdName;
    }
    if (!remarkControllers.containsKey(key)) {
      remarkControllers[key] = TextEditingController(text: indent.indentRemark);
    }
  }

  void removeSelectedItem(int index) {
    final item = selectedPurchaseItems[index];
    for (var authItem in authIndentItems) {
      for (var indent in authItem.items) {
        if (authItem.indentNo == item['IndentNo'] &&
            indent.indentSrNo == item['IndentSrNo']) {
          indent.isSelected = false;
        }
      }
    }
    authIndentItems.refresh();
    selectedPurchaseItems.removeAt(index);
    for (int i = 0; i < selectedPurchaseItems.length; i++) {
      selectedPurchaseItems[i]['SrNo'] = i + 1;
    }
    selectedPurchaseItems.refresh();
    _updateLockIfNoSelection();
    _updateSelectionMode();
  }

  Future<void> getAuthIndentItems() async {
    isLoading.value = true;
    try {
      final fetched = await PurchaseOrderRepo.getAuthIndentItems();
      authIndentItems.assignAll(fetched);

      expandedItemIndices.clear();
      for (int i = 0; i < fetched.length; i++) {
        expandedItemIndices.add(i);
      }

      for (var item in fetched) {
        for (var indent in item.items) {
          final key = '${item.indentNo}_${indent.indentSrNo}';
          if (!qtyControllers.containsKey(key)) {
            qtyControllers[key] = TextEditingController(
              text: indent.authoriseQty.toStringAsFixed(2),
            );
          }
          if (!priceControllers.containsKey(key)) {
            priceControllers[key] = TextEditingController(
              text: indent.rate.toStringAsFixed(2),
            );
          }
          if (!dateControllers.containsKey(key)) {
            dateControllers[key] = TextEditingController(
              text: convertyyyyMMddToddMMyyyy(indent.reqDate),
            );
          }
          if (!selectedGodownCode.containsKey(key)) {
            selectedGodownCode[key] = indent.gCode;
            selectedGodownName[key] = indent.gdName;
          }
          if (!remarkControllers.containsKey(key)) {
            remarkControllers[key] = TextEditingController(
              text: indent.indentRemark,
            );
          }
        }
      }

      await getGodowns();
      _reapplySelectionsFromItems();
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _reapplySelectionsFromItems() {
    for (var selectedItem in selectedPurchaseItems) {
      for (var item in authIndentItems) {
        for (var indent in item.items) {
          if (item.indentNo == selectedItem['IndentNo'] &&
              indent.indentSrNo == selectedItem['IndentSrNo']) {
            indent.isSelected = true;
            final key = '${item.indentNo}_${indent.indentSrNo}';
            qtyControllers[key]?.text = selectedItem['Qty'].toStringAsFixed(2);
            priceControllers[key]?.text = (selectedItem['Price'] ?? 0.0)
                .toStringAsFixed(2);
            if (selectedItem.containsKey('ReqDate')) {
              dateControllers[key]?.text = selectedItem['ReqDate'];
            }
            if (selectedItem.containsKey('GDCode')) {
              selectedGodownCode[key] = selectedItem['GDCode'] ?? '';
              final obj = godowns.firstWhereOrNull(
                (gd) => gd.gdCode == selectedItem['GDCode'],
              );
              selectedGodownName[key] =
                  obj?.gdName ?? selectedItem['GDName'] ?? '';
            }
            if (selectedItem.containsKey('IndentRemark')) {
              remarkControllers[key]?.text = selectedItem['IndentRemark'] ?? '';
            }
            if (lockedSiteCode.value.isEmpty) {
              lockedSiteCode.value = indent.siteCode;
              lockedSiteName.value = indent.siteName;
            }
          }
        }
      }
    }
    authIndentItems.refresh();
    _updateSelectionMode();
  }

  void toggleItemExpansion(int index) {
    if (expandedItemIndices.contains(index)) {
      expandedItemIndices.remove(index);
    } else {
      expandedItemIndices.add(index);
    }
  }

  void updateSelectedItemQty(int index, double qty) {
    if (index >= 0 && index < selectedPurchaseItems.length) {
      selectedPurchaseItems[index]['Qty'] = qty;
      selectedPurchaseItems.refresh();
    }
  }

  void updateSelectedItemPrice(int index, double price) {
    if (index >= 0 && index < selectedPurchaseItems.length) {
      selectedPurchaseItems[index]['Price'] = price;
      selectedPurchaseItems.refresh();
    }
  }

  void onDiscountPercChanged(String key, String value) {
    final perc = double.tryParse(value) ?? 0.0;
    final item = selectedPurchaseItems.firstWhereOrNull(
      (i) => '${i['IndentNo']}_${i['IndentSrNo']}' == key,
    );
    final qty = double.tryParse(qtyControllers[key]?.text ?? '0') ?? 0.0;
    final price = double.tryParse(priceControllers[key]?.text ?? '0') ?? 0.0;
    final amount = qty * price;
    final discAmt = (amount * perc) / 100;
    discountAmountControllers[key]?.text = discAmt.toStringAsFixed(2);

    if (item != null) {
      item['Dis_P'] = perc;
      item['Dis_A'] = discAmt;
      selectedPurchaseItems.refresh();
    }
  }

  void onDiscountAmountChanged(String key, String value) {
    final discAmt = double.tryParse(value) ?? 0.0;
    final qty = double.tryParse(qtyControllers[key]?.text ?? '0') ?? 0.0;
    final price = double.tryParse(priceControllers[key]?.text ?? '0') ?? 0.0;
    final amount = qty * price;
    final perc = amount > 0 ? (discAmt / amount) * 100 : 0.0;
    discountPercControllers[key]?.text = perc.toStringAsFixed(2);

    final item = selectedPurchaseItems.firstWhereOrNull(
      (i) => '${i['IndentNo']}_${i['IndentSrNo']}' == key,
    );
    if (item != null) {
      item['Dis_P'] = perc;
      item['Dis_A'] = discAmt;
      selectedPurchaseItems.refresh();
    }
  }

  final PurchaseOrderListController purchaseOrderListController =
      Get.find<PurchaseOrderListController>();

  Future<void> savePurchaseOrder() async {
    isLoading.value = true;
    try {
      if (selectedPurchaseItems.isEmpty) {
        showErrorSnackbar('Error', 'Please add at least one item');
        return;
      }

      final itemsToSave = selectedPurchaseItems.map((item) {
        final key = '${item['IndentNo']}_${item['IndentSrNo']}';
        return {
          ...item,
          'Qty':
              double.tryParse(qtyControllers[key]?.text ?? '') ?? item['Qty'],
          'Price':
              double.tryParse(priceControllers[key]?.text ?? '') ??
              item['Price'],
          'ReqDate': dateControllers[key]?.text ?? item['ReqDate'],
          'GDCode': selectedGodownCode[key] ?? item['GDCode'] ?? '',
          'IndentRemark':
              remarkControllers[key]?.text ?? item['IndentRemark'] ?? '',
        };
      }).toList();

      final termsForApi = getTermsForAPI();

      final response = await PurchaseOrderRepo.savePurchaseOrder(
        invNo: isEditMode.value ? currentInvNo.value : '',
        date: _convertToApiDateFormat(dateController.text),
        pCode: selectedPartyCode.value,
        remarks: remarksController.text.trim(),
        siteCode: selectedSiteCode.value,
        tCode: selectedTaxTypeCode.value,
        gdCode: selectedGodownCode.values.firstOrNull ?? '',
        amount: netTotalToSend.value.toStringAsFixed(2),
        valueOfGoods: valueOfGoodsToSend.value.toStringAsFixed(2),
        termCodes: selectedTermCodes.toList(),
        termsData: termsForApi,
        itemData: itemsToSave,
        ledgerData: _getLedgerForAPI(),
        newFiles: attachmentFiles.toList(),
        existingAttachments: existingAttachmentUrls.toList(),
      );

      if (response != null && response.containsKey('message')) {
        final message = response['message'] as String;
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

  String _convertToApiDateFormat(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.length < 3) return dateStr;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  void clearAll() {
    currentInvNo.value = '';
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    remarksController.clear();
    for (final c in discountPercControllers.values) c.dispose();
    for (final c in discountAmountControllers.values) c.dispose();
    discountPercControllers.clear();
    discountAmountControllers.clear();
    selectedSiteName.value = '';
    selectedSiteCode.value = '';
    selectedPartyName.value = '';
    selectedPartyCode.value = '';
    selectedTaxTypeName.value = '';
    selectedTaxTypeCode.value = '';
    isIGSTApplicable.value = false;
    isCGSTApplicable.value = false;
    isSGSTApplicable.value = false;
    lockedSiteCode.value = '';
    lockedSiteName.value = '';

    attachmentFiles.clear();
    existingAttachmentUrls.clear();
    authIndentItems.clear();
    selectedPurchaseItems.clear();
    termsList.clear();
    selectedTermCodes.clear();

    for (final c in editableTermDescriptions.values) c.dispose();
    editableTermDescriptions.clear();

    for (final c in manualTermControllers) c.dispose();
    manualTermControllers.clear();

    for (final c in remarkControllers.values) c.dispose();
    for (final c in qtyControllers.values) c.dispose();
    for (final c in priceControllers.values) c.dispose();
    for (final c in dateControllers.values) c.dispose();
    for (final c in customiseVoucherAmountControllers.values) c.dispose();
    for (final c in customiseVoucherPercentageControllers.values) c.dispose();

    remarkControllers.clear();
    qtyControllers.clear();
    priceControllers.clear();
    dateControllers.clear();
    customiseVoucherAmountControllers.clear();
    customiseVoucherPercentageControllers.clear();

    selectedGodownName.clear();
    selectedGodownCode.clear();
    godowns.clear();
    godownNames.clear();
    ledgerDataToSend.clear();
    customiseVoucher.clear();

    grossTotal.value = 0.0;
    totalIgst.value = 0.0;
    totalCgst.value = 0.0;
    totalSgst.value = 0.0;
    netTotalToSend.value = 0.0;

    currentStep.value = 0;
    isEditMode.value = false;
    isSelectionMode.value = false;
    expandedItemIndices.clear();
  }

  @override
  void onClose() {
    dateController.dispose();
    remarksController.dispose();
    for (final c in remarkControllers.values) c.dispose();
    for (final c in qtyControllers.values) c.dispose();
    for (final c in priceControllers.values) c.dispose();
    for (final c in dateControllers.values) c.dispose();
    for (final c in customiseVoucherAmountControllers.values) c.dispose();
    for (final c in customiseVoucherPercentageControllers.values) c.dispose();
    for (final c in editableTermDescriptions.values) c.dispose();
    for (final c in manualTermControllers) c.dispose();
    for (final c in discountPercControllers.values) c.dispose();
    for (final c in discountAmountControllers.values) c.dispose();
    super.onClose();
  }
}
