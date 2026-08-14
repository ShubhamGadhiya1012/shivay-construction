import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shivay_construction/features/reports/models/dlr_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:universal_html/html.dart' as html;

import 'package:shivay_construction/constants/image_constants.dart';

class _ActivityTotals {
  double daySkill = 0;
  double dayUnSkill = 0;
  double nightSkill = 0;
  double nightUnSkill = 0;

  double get dayTotal => daySkill + dayUnSkill;
  double get nightTotal => nightSkill + nightUnSkill;
  double get grandTotal => dayTotal + nightTotal;
}

class _SiteWiseStyles {
  final Style title;
  final Style dlr;
  final Style labelBox;
  final Style brandLabel;
  final Style dayNightHeader;
  final Style dayNightValue;
  final Style header;
  final Style activityHeader;
  final Style data;
  final Style dataCenter;
  final Style subTotal;
  final Style grandTotal;
  final Style summaryHeader;
  final Style summaryDataLabel;
  final Style summaryFooter;

  _SiteWiseStyles._({
    required this.title,
    required this.dlr,
    required this.labelBox,
    required this.brandLabel,
    required this.dayNightHeader,
    required this.dayNightValue,
    required this.header,
    required this.activityHeader,
    required this.data,
    required this.dataCenter,
    required this.subTotal,
    required this.grandTotal,
    required this.summaryHeader,
    required this.summaryDataLabel,
    required this.summaryFooter,
  });

  factory _SiteWiseStyles(Workbook workbook) {
    final title = workbook.styles.add('dlrTitleStyle')
      ..bold = true
      ..fontSize = 22
      ..hAlign = HAlignType.left
      ..vAlign = VAlignType.center;

    final dlr = workbook.styles.add('dlrHeaderStyle')
      ..bold = true
      ..fontSize = 16
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center;

    final labelBox = workbook.styles.add('dlrLabelBoxStyle')
      ..bold = true
      ..fontSize = 10
      ..hAlign = HAlignType.left
      ..vAlign = VAlignType.center;
    labelBox.borders.left.lineStyle = LineStyle.thin;
    labelBox.borders.right.lineStyle = LineStyle.thin;
    labelBox.borders.top.lineStyle = LineStyle.thin;
    labelBox.borders.bottom.lineStyle = LineStyle.thin;

    final brandLabel = workbook.styles.add('dlrBrandLabelStyle')
      ..bold = true
      ..fontSize = 14
      ..fontColor = '#1565C0'
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..wrapText = true;

    final dayNightHeader = workbook.styles.add('dlrDayNightHeaderStyle')
      ..bold = true
      ..fontSize = 11
      ..fontColor = '#FFFFFF'
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor = '#4472C4';

    final dayNightValue = workbook.styles.add('dlrDayNightValueStyle')
      ..bold = true
      ..fontSize = 14
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor = '#DCE6F1';

    final header = workbook.styles.add('dlrHeaderCellStyle')
      ..bold = true
      ..fontSize = 10
      ..fontColor = '#FFFFFF'
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor = '#4472C4'
      ..wrapText = true;

    final activityHeader = workbook.styles.add('dlrActivityHeaderStyle')
      ..bold = true
      ..fontSize = 9
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor = '#B4C6E7';

    final data = workbook.styles.add('dlrDataStyle')
      ..fontSize = 9
      ..hAlign = HAlignType.left
      ..vAlign = VAlignType.center;

    final dataCenter = workbook.styles.add('dlrDataCenterStyle')
      ..fontSize = 9
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center;

    final subTotal = workbook.styles.add('dlrSubTotalStyle')
      ..bold = true
      ..fontSize = 9
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor = '#E2EFDA';

    final grandTotal = workbook.styles.add('dlrGrandTotalStyle')
      ..bold = true
      ..fontSize = 10
      ..fontColor = '#FFFFFF'
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor = '#4472C4';

    final summaryHeader = workbook.styles.add('dlrSummaryHeaderStyle')
      ..bold = true
      ..fontSize = 10
      ..fontColor = '#FFFFFF'
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor = '#4472C4';

    final summaryDataLabel = workbook.styles.add('dlrSummaryDataLabelStyle')
      ..fontSize = 9
      ..hAlign = HAlignType.left
      ..vAlign = VAlignType.center;

    final summaryFooter = workbook.styles.add('dlrSummaryFooterStyle')
      ..bold = true
      ..fontSize = 10
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor = '#B4C6E7';

    return _SiteWiseStyles._(
      title: title,
      dlr: dlr,
      labelBox: labelBox,
      brandLabel: brandLabel,
      dayNightHeader: dayNightHeader,
      dayNightValue: dayNightValue,
      header: header,
      activityHeader: activityHeader,
      data: data,
      dataCenter: dataCenter,
      subTotal: subTotal,
      grandTotal: grandTotal,
      summaryHeader: summaryHeader,
      summaryDataLabel: summaryDataLabel,
      summaryFooter: summaryFooter,
    );
  }
}

