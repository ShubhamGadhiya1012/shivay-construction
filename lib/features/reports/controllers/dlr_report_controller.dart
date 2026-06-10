import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shivay_construction/features/reports/models/dlr_report_dm.dart';
import 'package:shivay_construction/features/reports/repos/dlr_report_repo.dart';
import 'package:shivay_construction/features/reports/widgets/dlr_report_excel_file.dart';
import 'package:shivay_construction/features/reports/widgets/dlr_report_pdf_screen.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_list_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class DlrReportController extends GetxController {
  var isLoading = false.obs;
  final reportFormKey = GlobalKey<FormState>();

  var fromDateController = TextEditingController();
  var toDateController = TextEditingController();

  var sites = <SiteMasterDm>[].obs;
  var siteNames = <String>[].obs;
  var selectedSiteName = ''.obs;
  var selectedSiteCode = ''.obs;

  // RType dropdown
  final List<String> rTypeOptions = ['Site Wise', 'Summary'];
  var selectedRType = 'Site Wise'.obs;

  var dlrReportList = <DlrReportDm>[].obs;

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

  void onSiteSelected(String? siteName) {
    selectedSiteName.value = siteName ?? '';
    var selectedSiteObj = sites.firstWhereOrNull(
      (site) => site.siteName == siteName,
    );
    selectedSiteCode.value = selectedSiteObj?.siteCode ?? '';
  }

  void onRTypeSelected(String? value) {
    selectedRType.value = value ?? 'Site Wise';
  }

  Future<void> generateReport(BuildContext context) async {
    final fromDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateFormat('dd-MM-yyyy').parse(fromDateController.text));

    final toDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateFormat('dd-MM-yyyy').parse(toDateController.text));

    // Always pass SiteWise to API
    final apiRType = 'SiteWise';

    try {
      isLoading.value = true;
      final response = await DlrReportRepo.getDlrReport(
        fromDate: fromDate,
        toDate: toDate,
        siteCode: selectedSiteCode.value,
        rType: apiRType,
      );

      if (response.isEmpty) {
        showErrorSnackbar(
          'No Data',
          'No records found for the selected filters.',
        );
        return;
      }

      dlrReportList.assignAll(response);

      // Show dialog to choose between PDF and Excel
      _showReportFormatDialog(context);
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

  void _showReportFormatDialog(BuildContext context) {
    final bool tablet = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tablet ? 20 : 16),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: tablet ? 450 : double.infinity,
            constraints: BoxConstraints(
              maxWidth: tablet ? 450 : MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(tablet ? 20 : 16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: tablet
                      ? const EdgeInsets.symmetric(horizontal: 24, vertical: 20)
                      : const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(tablet ? 20 : 16),
                      topRight: Radius.circular(tablet ? 20 : 16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(tablet ? 12 : 10),
                        ),
                        child: Icon(
                          Icons.description_rounded,
                          color: Colors.blue,
                          size: tablet ? 26 : 22,
                        ),
                      ),
                      SizedBox(width: tablet ? 12 : 10),
                      Expanded(
                        child: Text(
                          'Select Report Format',
                          style: TextStyle(
                            fontSize: tablet ? 22 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Padding(
                  padding: tablet
                      ? const EdgeInsets.all(24)
                      : const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose the format in which you want to generate the report:',
                        style: TextStyle(
                          fontSize: tablet ? 16 : 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: tablet ? 24 : 20),
                      Row(
                        children: [
                          // PDF Button
                          Expanded(
                            child: _buildFormatButton(
                              context: context,
                              icon: Icons.picture_as_pdf_rounded,
                              label: 'PDF',
                              color: Colors.red,
                              tablet: tablet,
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                _generatePdfReport();
                              },
                            ),
                          ),
                          SizedBox(width: tablet ? 16 : 12),
                          // Excel Button
                          Expanded(
                            child: _buildFormatButton(
                              context: context,
                              icon: Icons.table_chart_rounded,
                              label: 'Excel',
                              color: Colors.green,
                              tablet: tablet,
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                _generateExcelReport();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormatButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool tablet,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: tablet ? 24 : 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 12 : 10),
        ),
        padding: EdgeInsets.symmetric(vertical: tablet ? 16 : 14),
      ),
    );
  }

  Future<void> _generatePdfReport() async {
    try {
      isLoading.value = true;
      if (selectedRType.value == 'Summary') {
        await DlrReportPdfScreen.generateSummaryPdf(
          reportData: dlrReportList,
          fromDate: fromDateController.text,
          toDate: toDateController.text,
        );
      } else {
        await DlrReportPdfScreen.generateSiteWisePdf(
          reportData: dlrReportList,
          fromDate: fromDateController.text,
          toDate: toDateController.text,
        );
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate PDF: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _generateExcelReport() async {
    try {
      isLoading.value = true;
      if (selectedRType.value == 'Summary') {
        await DlrReportExcelFile.generateSummaryReport(
          reportList: dlrReportList,
          fromDate: fromDateController.text,
          toDate: toDateController.text,
        );
      } else {
        await DlrReportExcelFile.generateSiteWiseReport(
          reportList: dlrReportList,
          fromDate: fromDateController.text,
          toDate: toDateController.text,
        );
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Excel: $e');
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

    selectedSiteName.value = '';
    selectedSiteCode.value = '';
    selectedRType.value = 'Site Wise';
    dlrReportList.clear();
  }
}
