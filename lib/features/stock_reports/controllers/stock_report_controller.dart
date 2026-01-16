import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/item_master/models/item_master_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_list_repo.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/features/stock_reports/models/stock_report_dm.dart';
import 'package:shivay_construction/features/stock_reports/repos/stock_report_repo.dart';
import 'package:shivay_construction/features/stock_reports/widgets/stock_report_pdf_screen.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class StockReportController extends GetxController {
  var isLoading = false.obs;
  var isReportScreen = false.obs;
  final reportFormKey = GlobalKey<FormState>();

  var fromDateController = TextEditingController();
  var toDateController = TextEditingController();
  var siteNameController = TextEditingController();

  // Godown related
  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;
  var selectedGodownName = ''.obs;
  var selectedGodownCode = ''.obs;
  var selectedSiteCode = ''.obs;

  // Site related
  var sites = <SiteMasterDm>[].obs;

  // Items related
  var items = <ItemMasterDm>[].obs;
  var filteredItems = <ItemMasterDm>[].obs;
  var selectedItems = <String>[].obs;
  var selectedItemNames = <String>[].obs;
  var searchItemController = TextEditingController();

  // Report data
  var stockReports = <StockReportDm>[].obs;
  var grandTotal = Rxn<StockReportDm>();
  var openingStock = Rxn<StockReportDm>();
  var closingStock = Rxn<StockReportDm>();

  // Report configuration
  String reportName = '';
  String reportTitle = '';
  String rType = '';
  String method = '';

  void setReportConfig({
    required String name,
    required String title,
    required String type,
    required String mtd,
  }) {
    reportName = name;
    reportTitle = title;
    rType = type;
    method = mtd;
  }

  @override
  void onInit() async {
    super.onInit();
    final now = DateTime.now();
    final currentYear = now.month >= 4 ? now.year : now.year - 1;
    final financialYearStart = DateTime(currentYear, 4, 1);
    final formatter = DateFormat('dd-MM-yyyy');
    fromDateController.text = formatter.format(financialYearStart);
    toDateController.text = formatter.format(now);

    await getSites();
    await getGodowns();
    await getItems();
  }

  Future<void> getSites() async {
    isLoading.value = true;
    try {
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
    selectedGodownName.value = godownName ?? '';
    var selectedGodownObj = godowns.firstWhereOrNull(
      (gd) => gd.gdName == godownName,
    );
    selectedGodownCode.value = selectedGodownObj?.gdCode ?? '';
    selectedSiteCode.value = selectedGodownObj?.siteCode ?? '';

    if (selectedGodownObj?.siteCode.isNotEmpty ?? false) {
      final site = sites.firstWhereOrNull(
        (s) => s.siteCode == selectedGodownObj!.siteCode,
      );
      siteNameController.text = site?.siteName ?? '';
    } else {
      siteNameController.clear();
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

  void selectAllItems() {
    selectedItems.assignAll(items.map((item) => item.iCode));
    selectedItemNames.assignAll(items.map((item) => item.iName));
  }

  void togglePage() {
    isReportScreen.value = !isReportScreen.value;
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

      final response = await StockReportRepo.getStockReport(
        fromDate: fromDate,
        toDate: toDate,
        rType: rType,
        method: method,
        siteCode: selectedSiteCode.value,
        gdCode: selectedGodownCode.value,
        iCode: selectedItems.join(','),
      );

      if (response.isEmpty) {
        showErrorSnackbar(
          'No Data',
          'No records found for the selected filters.',
        );
        return;
      }

      _processReportData(response);
      togglePage();
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

  void _processReportData(List<StockReportDm> response) {
    stockReports.clear();
    grandTotal.value = null;
    openingStock.value = null;
    closingStock.value = null;

    if (reportName == 'LEDGER') {
      // Stock Ledger processing
      if (response.isNotEmpty) {
        openingStock.value = response.first;
        closingStock.value = response.last;

        if (response.length > 2) {
          stockReports.assignAll(response.sublist(1, response.length - 1));
        }
      }
    } else {
      // Other reports processing
      final lastItem = response.lastOrNull;
      if (lastItem?.isGrandTotal == true) {
        grandTotal.value = lastItem;
        stockReports.assignAll(response.sublist(0, response.length - 1));
      } else {
        stockReports.assignAll(response);
      }
    }
  }

  Future<void> downloadPdf() async {
    try {
      isLoading.value = true;
      await StockReportPdfScreen.generateStockReportPdf(
        reportData: stockReports,
        reportTitle: reportTitle,
        reportName: reportName,
        fromDate: fromDateController.text,
        toDate: toDateController.text,
        grandTotal: grandTotal.value,
        openingStock: openingStock.value,
        closingStock: closingStock.value,
      );
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate PDF: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void clearAll() {
    final now = DateTime.now();
    final currentYear = now.month >= 4 ? now.year : now.year - 1;
    final financialYearStart = DateTime(currentYear, 4, 1);
    final formatter = DateFormat('dd-MM-yyyy');
    fromDateController.text = formatter.format(financialYearStart);
    toDateController.text = formatter.format(now);

    selectedGodownName.value = '';
    selectedGodownCode.value = '';
    selectedSiteCode.value = '';
    siteNameController.clear();
    selectedItems.clear();
    selectedItemNames.clear();
    stockReports.clear();
    grandTotal.value = null;
    openingStock.value = null;
    closingStock.value = null;
    isReportScreen.value = false;
  }
}