class _SummaryStyles {
  final Style companyTitle;
  final Style subtitle;
  final Style month;
  final Style dayReport;
  final Style header;
  final Style data;
  final Style dataCenter;
  final Style totalFooter;

  _SummaryStyles._({
    required this.companyTitle,
    required this.subtitle,
    required this.month,
    required this.dayReport,
    required this.header,
    required this.data,
    required this.dataCenter,
    required this.totalFooter,
  });

  factory _SummaryStyles(Workbook workbook) {
    final companyTitle = workbook.styles.add('sumCompanyTitleStyle')
      ..bold = true
      ..fontSize = 14
      ..hAlign = HAlignType.left;

    final subtitle = workbook.styles.add('sumSubtitleStyle')
      ..fontSize = 10
      ..hAlign = HAlignType.left;

    final month = workbook.styles.add('sumMonthStyle')
      ..bold = true
      ..fontSize = 10
      ..hAlign = HAlignType.left;

    final dayReport = workbook.styles.add('sumDayReportStyle')
      ..bold = true
      ..fontSize = 10
      ..hAlign = HAlignType.center;

    final header = workbook.styles.add('sumHeaderStyle')
      ..bold = true
      ..fontSize = 9
      ..fontColor = '#FFFFFF'
      ..hAlign = HAlignType.center
      ..vAlign = VAlignType.center
      ..backColor = '#4472C4'
      ..wrapText = true;

    final data = workbook.styles.add('sumDataStyle')
      ..fontSize = 9
      ..hAlign = HAlignType.left;

    final dataCenter = workbook.styles.add('sumDataCenterStyle')
      ..fontSize = 9
      ..hAlign = HAlignType.center;

    final totalFooter = workbook.styles.add('sumTotalFooterStyle')
      ..bold = true
      ..fontSize = 10
      ..hAlign = HAlignType.center
      ..backColor = '#B4C6E7';

    return _SummaryStyles._(
      companyTitle: companyTitle,
      subtitle: subtitle,
      month: month,
      dayReport: dayReport,
      header: header,
      data: data,
      dataCenter: dataCenter,
      totalFooter: totalFooter,
    );
  }
}

