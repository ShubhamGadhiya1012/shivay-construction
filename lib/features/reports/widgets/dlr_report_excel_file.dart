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
  static Future<void> generateDlrReport({
    required List<DlrReportDm> reportList,
    required String fromDate,
    required String toDate,
    String partyName = '',
    String siteName = '',
  }) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel[excel.getDefaultSheet()!];

      int rowIndex = 0;

      // Styles
      CellStyle titleStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      CellStyle headerStyle = CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#007BFF"),
      );

      CellStyle dataStyle = CellStyle(
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      CellStyle subTotalStyle = CellStyle(
        bold: true,
        fontSize: 10,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#E8F4F8"),
      );

      CellStyle grandTotalStyle = CellStyle(
        bold: true,
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString("#FFF3CD"),
      );

      List<String> headers = [
        'DATE',
        'SHIFT',
        'SKILLED PERSON',
        'RATE',
        'AMOUNT',
        'UNSKILLED PERSON',
        'RATE',
        'AMOUNT',
        'SUPERVISOR',
      ];

      // Column widths
      Map<int, double> columnWidths = {};
      for (int i = 0; i < headers.length; i++) {
        columnWidths[i] = headers[i].length.toDouble() + 3;
      }

      // Title
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(
          columnIndex: headers.length - 1,
          rowIndex: rowIndex,
        ),
      );
      var titleCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      );
      titleCell.value = TextCellValue('DLR Entry Report');
      titleCell.cellStyle = titleStyle;
      rowIndex++;

      // Date Range
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(
          columnIndex: headers.length - 1,
          rowIndex: rowIndex,
        ),
      );
      var dateCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      );
      dateCell.value = TextCellValue('From: $fromDate | To: $toDate');
      dateCell.cellStyle = dataStyle;
      rowIndex++;

      // Party and Site info if selected
      if (partyName.isNotEmpty || siteName.isNotEmpty) {
        sheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
          CellIndex.indexByColumnRow(
            columnIndex: headers.length - 1,
            rowIndex: rowIndex,
          ),
        );
        var infoCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        );
        String info = '';
        if (partyName.isNotEmpty) info += 'Party: $partyName';
        if (siteName.isNotEmpty) {
          if (info.isNotEmpty) info += ' | ';
          info += 'Site: $siteName';
        }
        infoCell.value = TextCellValue(info);
        infoCell.cellStyle = dataStyle;
        rowIndex++;
      }

      rowIndex++;

      // Headers
      for (int i = 0; i < headers.length; i++) {
        var headerCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex),
        );
        headerCell.value = TextCellValue(headers[i]);
        headerCell.cellStyle = headerStyle;
      }
      rowIndex++;

      // Group data by date
      Map<String, List<DlrReportDm>> groupedByDate = {};
      for (var entry in reportList) {
        String formattedDate = _formatDate(entry.dlrDate);
        if (!groupedByDate.containsKey(formattedDate)) {
          groupedByDate[formattedDate] = [];
        }
        groupedByDate[formattedDate]!.add(entry);
      }

      // Grand totals
      double grandTotalSkill = 0;
      double grandTotalSkillAmount = 0;
      double grandTotalUnSkill = 0;
      double grandTotalUnSkillAmount = 0;

      // Process each date group
      groupedByDate.forEach((date, entries) {
        double dayTotalSkill = 0;
        double dayTotalSkillAmount = 0;
        double dayTotalUnSkill = 0;
        double dayTotalUnSkillAmount = 0;

        // Process entries for this date
        for (int i = 0; i < entries.length; i++) {
          var entry = entries[i];

          List<dynamic> values = [
            i == 0 ? date : '', // Show date only on first row
            entry.shift,
            entry.skill,
            entry.skillRate,
            entry.skillAmount,
            entry.unSkill,
            entry.unSkillRate,
            entry.unSkillAmount,
            entry.supervisorName,
          ];

          for (int j = 0; j < values.length; j++) {
            var dataCell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
            );

            String cellText = values[j].toString();
            if (cellText.length > columnWidths[j]!) {
              columnWidths[j] = cellText.length.toDouble();
            }

            if (values[j] is num) {
              dataCell.value = DoubleCellValue(values[j].toDouble());
            } else {
              dataCell.value = TextCellValue(values[j].toString());
            }
            dataCell.cellStyle = dataStyle;
          }

          dayTotalSkill += entry.skill;
          dayTotalSkillAmount += entry.skillAmount;
          dayTotalUnSkill += entry.unSkill;
          dayTotalUnSkillAmount += entry.unSkillAmount;

          rowIndex++;
        }

        // Day-wise total row
        List<dynamic> dayTotalValues = [
          'DAY WISE TOTAL',
          '',
          dayTotalSkill,
          '',
          dayTotalSkillAmount,
          dayTotalUnSkill,
          '',
          dayTotalUnSkillAmount,
          '',
        ];

        for (int j = 0; j < dayTotalValues.length; j++) {
          var totalCell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
          );

          if (dayTotalValues[j] is num) {
            totalCell.value = DoubleCellValue(
              (dayTotalValues[j] as num).toDouble(),
            );
          } else {
            totalCell.value = TextCellValue(dayTotalValues[j].toString());
          }
          totalCell.cellStyle = subTotalStyle;
        }

        grandTotalSkill += dayTotalSkill;
        grandTotalSkillAmount += dayTotalSkillAmount;
        grandTotalUnSkill += dayTotalUnSkill;
        grandTotalUnSkillAmount += dayTotalUnSkillAmount;

        rowIndex++;
        rowIndex++; // Empty row between days
      });

      // Grand Total Row
      List<dynamic> grandTotalValues = [
        'GRAND TOTAL',
        '',
        grandTotalSkill,
        '',
        grandTotalSkillAmount,
        grandTotalUnSkill,
        '',
        grandTotalUnSkillAmount,
        '',
      ];

      for (int j = 0; j < grandTotalValues.length; j++) {
        var grandCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
        );

        if (grandTotalValues[j] is num) {
          grandCell.value = DoubleCellValue(
            (grandTotalValues[j] as num).toDouble(),
          );
        } else {
          grandCell.value = TextCellValue(grandTotalValues[j].toString());
        }
        grandCell.cellStyle = grandTotalStyle;
      }

      // Set column widths
      columnWidths.forEach((colIndex, width) {
        sheet.setColumnWidth(colIndex, width + 3);
      });

      // Save and open file
      final bytes = excel.encode()!;
      await _saveAndOpenExcel(bytes, 'DLR_Entry_Report');

      if (!AppScreenUtils.isWeb) {
        showSuccessSnackbar('Success', 'Excel report generated successfully');
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Excel file: $e');
    }
  }

  static String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

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
