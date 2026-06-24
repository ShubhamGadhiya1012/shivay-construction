import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/reports/models/dlr_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class DlrReportPdfScreen {
  static Future<void> generateSiteWisePdf({
    required List<DlrReportDm> reportData,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      if (reportData.isEmpty) {
        showErrorSnackbar('Error', 'No data found to generate PDF.');
        return;
      }

      final pdf = pw.Document();

      final tableHeaderColor = PdfColor.fromHex('#4472C4');
      final activityHeaderColor = PdfColor.fromHex('#B4C6E7');
      final subTotalColor = PdfColor.fromHex('#E2EFDA');
      final textColor = PdfColor.fromHex('#333333');
      final reportDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      final Map<String, List<DlrReportDm>> groupedBySite = {};
      for (var item in reportData) {
        groupedBySite.putIfAbsent(item.siteCode, () => []).add(item);
      }

      groupedBySite.forEach((siteCode, siteItems) {
        final siteName = siteItems.first.siteName;
        final companyName = siteItems.first.coName;

        final Map<String, List<DlrReportDm>> groupedByActivity = {};
        for (var item in siteItems) {
          groupedByActivity.putIfAbsent(item.activity, () => []).add(item);
        }

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.all(20),
            // FIX: build returns a flat List<pw.Widget> so MultiPage can
            // paginate each widget independently instead of one giant Column.
            build: (context) {
              return [
                pw.Center(
                  child: pw.Text(
                    companyName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    siteName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'From: $fromDate   To: $toDate',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      'DLR_$reportDate',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                // Spread all table/content widgets directly into the list
                ..._buildSiteWiseContentWidgets(
                  companyName: companyName,
                  siteName: siteName,
                  reportDate: reportDate,
                  fromDate: fromDate,
                  toDate: toDate,
                  groupedByActivity: groupedByActivity,
                  tableHeaderColor: tableHeaderColor,
                  activityHeaderColor: activityHeaderColor,
                  subTotalColor: subTotalColor,
                  textColor: textColor,
                ),
              ];
            },
            footer: (context) => _buildFooter(context),
          ),
        );
      });

      await _savePdf(pdf, 'DLR_SiteWise_Report');
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate PDF: $e');
    }
  }

  // Renamed from _buildSiteWisePage, now returns List<pw.Widget>
  // so MultiPage can paginate across them properly.
  static List<pw.Widget> _buildSiteWiseContentWidgets({
    required String companyName,
    required String siteName,
    required String reportDate,
    required String fromDate,
    required String toDate,
    required Map<String, List<DlrReportDm>> groupedByActivity,
    required PdfColor tableHeaderColor,
    required PdfColor activityHeaderColor,
    required PdfColor subTotalColor,
    required PdfColor textColor,
  }) {
    final headers = [
      'Sr. No',
      'Name of Agency',
      'Skill',
      'Unskilled',
      'Work Description',
      'Remark',
    ];

    final columnWidths = {
      0: const pw.FlexColumnWidth(0.8),
      1: const pw.FlexColumnWidth(2.0),
      2: const pw.FlexColumnWidth(1.2),
      3: const pw.FlexColumnWidth(1.5),
      4: const pw.FlexColumnWidth(4.0),
      5: const pw.FlexColumnWidth(1.5),
    };

    double grandTotalSkill = 0;
    double grandTotalUnSkill = 0;
    double grandTotalAmount = 0;

    List<pw.Widget> contentWidgets = [];

    contentWidgets.add(
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
        columnWidths: columnWidths,
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: tableHeaderColor),
            children: headers
                .map(
                  (h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      h,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );

    groupedByActivity.forEach((activity, activityItems) {
      double activityTotalSkill = 0;
      double activityTotalUnSkill = 0;
      double activityTotal = 0;

      contentWidgets.add(
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            color: activityHeaderColor,
            border: pw.Border(
              left: pw.BorderSide(color: PdfColors.grey, width: 0.5),
              right: pw.BorderSide(color: PdfColors.grey, width: 0.5),
              bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5),
            ),
          ),
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: pw.Center(
            child: pw.Text(
              activity,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      );

      List<pw.TableRow> activityRows = [];

      for (int i = 0; i < activityItems.length; i++) {
        final item = activityItems[i];
        activityTotalSkill += item.skill;
        activityTotalUnSkill += item.unSkill;
        activityTotal += item.total;

        activityRows.add(
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? PdfColors.white : PdfColor.fromHex('#F5F5F5'),
            ),
            children: [
              _cell(
                item.srNo.toString(),
                textColor,
                align: pw.TextAlign.center,
              ),
              _cell(item.agencyName, textColor),
              _cell(
                item.skill.toStringAsFixed(1),
                textColor,
                align: pw.TextAlign.center,
              ),
              _cell(
                item.unSkill.toStringAsFixed(1),
                textColor,
                align: pw.TextAlign.center,
              ),
              _cell(
                item.description.isNotEmpty ? item.description : '-',
                textColor,
              ),
              _cell(item.remark.isNotEmpty ? item.remark : '-', textColor),
            ],
          ),
        );
      }

      activityRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: subTotalColor),
          children: [
            _cell('', textColor),
            _cell(
              'Sub Total',
              textColor,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            ),
            _cell(
              activityTotalSkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            ),
            _cell(
              activityTotalUnSkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            ),
            _cell('', textColor),
            _cell(
              activityTotal.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            ),
          ],
        ),
      );

      contentWidgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          columnWidths: columnWidths,
          children: activityRows,
        ),
      );

      grandTotalSkill += activityTotalSkill;
      grandTotalUnSkill += activityTotalUnSkill;
      grandTotalAmount += activityTotal;
    });

    contentWidgets.add(
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
        columnWidths: columnWidths,
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: tableHeaderColor),
            children: [
              _cell('', PdfColors.white),
              _cell(
                'Grand Total',
                PdfColors.white,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
              ),
              _cell(
                grandTotalSkill.toStringAsFixed(1),
                PdfColors.white,
                align: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
              ),
              _cell(
                grandTotalUnSkill.toStringAsFixed(1),
                PdfColors.white,
                align: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
              ),
              _cell(
                grandTotalAmount.toStringAsFixed(1),
                PdfColors.white,
                align: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
              ),
              _cell('', PdfColors.white),
            ],
          ),
        ],
      ),
    );

    return contentWidgets;
  }

  static Future<void> generateSummaryPdf({
    required List<DlrReportDm> reportData,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      if (reportData.isEmpty) {
        showErrorSnackbar('Error', 'No data found to generate PDF.');
        return;
      }

      final pdf = pw.Document();

      final tableHeaderColor = PdfColor.fromHex('#4472C4');
      final activityHeaderColor = PdfColor.fromHex('#B4C6E7');
      final textColor = PdfColor.fromHex('#333333');
      final reportDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      final Map<String, List<DlrReportDm>> groupedByCompany = {};
      for (var item in reportData) {
        final key = '${item.coCode}_${item.coName}';
        groupedByCompany.putIfAbsent(key, () => []).add(item);
      }

      groupedByCompany.forEach((companyKey, companyItems) {
        final companyName = companyItems.first.coName;

        final List<String> siteNames = [];
        for (var item in companyItems) {
          if (!siteNames.contains(item.siteName)) {
            siteNames.add(item.siteName);
          }
        }

        final Map<String, Map<String, double>> agencyData = {};
        final Map<String, String> agencyDescMap = {};
        final Map<String, String> agencyActivityMap = {};

        for (var item in companyItems) {
          final key = '${item.agencyName}__${item.activity}';
          agencyActivityMap[key] = item.activity;
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

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.all(20),
            build: (context) => [
              _buildSummaryPage(
                companyName: companyName,
                reportDate: reportDate,
                fromDate: fromDate,
                toDate: toDate,
                siteNames: siteNames,
                agencyData: agencyData,
                agencyDescMap: agencyDescMap,
                siteColumnTotals: siteColumnTotals,
                grandTotal: grandTotal,
                tableHeaderColor: tableHeaderColor,
                activityHeaderColor: activityHeaderColor,
                textColor: textColor,
              ),
            ],
            footer: (context) => _buildFooter(context),
          ),
        );
      });

      await _savePdf(pdf, 'DLR_Summary_Report');
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Summary PDF: $e');
    }
  }

  static pw.Widget _buildSummaryPage({
    required String companyName,
    required String reportDate,
    required String fromDate,
    required String toDate,
    required List<String> siteNames,
    required Map<String, Map<String, double>> agencyData,
    required Map<String, String> agencyDescMap,
    required Map<String, double> siteColumnTotals,
    required double grandTotal,
    required PdfColor tableHeaderColor,
    required PdfColor activityHeaderColor,
    required PdfColor textColor,
  }) {
    final int fixedCols = 3;
    final int totalCols = fixedCols + siteNames.length + 1;

    Map<int, pw.TableColumnWidth> columnWidths = {
      0: const pw.FlexColumnWidth(0.6),
      1: const pw.FlexColumnWidth(2.2),
      2: const pw.FlexColumnWidth(2.5),
    };
    for (int i = 0; i < siteNames.length; i++) {
      columnWidths[fixedCols + i] = const pw.FlexColumnWidth(1.2);
    }
    columnWidths[fixedCols + siteNames.length] = const pw.FlexColumnWidth(1.2);

    List<pw.TableRow> rows = [];

    List<pw.Widget> headerCells = [
      _headerCell('Sr.\nNo.'),
      _headerCell('Name of Agency'),
      _headerCell('Work Description'),
    ];
    for (var site in siteNames) {
      headerCells.add(_headerCell(site, fontSize: 7));
    }
    headerCells.add(_headerCell('Total\nPerson'));

    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: tableHeaderColor),
        children: headerCells,
      ),
    );

    int srNo = 1;
    agencyData.forEach((key, siteMap) {
      final parts = key.split('__');
      final agencyName = parts[0];
      final activity = parts.length > 1 ? parts[1] : '';
      double rowTotal = siteMap.values.fold(0, (a, b) => a + b);

      List<pw.Widget> cells = [
        _dataCell(srNo.toString(), align: pw.TextAlign.center),
        _dataCell(agencyName),
        _dataCell(activity.isNotEmpty ? activity : '-'),
      ];

      for (var site in siteNames) {
        final val = siteMap[site];
        cells.add(
          _dataCell(
            val != null && val > 0 ? val.toStringAsFixed(0) : '-',
            align: pw.TextAlign.center,
          ),
        );
      }
      cells.add(
        _dataCell(
          rowTotal > 0 ? rowTotal.toStringAsFixed(0) : '-',
          align: pw.TextAlign.center,
          bold: true,
        ),
      );

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: srNo.isOdd ? PdfColors.white : PdfColor.fromHex('#F5F5F5'),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.3),
          ),
          children: cells,
        ),
      );
      srNo++;
    });

    for (int i = 0; i < 2; i++) {
      rows.add(
        pw.TableRow(
          children: List.generate(
            totalCols,
            (_) => pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('', style: const pw.TextStyle(fontSize: 8)),
            ),
          ),
        ),
      );
    }

    List<pw.Widget> totalCells = [
      _dataCell('', align: pw.TextAlign.center),
      _dataCell('', align: pw.TextAlign.center),
      _dataCell('', align: pw.TextAlign.center),
    ];
    for (var site in siteNames) {
      final val = siteColumnTotals[site] ?? 0;
      totalCells.add(
        _dataCell(
          val > 0 ? val.toStringAsFixed(0) : '0',
          align: pw.TextAlign.center,
          bold: true,
        ),
      );
    }
    totalCells.add(
      _dataCell(
        grandTotal.toStringAsFixed(0),
        align: pw.TextAlign.center,
        bold: true,
      ),
    );

    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey, width: 0.5),
        ),
        children: totalCells,
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                companyName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Summary', style: const pw.TextStyle(fontSize: 10)),
              pw.Text(
                'Month : ${DateFormat('MMMM-yyyy').format(DateFormat('dd-MM-yyyy').parse(toDate))}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
          ),
          child: pw.Center(
            child: pw.Text(
              'Day Report - $reportDate',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          columnWidths: columnWidths,
          children: rows,
        ),
      ],
    );
  }

  static pw.Widget _headerCell(String text, {double fontSize = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _dataCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _cell(
    String text,
    PdfColor color, {
    pw.TextAlign align = pw.TextAlign.left,
    pw.TextStyle? style,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        textAlign: align,
        style: style ?? pw.TextStyle(fontSize: 8, color: color),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('DLR Entry Report', style: pw.TextStyle(fontSize: 8)),
          pw.Text(
            'Page ${context.pageNumber}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String fileName) async {
    try {
      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final reportDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final file = File('${dir.path}/${fileName}_${reportDate}_$timestamp.pdf');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
      showSuccessSnackbar('Success', 'PDF report generated successfully');
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to save PDF: $e');
    }
  }
}
