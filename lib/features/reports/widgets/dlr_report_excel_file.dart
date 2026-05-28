import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shivay_construction/features/reports/models/dlr_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:universal_html/html.dart' as html;

class DlrReportExcelFile {
  // ─────────────────────────────────────────────────────────────────────────
  // SITE WISE EXCEL
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> generateSiteWiseReport({
    required List<DlrReportDm> reportList,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final excel = Excel.createExcel();
      // Remove default sheet
      final defaultSheet = excel.getDefaultSheet();

      // Group by site
      final Map<String, List<DlrReportDm>> groupedBySite = {};
      for (var item in reportList) {
        groupedBySite.putIfAbsent(item.siteCode, () => []).add(item);
      }

      bool firstSheet = true;
      groupedBySite.forEach((siteCode, siteItems) {
        final siteName = siteItems.first.siteName;
        final companyName = siteItems.first.coName;
        final sheetName = siteName.length > 31
            ? siteName.substring(0, 31)
            : siteName;

        Sheet sheet = excel[sheetName];

        if (firstSheet && defaultSheet != null && defaultSheet != sheetName) {
          excel.delete(defaultSheet);
          firstSheet = false;
        } else {
          firstSheet = false;
        }

        _writeSiteWiseSheet(
          sheet: sheet,
          siteItems: siteItems,
          companyName: companyName,
          siteName: siteName,
          fromDate: fromDate,
          toDate: toDate,
        );
      });

      final bytes = excel.encode()!;
      await _saveAndOpenExcel(bytes, 'DLR_SiteWise_Report');

      if (!AppScreenUtils.isWeb) {
        showSuccessSnackbar('Success', 'Excel report generated successfully');
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Excel file: $e');
    }
  }

  static void _writeSiteWiseSheet({
    required Sheet sheet,
    required List<DlrReportDm> siteItems,
    required String companyName,
    required String siteName,
    required String fromDate,
    required String toDate,
  }) {
    int rowIndex = 0;
    final reportDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // ── Styles ──────────────────────────────────────────────────────────────
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 18,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final subtitleStyle = CellStyle(
      bold: true,
      fontSize: 13,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final dateRightStyle = CellStyle(
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Right,
    );

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
    );

    final activityHeaderStyle = CellStyle(
      bold: true,
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#B4C6E7'),
    );

    final dataStyle = CellStyle(
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    final dataCenterStyle = CellStyle(
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final subTotalStyle = CellStyle(
      bold: true,
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#E2EFDA'),
    );

    final grandTotalStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
    );

    const int totalCols = 6;

    // ── Row 0: Company Name ─────────────────────────────────────────────────
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(
        columnIndex: totalCols - 1,
        rowIndex: rowIndex,
      ),
    );
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    cell.value = TextCellValue(companyName.toUpperCase());
    cell.cellStyle = titleStyle;
    rowIndex++;

    // ── Row 1: Site Name ────────────────────────────────────────────────────
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(
        columnIndex: totalCols - 1,
        rowIndex: rowIndex,
      ),
    );
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    cell.value = TextCellValue(siteName.toUpperCase());
    cell.cellStyle = subtitleStyle;
    rowIndex++;

    // ── Row 2: DLR date right-aligned ───────────────────────────────────────
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(
        columnIndex: totalCols - 2,
        rowIndex: rowIndex,
      ),
    );
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('');

