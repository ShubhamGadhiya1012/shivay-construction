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
            borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            width: tablet ? 380 : double.infinity,
            constraints: BoxConstraints(
              maxWidth: tablet ? 380 : MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(tablet ? 14 : 12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Export Report',
                          style: TextStyle(
                            fontSize: tablet ? 16.5 : 15.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.grey[500],
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: Colors.grey.shade200),

                // List options
                _buildFormatButton(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'PDF',
                  subtitle: 'Print-ready file',
                  color: const Color(0xFFE53935),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _generatePdfReport();
                  },
                ),
                Divider(
                  height: 1,
                  color: Colors.grey.shade100,
                  indent: 16,
                  endIndent: 16,
                ),
                _buildFormatButton(
                  icon: Icons.grid_on_rounded,
                  label: 'Excel',
                  subtitle: 'Editable sheet',
                  color: const Color(0xFF2E7D32),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _generateExcelReport();
                  },
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        hoverColor: color.withOpacity(0.05),
        splashColor: color.withOpacity(0.10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.25), width: 1),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
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