class DlrReportExcelFile {
  static Future<void> generateSiteWiseReport({
    required List<DlrReportDm> reportList,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final Workbook workbook = Workbook();
      final styles = _SiteWiseStyles(workbook);

      final Map<String, List<DlrReportDm>> groupedBySite = {};
      for (var item in reportList) {
        groupedBySite.putIfAbsent(item.siteCode, () => []).add(item);
      }

      final Map<int, Uint8List?> logoCache = {};

      bool firstSheet = true;
      for (final entry in groupedBySite.entries) {
        final siteItems = entry.value;
        final siteName = siteItems.first.siteName;
        final companyName = siteItems.first.coName;
        final coCode = siteItems.first.coCode;
        final sheetName = siteName.length > 31
            ? siteName.substring(0, 31)
            : siteName;

        Worksheet sheet;
        if (firstSheet) {
          sheet = workbook.worksheets[0];
          sheet.name = sheetName;
          firstSheet = false;
        } else {
          sheet = workbook.worksheets.addWithName(sheetName);
        }

        if (!logoCache.containsKey(coCode)) {
          logoCache[coCode] = await _loadLogoBytes(coCode);
        }
        final resolvedLogoBytes = logoCache[coCode];

        final Map<String, List<DlrReportDm>> groupedByDate = {};
        for (var item in siteItems) {
          groupedByDate.putIfAbsent(item.date, () => []).add(item);
        }
        final sortedDates = groupedByDate.keys.toList()
          ..sort((a, b) => _parseDate(b).compareTo(_parseDate(a)));

        int startRow = 0;
        for (final currentDate in sortedDates) {
          final dateItems = groupedByDate[currentDate]!;

          startRow = _writeSiteWiseSheet(
            sheet: sheet,
            styles: styles,
            siteItems: dateItems,
            companyName: companyName,
            siteName: siteName,
            fromDate: currentDate,
            toDate: currentDate,
            logoBytes: resolvedLogoBytes,
            startRow: startRow,
          );

          startRow += 2;
        }
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await _saveAndOpenExcel(bytes, 'DLR_SiteWise_Report');

      if (!AppScreenUtils.isWeb) {
        showSuccessSnackbar('Success', 'Excel report generated successfully');
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Excel file: $e');
    }
  }

  static DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd-MM-yyyy').parseStrict(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return DateTime(1900);
      }
    }
  }

  static int _writeSiteWiseSheet({
    required Worksheet sheet,
    required _SiteWiseStyles styles,
    required List<DlrReportDm> siteItems,
    required String companyName,
    required String siteName,
    required String fromDate,
    required String toDate,
    Uint8List? logoBytes,
    required int startRow,
  }) {
    int rowIndex = startRow;

    const int totalCols = 11;

    Range rangeAt(int col, int row) => sheet.getRangeByIndex(row + 1, col + 1);

    Range rangeBlock(int c1, int r1, int c2, int r2) =>
        sheet.getRangeByIndex(r1 + 1, c1 + 1, r2 + 1, c2 + 1);

    void setText(int col, int row, String text, Style style) {
      final r = rangeAt(col, row);
      r.setText(text);
      r.cellStyle = style;
    }

    void setNumber(int col, int row, double value, Style style) {
      final r = rangeAt(col, row);
      r.setNumber(value);
      r.cellStyle = style;
    }

    void merge(int c1, int r1, int c2, int r2) {
      rangeBlock(c1, r1, c2, r2).merge();
    }

    void mergeSetText(
      int c1,
      int r1,
      int c2,
      int r2,
      String text,
      Style style,
    ) {
      final block = rangeBlock(c1, r1, c2, r2);
      block.merge();
      rangeAt(c1, r1).setText(text);
      block.cellStyle = style;
    }

    void mergeSetNumber(
      int c1,
      int r1,
      int c2,
      int r2,
      double value,
      Style style,
    ) {
      final block = rangeBlock(c1, r1, c2, r2);
      block.merge();
      rangeAt(c1, r1).setNumber(value);
      block.cellStyle = style;
    }

    void applyStyleOnly(int col, int row, Style style) {
      rangeAt(col, row).cellStyle = style;
    }

    final Map<String, List<DlrReportDm>> groupedByActivity = {};
    for (var item in siteItems) {
      groupedByActivity.putIfAbsent(item.activity, () => []).add(item);
    }

    final Map<String, _ActivityTotals> activityTotals = {};
    double grandDaySkill = 0, grandDayUnSkill = 0;
    double grandNightSkill = 0, grandNightUnSkill = 0;

    groupedByActivity.forEach((activity, items) {
      final t = _ActivityTotals();
      for (var item in items) {
        if (item.isNight) {
          t.nightSkill += item.skill;
          t.nightUnSkill += item.unSkill;
        } else {
          t.daySkill += item.skill;
          t.dayUnSkill += item.unSkill;
        }
      }
      activityTotals[activity] = t;
      grandDaySkill += t.daySkill;
      grandDayUnSkill += t.dayUnSkill;
      grandNightSkill += t.nightSkill;
      grandNightUnSkill += t.nightUnSkill;
    });

    final double grandDayTotal = grandDaySkill + grandDayUnSkill;
    final double grandNightTotal = grandNightSkill + grandNightUnSkill;

    if (startRow == 0) {
      mergeSetText(
        0,
        rowIndex,
        7,
        rowIndex,
        companyName.toUpperCase(),
        styles.title,
      );

      merge(8, rowIndex, 10, rowIndex);
      rangeAt(0, rowIndex).rowHeight = 44;

      if (logoBytes != null) {
        final picture = sheet.pictures.addStream(rowIndex + 1, 9, logoBytes);
        picture.height = 58;
        picture.width = 190;
      } else {
        setText(
          8,
          rowIndex,
          _brandLabelForCompany(companyName),
          styles.brandLabel,
        );
      }
      rowIndex++;
    }

    mergeSetText(0, rowIndex, totalCols - 1, rowIndex, 'DLR', styles.dlr);
    rowIndex++;

    mergeSetText(
      0,
      rowIndex,
      4,
      rowIndex,
      'Name Of Project : $siteName',
      styles.labelBox,
    );
    mergeSetText(6, rowIndex, 7, rowIndex, 'Day', styles.dayNightHeader);
    mergeSetText(8, rowIndex, 9, rowIndex, 'Night', styles.dayNightHeader);
    rowIndex++;

    mergeSetText(
      0,
      rowIndex,
      4,
      rowIndex,
      'Name of Contractor : $companyName',
      styles.labelBox,
    );
    mergeSetNumber(
      6,
      rowIndex,
      7,
      rowIndex,
      grandDayTotal,
      styles.dayNightValue,
    );
    mergeSetNumber(
      8,
      rowIndex,
      9,
      rowIndex,
      grandNightTotal,
      styles.dayNightValue,
    );
    rowIndex++;

    mergeSetText(
      0,
      rowIndex,
      4,
      rowIndex,
      fromDate == toDate ? 'Date : $fromDate' : 'Date : $fromDate  to  $toDate',
      styles.labelBox,
    );
    rowIndex++;

    rowIndex++;

    final headerTopRow = rowIndex;
    final headerSubRow = rowIndex + 1;

    mergeSetText(0, headerTopRow, 0, headerSubRow, 'Sr.\nNo', styles.header);
    mergeSetText(
      1,
      headerTopRow,
      1,
      headerSubRow,
      'Name Of Agency',
      styles.header,
    );
    mergeSetText(
      2,
      headerTopRow,
      2,
      headerSubRow,
      'Work Description',
      styles.header,
    );
    mergeSetText(3, headerTopRow, 4, headerTopRow, 'DAY Work', styles.header);
    mergeSetText(5, headerTopRow, 6, headerTopRow, 'Night Work', styles.header);
    mergeSetText(7, headerTopRow, 8, headerTopRow, 'Time Night', styles.header);
    mergeSetText(
      9,
      headerTopRow,
      9,
      headerSubRow,
      'Total\n(A+B)',
      styles.header,
    );
    mergeSetText(10, headerTopRow, 10, headerSubRow, 'Remark', styles.header);

    final subHeaders = {
      3: 'Skill',
      4: 'Unskilled',
      5: 'Skill',
      6: 'Unskilled',
      7: 'In',
      8: 'Out',
    };
    subHeaders.forEach((col, label) {
      setText(col, headerSubRow, label, styles.header);
    });

    rowIndex = headerSubRow + 1;

    groupedByActivity.forEach((activity, items) {
      mergeSetText(
        0,
        rowIndex,
        totalCols - 1,
        rowIndex,
        activity,
        styles.activityHeader,
      );
      rowIndex++;

      for (var item in items) {
        setNumber(0, rowIndex, item.srNo.toDouble(), styles.dataCenter);
        setText(1, rowIndex, item.agencyName, styles.data);
        setText(
          2,
          rowIndex,
          item.description.isNotEmpty ? item.description : '-',
          styles.data,
        );

        if (item.isNight) {
          setNumber(5, rowIndex, item.skill, styles.dataCenter);
          setNumber(6, rowIndex, item.unSkill, styles.dataCenter);

          if (item.inTime.isNotEmpty) {
            setText(7, rowIndex, item.inTime, styles.dataCenter);
          }
          if (item.outTime.isNotEmpty) {
            setText(8, rowIndex, item.outTime, styles.dataCenter);
          }
        } else {
          setNumber(3, rowIndex, item.skill, styles.dataCenter);
          setNumber(4, rowIndex, item.unSkill, styles.dataCenter);
        }

        setNumber(9, rowIndex, item.skill + item.unSkill, styles.dataCenter);
        setText(
          10,
          rowIndex,
          item.remark.isNotEmpty ? item.remark : '-',
          styles.data,
        );

        rowIndex++;
      }

      final t = activityTotals[activity]!;
      mergeSetText(0, rowIndex, 1, rowIndex, 'Sub Total', styles.subTotal);
      applyStyleOnly(2, rowIndex, styles.subTotal);

      setNumber(3, rowIndex, t.daySkill, styles.subTotal);
      setNumber(4, rowIndex, t.dayUnSkill, styles.subTotal);
      setNumber(5, rowIndex, t.nightSkill, styles.subTotal);
      setNumber(6, rowIndex, t.nightUnSkill, styles.subTotal);

      mergeSetText(7, rowIndex, 8, rowIndex, 'G. Total', styles.subTotal);
      setNumber(9, rowIndex, t.grandTotal, styles.subTotal);
      applyStyleOnly(10, rowIndex, styles.subTotal);
      rowIndex++;
    });

    mergeSetText(0, rowIndex, 1, rowIndex, 'Grand Total', styles.grandTotal);
    applyStyleOnly(2, rowIndex, styles.grandTotal);
    setNumber(3, rowIndex, grandDaySkill, styles.grandTotal);
    setNumber(4, rowIndex, grandDayUnSkill, styles.grandTotal);
    setNumber(5, rowIndex, grandNightSkill, styles.grandTotal);
    setNumber(6, rowIndex, grandNightUnSkill, styles.grandTotal);
    merge(7, rowIndex, 8, rowIndex);
    applyStyleOnly(7, rowIndex, styles.grandTotal);
    setNumber(9, rowIndex, grandDayTotal + grandNightTotal, styles.grandTotal);
    applyStyleOnly(10, rowIndex, styles.grandTotal);
    rowIndex += 2;

    final sumHeaderTop = rowIndex;
    final sumHeaderSub = rowIndex + 1;

    mergeSetText(
      0,
      sumHeaderTop,
      2,
      sumHeaderSub,
      'Work Description',
      styles.summaryHeader,
    );
    mergeSetText(
      3,
      sumHeaderTop,
      4,
      sumHeaderTop,
      'DAY Work',
      styles.summaryHeader,
    );
    mergeSetText(
      5,
      sumHeaderTop,
      6,
      sumHeaderTop,
      'Night Work',
      styles.summaryHeader,
    );

    final sumSubHeaders = {
      3: 'Skill',
      4: 'Unskilled',
      5: 'Skill',
      6: 'Unskilled',
    };
    sumSubHeaders.forEach((col, label) {
      setText(col, sumHeaderSub, label, styles.summaryHeader);
    });
    rowIndex = sumHeaderSub + 1;

    for (final activity in groupedByActivity.keys) {
      final t = activityTotals[activity]!;

      mergeSetText(0, rowIndex, 2, rowIndex, activity, styles.summaryDataLabel);

      setNumber(3, rowIndex, t.daySkill, styles.dataCenter);
      setNumber(4, rowIndex, t.dayUnSkill, styles.dataCenter);
      setNumber(5, rowIndex, t.nightSkill, styles.dataCenter);
      setNumber(6, rowIndex, t.nightUnSkill, styles.dataCenter);
      rowIndex++;
    }

    mergeSetText(
      0,
      rowIndex,
      2,
      rowIndex,
      'Total Manpower',
      styles.summaryFooter,
    );
    setNumber(3, rowIndex, grandDaySkill, styles.summaryFooter);
    setNumber(4, rowIndex, grandDayUnSkill, styles.summaryFooter);
    setNumber(5, rowIndex, grandNightSkill, styles.summaryFooter);
    setNumber(6, rowIndex, grandNightUnSkill, styles.summaryFooter);
    rowIndex++;

    if (startRow == 0) {
      sheet.getRangeByIndex(1, 1).columnWidth = 7;
      sheet.getRangeByIndex(1, 2).columnWidth = 20;
      sheet.getRangeByIndex(1, 3).columnWidth = 30;
      sheet.getRangeByIndex(1, 4).columnWidth = 9;
      sheet.getRangeByIndex(1, 5).columnWidth = 11;
      sheet.getRangeByIndex(1, 6).columnWidth = 9;
      sheet.getRangeByIndex(1, 7).columnWidth = 11;
      sheet.getRangeByIndex(1, 8).columnWidth = 8;
      sheet.getRangeByIndex(1, 9).columnWidth = 8;
      sheet.getRangeByIndex(1, 10).columnWidth = 10;
      sheet.getRangeByIndex(1, 11).columnWidth = 18;
    }

    return rowIndex;
  }

  static Future<Uint8List?> _loadLogoBytes(int coCode) async {
    final assetPath = coCode == 1 ? kImageSCFULLLogo : kImagefulllogo;

    try {
      final data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      return null;
    }
  }

  static String _brandLabelForCompany(String companyName) {
    final name = companyName.toUpperCase();
    if (name.contains('URBANSPACE') || name.contains('URBAN SPACE')) {
      return 'SHIVAY\nURBANSPACE PVT. LTD.';
    }
    return 'SHIVAY\nCONSTRUCTION';
  }

  static Future<void> generateSummaryReport({
    required List<DlrReportDm> reportList,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final Workbook workbook = Workbook();
      final styles = _SummaryStyles(workbook);

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

        Worksheet sheet;
        if (firstSheet) {
          sheet = workbook.worksheets[0];
          sheet.name = sheetName;
          firstSheet = false;
        } else {
          sheet = workbook.worksheets.addWithName(sheetName);
        }

        _writeSummarySheet(
          sheet: sheet,
          styles: styles,
          companyItems: companyItems,
          companyName: companyName,
          fromDate: fromDate,
          toDate: toDate,
        );
      });

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await _saveAndOpenExcel(bytes, 'DLR_Summary_Report');

      if (!AppScreenUtils.isWeb) {
        showSuccessSnackbar('Success', 'Excel report generated successfully');
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Excel file: $e');
    }
  }

  static void _writeSummarySheet({
    required Worksheet sheet,
    required _SummaryStyles styles,
    required List<DlrReportDm> companyItems,
    required String companyName,
    required String fromDate,
    required String toDate,
  }) {
    int rowIndex = 0;

    final List<String> siteNames = [];
    for (var item in companyItems) {
      if (!siteNames.contains(item.siteName)) {
        siteNames.add(item.siteName);
      }
    }

    final int totalCols = 3 + siteNames.length + 1;

    Range rangeAt(int col, int row) => sheet.getRangeByIndex(row + 1, col + 1);
    Range rangeBlock(int c1, int r1, int c2, int r2) =>
        sheet.getRangeByIndex(r1 + 1, c1 + 1, r2 + 1, c2 + 1);

    void setText(int col, int row, String text, Style style) {
      final r = rangeAt(col, row);
      r.setText(text);
      r.cellStyle = style;
    }

    void setNumber(int col, int row, double value, Style style) {
      final r = rangeAt(col, row);
      r.setNumber(value);
      r.cellStyle = style;
    }

    void mergeSetText(
      int c1,
      int r1,
      int c2,
      int r2,
      String text,
      Style style,
    ) {
      final block = rangeBlock(c1, r1, c2, r2);
      block.merge();
      rangeAt(c1, r1).setText(text);
      block.cellStyle = style;
    }

    mergeSetText(
      0,
      rowIndex,
      totalCols - 1,
      rowIndex,
      companyName,
      styles.companyTitle,
    );
    rowIndex++;

    mergeSetText(
      0,
      rowIndex,
      totalCols - 1,
      rowIndex,
      'Summary',
      styles.subtitle,
    );
    rowIndex++;

    final monthStr = DateFormat(
      'MMMM-yyyy',
    ).format(DateFormat('dd-MM-yyyy').parse(toDate));
    mergeSetText(
      0,
      rowIndex,
      totalCols - 1,
      rowIndex,
      'Month : $monthStr',
      styles.month,
    );
    rowIndex++;

    rowIndex++;

    mergeSetText(
      0,
      rowIndex,
      totalCols - 1,
      rowIndex,
      'Day Report - $fromDate to $toDate',
      styles.dayReport,
    );
    rowIndex++;

    setText(0, rowIndex, 'Sr.\nNo.', styles.header);
    setText(1, rowIndex, 'Name of Agency', styles.header);
    setText(2, rowIndex, 'Work Description', styles.header);

    for (int i = 0; i < siteNames.length; i++) {
      setText(3 + i, rowIndex, siteNames[i], styles.header);
    }
    setText(3 + siteNames.length, rowIndex, 'Total\nPerson', styles.header);
    rowIndex++;

    final Map<String, Map<String, double>> agencyData = {};
    final Map<String, String> agencyActivityMap = {};

    for (var item in companyItems) {
      final key = '${item.agencyName}__${item.activity}';
      agencyActivityMap[key] = item.activity;
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

      setNumber(0, rowIndex, srNo.toDouble(), styles.dataCenter);
      setText(1, rowIndex, agencyName, styles.data);
      setText(2, rowIndex, activity.isNotEmpty ? activity : '-', styles.data);

      for (int i = 0; i < siteNames.length; i++) {
        final val = siteMap[siteNames[i]];
        setText(
          3 + i,
          rowIndex,
          val != null && val > 0 ? val.toStringAsFixed(0) : '-',
          styles.dataCenter,
        );
      }

      setText(
        3 + siteNames.length,
        rowIndex,
        rowTotal > 0 ? rowTotal.toStringAsFixed(0) : '-',
        styles.dataCenter,
      );

      srNo++;
      rowIndex++;
    });

    rowIndex += 2;

    for (int i = 0; i < siteNames.length; i++) {
      final val = siteColumnTotals[siteNames[i]] ?? 0;
      setNumber(3 + i, rowIndex, val, styles.totalFooter);
    }
    setNumber(3 + siteNames.length, rowIndex, grandTotal, styles.totalFooter);

    sheet.getRangeByIndex(1, 1).columnWidth = 7;
    sheet.getRangeByIndex(1, 2).columnWidth = 22;
    sheet.getRangeByIndex(1, 3).columnWidth = 22;
    for (int i = 0; i < siteNames.length; i++) {
      sheet.getRangeByIndex(1, 4 + i).columnWidth = 12;
    }
    sheet.getRangeByIndex(1, 4 + siteNames.length).columnWidth = 14;
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