    cell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: totalCols - 1,
        rowIndex: rowIndex,
      ),
    );
    cell.value = TextCellValue('DLR_$reportDate');
    cell.cellStyle = dateRightStyle;
    rowIndex++;

    rowIndex++; // blank row

    // ── Column Headers ───────────────────────────────────────────────────────
    final headers = [
      'Sr. No',
      'Name of Agency',
      'Skill',
      'Unskilled',
      'Work Description',
      'Remark',
    ];
    for (int i = 0; i < headers.length; i++) {
      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }
    rowIndex++;

    // ── Group by Activity ────────────────────────────────────────────────────
    final Map<String, List<DlrReportDm>> groupedByActivity = {};
    for (var item in siteItems) {
      groupedByActivity.putIfAbsent(item.activity, () => []).add(item);
    }

    double grandSkill = 0, grandUnSkill = 0, grandTotal = 0;

    groupedByActivity.forEach((activity, items) {
      double actSkill = 0, actUnSkill = 0, actTotal = 0;

      // Activity header row
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(
          columnIndex: totalCols - 1,
          rowIndex: rowIndex,
        ),
      );
      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      );
      cell.value = TextCellValue(activity);
      cell.cellStyle = activityHeaderStyle;
      rowIndex++;

      for (var entry in items) {
        // Sr. No
        cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        );
        cell.value = IntCellValue(entry.srNo);
        cell.cellStyle = dataCenterStyle;
        // Agency
        cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
        );
        cell.value = TextCellValue(entry.agencyName);
        cell.cellStyle = dataStyle;
        // Skill
        cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
        );
        cell.value = DoubleCellValue(entry.skill);
        cell.cellStyle = dataCenterStyle;
        // Unskilled
        cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
        );
        cell.value = DoubleCellValue(entry.unSkill);
        cell.cellStyle = dataCenterStyle;
        // Description
        cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
        );
        cell.value = TextCellValue(
          entry.description.isNotEmpty ? entry.description : '-',
        );
        cell.cellStyle = dataStyle;
        // Remark
        cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
        );
        cell.value = TextCellValue(
          entry.remark.isNotEmpty ? entry.remark : '-',
        );
        cell.cellStyle = dataStyle;

        actSkill += entry.skill;
        actUnSkill += entry.unSkill;
        actTotal += entry.total;
        rowIndex++;
      }

      // Sub Total
      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
      );
      cell.value = TextCellValue('Sub Total');
      cell.cellStyle = subTotalStyle;

      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
      );
      cell.value = DoubleCellValue(actSkill);
      cell.cellStyle = subTotalStyle;

      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
      );
      cell.value = DoubleCellValue(actUnSkill);
      cell.cellStyle = subTotalStyle;

      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
      );
      cell.value = DoubleCellValue(actTotal);
      cell.cellStyle = subTotalStyle;

      grandSkill += actSkill;
      grandUnSkill += actUnSkill;
      grandTotal += actTotal;
      rowIndex++;
    });

    // ── Grand Total ───────────────────────────────────────────────────────────
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('Grand Total');
    cell.cellStyle = grandTotalStyle;

    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
    );
    cell.value = DoubleCellValue(grandSkill);
    cell.cellStyle = grandTotalStyle;

    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
    );
    cell.value = DoubleCellValue(grandUnSkill);
    cell.cellStyle = grandTotalStyle;

    // Col 4 middle (description col) - just show grandTotal
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
    );
    cell.value = DoubleCellValue(grandTotal);
    cell.cellStyle = grandTotalStyle;

    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('');
    cell.cellStyle = grandTotalStyle;

    // ── Column widths ─────────────────────────────────────────────────────────
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 22);
    sheet.setColumnWidth(2, 10);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 38);
    sheet.setColumnWidth(5, 18);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUMMARY EXCEL
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> generateSummaryReport({
    required List<DlrReportDm> reportList,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final excel = Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet();

      // Group by Company
      final Map<String, List<DlrReportDm>> groupedByCompany = {};
      for (var item in reportList) {
        final key = '${item.coCode}_${item.coName}';
        groupedByCompany.putIfAbsent(key, () => []).add(item);
      }

      bool firstSheet = true;
      groupedByCompany.forEach((companyKey, companyItems) {
        final companyName = companyItems.first.coName;
        final sheetName = companyName.length > 31
            ? companyName.substring(0, 31)
            : companyName;

        Sheet sheet = excel[sheetName];
        if (firstSheet && defaultSheet != null && defaultSheet != sheetName) {
          excel.delete(defaultSheet);
          firstSheet = false;
        } else {
          firstSheet = false;
        }

        _writeSummarySheet(
          sheet: sheet,
          companyItems: companyItems,
          companyName: companyName,
          fromDate: fromDate,
          toDate: toDate,
        );
      });

      final bytes = excel.encode()!;
      await _saveAndOpenExcel(bytes, 'DLR_Summary_Report');

      if (!AppScreenUtils.isWeb) {
        showSuccessSnackbar('Success', 'Excel report generated successfully');
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Excel file: $e');
    }
  }

  static void _writeSummarySheet({
    required Sheet sheet,
    required List<DlrReportDm> companyItems,
    required String companyName,
    required String fromDate,
    required String toDate,
  }) {
    int rowIndex = 0;
    final reportDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Unique sites in order
    final List<String> siteNames = [];
    for (var item in companyItems) {
      if (!siteNames.contains(item.siteName)) {
        siteNames.add(item.siteName);
      }
    }

    // Total columns: Sr.No + Agency + WorkDesc + [sites] + Total
    final int totalCols = 3 + siteNames.length + 1;

    // ── Styles ──────────────────────────────────────────────────────────────
    final companyTitleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Left,
    );

    final subtitleStyle = CellStyle(
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Left,
    );

    final monthStyle = CellStyle(
      bold: true,
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Left,
    );

    final dayReportStyle = CellStyle(
      bold: true,
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
    );

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 9,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
      textWrapping: TextWrapping.WrapText,
    );

    final dataStyle = CellStyle(
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Left,
    );

    final dataCenterStyle = CellStyle(
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
    );

    final totalFooterStyle = CellStyle(
      bold: true,
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#B4C6E7'),
    );

    // ── Row 0: Company Name ──────────────────────────────────────────────────
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(
        columnIndex: totalCols - 1,
        rowIndex: rowIndex,
      ),
    );
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    cell.value = TextCellValue(companyName);
    cell.cellStyle = companyTitleStyle;
    rowIndex++;

    // ── Row 1: "Summary" ─────────────────────────────────────────────────────
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(
        columnIndex: totalCols - 1,
        rowIndex: rowIndex,
      ),
    );
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('Summary');
    cell.cellStyle = subtitleStyle;
    rowIndex++;

    // ── Row 2: Month ─────────────────────────────────────────────────────────
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(
        columnIndex: totalCols - 1,
        rowIndex: rowIndex,
      ),
    );
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    final monthStr = DateFormat(
      'MMMM-yyyy',
    ).format(DateFormat('dd-MM-yyyy').parse(toDate));
    cell.value = TextCellValue('Month : $monthStr');
    cell.cellStyle = monthStyle;
    rowIndex++;

    rowIndex++; // blank row

    // ── Row 4: "Day Report - date" header ────────────────────────────────────
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      CellIndex.indexByColumnRow(
        columnIndex: totalCols - 1,
        rowIndex: rowIndex,
      ),
    );
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('Day Report - $reportDate');
    cell.cellStyle = dayReportStyle;
    rowIndex++;

    // ── Column headers ───────────────────────────────────────────────────────
    // Sr. No
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('Sr.\nNo.');
    cell.cellStyle = headerStyle;
    // Agency
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('Name of Agency');
    cell.cellStyle = headerStyle;
    // Work Desc
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('Work Description');
    cell.cellStyle = headerStyle;
    // Sites
    for (int i = 0; i < siteNames.length; i++) {
      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3 + i, rowIndex: rowIndex),
      );
      cell.value = TextCellValue(siteNames[i]);
      cell.cellStyle = headerStyle;
    }
    // Total
    cell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 3 + siteNames.length,
        rowIndex: rowIndex,
      ),
    );
    cell.value = TextCellValue('Total\nPerson');
    cell.cellStyle = headerStyle;
    rowIndex++;

    // ── Build agency data grouped by Agency + Activity ─────────────────────
    final Map<String, Map<String, double>> agencyData = {};
    final Map<String, String> agencyActivityMap = {};
    final Map<String, String> agencyDescMap = {};

    for (var item in companyItems) {
      final key = '${item.agencyName}__${item.activity}';
      agencyActivityMap[key] = item.activity;
      // Store description (use first non-empty one found)
      if (!agencyDescMap.containsKey(key)) {
        agencyDescMap[key] = item.description.isNotEmpty
            ? item.description
            : '-';
      }
      agencyData.putIfAbsent(key, () => {});
      agencyData[key]![item.siteName] =
          (agencyData[key]![item.siteName] ?? 0) + item.total;
    }

    final Map<String, double> siteColumnTotals = {};
    for (var siteMap in agencyData.values) {
      siteMap.forEach((site, val) {
        siteColumnTotals[site] = (siteColumnTotals[site] ?? 0) + val;
      });
    }
    double grandTotal = siteColumnTotals.values.fold(0, (a, b) => a + b);

    int srNo = 1;
    agencyData.forEach((key, siteMap) {
      final parts = key.split('__');
      final agencyName = parts[0];
      final activity = agencyActivityMap[key] ?? '';
      double rowTotal = siteMap.values.fold(0, (a, b) => a + b);

      // Sr. No
      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      );
      cell.value = IntCellValue(srNo);
      cell.cellStyle = dataCenterStyle;
      // Agency
      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
      );
      cell.value = TextCellValue(agencyName);
      cell.cellStyle = dataStyle;
      // Work Desc
      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
      );
      cell.value = TextCellValue(activity.isNotEmpty ? activity : '-');
      cell.cellStyle = dataStyle;
      // Site columns
      for (int i = 0; i < siteNames.length; i++) {
        cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 3 + i, rowIndex: rowIndex),
        );
        final val = siteMap[siteNames[i]];
        cell.value = TextCellValue(
          val != null && val > 0 ? val.toStringAsFixed(0) : '-',
        );
        cell.cellStyle = dataCenterStyle;
      }
      // Total
      cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 3 + siteNames.length,
          rowIndex: rowIndex,
        ),
      );
      cell.value = TextCellValue(
        rowTotal > 0 ? rowTotal.toStringAsFixed(0) : '-',
      );
      cell.cellStyle = dataCenterStyle;

      srNo++;
      rowIndex++;
    });

    // 2 blank rows
    rowIndex += 2;

    // ── Total footer row ──────────────────────────────────────────────────────
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('');
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('');
    cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
    );
    cell.value = TextCellValue('');

    for (int i = 0; i < siteNames.length; i++) {
      cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3 + i, rowIndex: rowIndex),
      );
      final val = siteColumnTotals[siteNames[i]] ?? 0;
      cell.value = DoubleCellValue(val);
      cell.cellStyle = totalFooterStyle;
    }
    cell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 3 + siteNames.length,
        rowIndex: rowIndex,
      ),
    );
    cell.value = DoubleCellValue(grandTotal);
    cell.cellStyle = totalFooterStyle;

    // ── Column widths ─────────────────────────────────────────────────────────
    sheet.setColumnWidth(0, 7);
    sheet.setColumnWidth(1, 22);
    sheet.setColumnWidth(2, 22);
    for (int i = 0; i < siteNames.length; i++) {
      sheet.setColumnWidth(3 + i, 12);
    }
    sheet.setColumnWidth(3 + siteNames.length, 14);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SAVE & OPEN
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> _saveAndOpenExcel(
    List<int> excelBytes,
    String fileName,
  ) async {
    try {
      if (AppScreenUtils.isWeb) {
        final blob = html.Blob([
          excelBytes,
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute(
            'download',
            '$fileName${DateTime.now().millisecondsSinceEpoch}.xlsx',
          )
          ..click();

        Future.delayed(const Duration(seconds: 2), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/$fileName${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final File file = File(filePath)..writeAsBytesSync(excelBytes);
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      showErrorSnackbar(
        'Error',
        'Failed to save and open Excel: ${e.toString()}',
      );
    }
  }
}
