import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/category_master/models/category_master_dm.dart';
import 'package:shivay_construction/features/category_master/repos/category_master_repo.dart';
import 'package:shivay_construction/features/godown_master/models/godown_master_dm.dart';
import 'package:shivay_construction/features/godown_master/repos/godown_master_repo.dart';
import 'package:shivay_construction/features/item_group_master/models/item_group_master_dm.dart';
import 'package:shivay_construction/features/item_group_master/repos/item_group_master_repo.dart';
import 'package:shivay_construction/features/item_master/models/filtered_item_dm.dart';
import 'package:shivay_construction/features/item_master/repos/item_master_list_repo.dart';
import 'package:shivay_construction/features/item_sub_group_master/models/item_sub_group_master_dm.dart';
import 'package:shivay_construction/features/item_sub_group_master/repos/item_sub_group_master_repo.dart';
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

  var godowns = <GodownMasterDm>[].obs;
  var godownNames = <String>[].obs;
  var selectedGodownName = ''.obs;
  var selectedGodownCode = ''.obs;

  var sites = <SiteMasterDm>[].obs;
  var siteNames = <String>[].obs;
  var selectedSiteName = ''.obs;
  var selectedSiteCode = ''.obs;

  var filteredItemsList = <FilteredItemDm>[].obs;
  var selectedItems = <String>[].obs;
  var selectedItemNames = <String>[].obs;
  var searchItemController = TextEditingController();

  var categories = <CategoryMasterDm>[].obs;
  var categoryNames = <String>[].obs;
  var selectedCategoryName = ''.obs;
  var selectedCategoryCode = ''.obs;

  var itemGroups = <ItemGroupMasterDm>[].obs;
  var itemGroupNames = <String>[].obs;
  var selectedItemGroupName = ''.obs;
  var selectedItemGroupCode = ''.obs;

  var itemSubGroups = <ItemSubGroupMasterDm>[].obs;
  var itemSubGroupNames = <String>[].obs;
  var selectedItemSubGroupName = ''.obs;
  var selectedItemSubGroupCode = ''.obs;

  var stockReports = <StockReportDm>[].obs;
  var grandTotal = Rxn<StockReportDm>();
  var openingStock = Rxn<StockReportDm>();
  var closingStock = Rxn<StockReportDm>();

  String reportName = '';
  String reportTitle = '';
  String rType = '';
  String method = '';

  var currentItemIndex = 0.obs;
  var groupedReportsByItem = <String, List<StockReportDm>>{}.obs;
  var itemCodes = <String>[].obs;

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
    await getCategories();
    await getItemGroups();
    await getItemSubGroups();
    await getFilteredItems();
  }

  Future<void> getSites() async {
    isLoading.value = true;
    try {
      final fetchedSites = await SiteMasterListRepo.getSites();
      sites.assignAll(fetchedSites);
      siteNames.assignAll(fetchedSites.map((site) => site.siteName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSiteSelected(String? siteName) async {
    selectedSiteName.value = siteName ?? '';
    var selectedSiteObj = sites.firstWhereOrNull(
      (site) => site.siteName == siteName,
    );
    selectedSiteCode.value = selectedSiteObj?.siteCode ?? '';

    selectedGodownName.value = '';
    selectedGodownCode.value = '';

    if (selectedSiteCode.value.isNotEmpty) {
      await getGodowns(selectedSiteCode.value);
    } else {
      godowns.clear();
      godownNames.clear();
    }
  }

  Future<void> getGodowns([String siteCode = '']) async {
    try {
      isLoading.value = true;
      final fetchedGodowns = await GodownMasterRepo.getGodowns(
        siteCode: siteCode,
      );
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

    if (selectedGodownObj?.siteCode.isNotEmpty ?? false) {
      sites.firstWhereOrNull((s) => s.siteCode == selectedGodownObj!.siteCode);
    } else {}
  }

  Future<void> getCategories() async {
    try {
      isLoading.value = true;
      final fetchedCategories = await CategoryMasterRepo.getCategories();
      categories.assignAll(fetchedCategories);
      categoryNames.assignAll(fetchedCategories.map((c) => c.cName).toList());
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onCategorySelected(String? categoryName) async {
    selectedCategoryName.value = categoryName ?? '';
    var selectedCategoryObj = categories.firstWhereOrNull(
      (c) => c.cName == categoryName,
    );
    selectedCategoryCode.value = selectedCategoryObj?.cCode ?? '';

    await getFilteredItems();
  }

  Future<void> getItemGroups() async {
    try {
      isLoading.value = true;
      final fetchedItemGroups = await ItemGroupMasterRepo.getItemGroups();
      itemGroups.assignAll(fetchedItemGroups);
      itemGroupNames.assignAll(
        fetchedItemGroups.map((ig) => ig.igName).toList(),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onItemGroupSelected(String? itemGroupName) async {
    selectedItemGroupName.value = itemGroupName ?? '';
    var selectedItemGroupObj = itemGroups.firstWhereOrNull(
      (ig) => ig.igName == itemGroupName,
    );
    selectedItemGroupCode.value = selectedItemGroupObj?.igCode ?? '';

    await getFilteredItems();
  }

  Future<void> getItemSubGroups() async {
    try {
      isLoading.value = true;
      final fetchedItemSubGroups =
          await ItemSubGroupMasterRepo.getItemSubGroups();
      itemSubGroups.assignAll(fetchedItemSubGroups);
      itemSubGroupNames.assignAll(
        fetchedItemSubGroups.map((isg) => isg.icName).toList(),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onItemSubGroupSelected(String? itemSubGroupName) async {
    selectedItemSubGroupName.value = itemSubGroupName ?? '';
    var selectedItemSubGroupObj = itemSubGroups.firstWhereOrNull(
      (isg) => isg.icName == itemSubGroupName,
    );
    selectedItemSubGroupCode.value = selectedItemSubGroupObj?.icCode ?? '';

    await getFilteredItems();
  }

  Future<void> getFilteredItems() async {
    try {
      isLoading.value = true;
      final fetchedItems = await ItemMasterListRepo.getFilteredItems(
        cCode: selectedCategoryCode.value,
        igCode: selectedItemGroupCode.value,
        icCode: selectedItemSubGroupCode.value,
      );
      filteredItemsList.assignAll(fetchedItems);

      selectedItems.removeWhere(
        (code) => !filteredItemsList.any((item) => item.iCode == code),
      );
      selectedItemNames.removeWhere(
        (name) => !filteredItemsList.any((item) => item.iName == name),
      );
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void selectAllItems() {
    selectedItems.assignAll(filteredItemsList.map((item) => item.iCode));
    selectedItemNames.assignAll(filteredItemsList.map((item) => item.iName));
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
        cCode: selectedCategoryCode.value,
        igCode: selectedItemGroupCode.value,
        icCode: selectedItemSubGroupCode.value,
        iCode: selectedItems.join(','),
      );

      if (response.isEmpty) {
        showErrorSnackbar(
          'No Data',
          'No records found for the selected filters.',
        );
        isLoading.value = false;
        return;
      }

      await _processReportData(response);

      isLoading.value = false;
      togglePage();
    } catch (e) {
      isLoading.value = false;
      if (e is Map<String, dynamic>) {
        showErrorSnackbar('Error', e['message']);
      } else {
        showErrorSnackbar('Error', e.toString());
      }
    }
  }

  Future<void> _processReportData(List<StockReportDm> response) async {
    stockReports.clear();
    grandTotal.value = null;
    openingStock.value = null;
    closingStock.value = null;
    groupedReportsByItem.clear();
    itemCodes.clear();
    currentItemIndex.value = 0;

    if (reportName == 'LEDGER') {
      final Map<String, List<StockReportDm>> grouped = {};

      for (var item in response) {
        final iCode = item.iCode ?? '';
        if (iCode.isEmpty) continue;

        if (!grouped.containsKey(iCode)) {
          grouped[iCode] = [];
        }
        grouped[iCode]!.add(item);
      }

      groupedReportsByItem.assignAll(grouped);
      itemCodes.assignAll(grouped.keys.toList());

      if (itemCodes.isNotEmpty) {
        _loadItemData(0);
      }
    } else {
      final lastItem = response.lastOrNull;
      if (lastItem?.isGrandTotal == true) {
        grandTotal.value = lastItem;
        stockReports.assignAll(response.sublist(0, response.length - 1));
      } else {
        stockReports.assignAll(response);
      }
    }
  }

  void _loadItemData(int index) {
    if (index < 0 || index >= itemCodes.length) return;

    currentItemIndex.value = index;
    final iCode = itemCodes[index];
    final itemData = groupedReportsByItem[iCode] ?? [];

    stockReports.clear();
    openingStock.value = null;
    closingStock.value = null;

    if (itemData.isEmpty) return;

    StockReportDm? opening;
    StockReportDm? closing;
    List<StockReportDm> transactions = [];

    for (var item in itemData) {
      final desc = item.desc?.trim() ?? '';

      if (desc == 'Opening Stock') {
        opening = item;
      } else if (desc == 'Closing Stock') {
        closing = item;
      } else {
        transactions.add(item);
      }
    }

    openingStock.value = opening;
    closingStock.value = closing;
    stockReports.assignAll(transactions);
  }

  void goToPreviousItem() {
    if (currentItemIndex.value > 0) {
      _loadItemData(currentItemIndex.value - 1);
    }
  }

  void goToNextItem() {
    if (currentItemIndex.value < itemCodes.length - 1) {
      _loadItemData(currentItemIndex.value + 1);
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

  Future<void> clearAll() async {
    final now = DateTime.now();
    final currentYear = now.month >= 4 ? now.year : now.year - 1;
    final financialYearStart = DateTime(currentYear, 4, 1);
    final formatter = DateFormat('dd-MM-yyyy');
    fromDateController.text = formatter.format(financialYearStart);
    toDateController.text = formatter.format(now);

    selectedGodownName.value = '';
    selectedGodownCode.value = '';
    selectedSiteCode.value = '';
    selectedSiteName.value = '';

    selectedCategoryName.value = '';
    selectedCategoryCode.value = '';
    selectedItemGroupName.value = '';
    selectedItemGroupCode.value = '';
    selectedItemSubGroupName.value = '';
    selectedItemSubGroupCode.value = '';

    selectedItems.clear();
    selectedItemNames.clear();
    stockReports.clear();
    grandTotal.value = null;
    openingStock.value = null;
    closingStock.value = null;
    isReportScreen.value = false;
    groupedReportsByItem.clear();
    itemCodes.clear();
    currentItemIndex.value = 0;

    await getGodowns();
    await getFilteredItems();
  }
}
