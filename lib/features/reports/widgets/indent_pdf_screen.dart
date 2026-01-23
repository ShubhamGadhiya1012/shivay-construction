import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/reports/models/indent_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';

class IndentPdfScreen {
  static Future<void> generateIndentPdf({
    required List<IndentReportDm> reportData,
    required String fromDate,
    required String toDate,
    required String status,
    required String reportType,
  }) async {
    try {
      if (reportData.isEmpty) {
        showErrorSnackbar('Error', 'No data found to generate PDF.');
        return;
      }

      final pdf = pw.Document();

      final headerColor = PdfColor.fromHex('#1D5B86');
      final tableHeaderColor = PdfColor.fromHex('#E3F2FD');
      final groupHeaderColor = PdfColor.fromHex('#BBDEFB');
      final textColor = PdfColor.fromHex('#333333');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          header: (context) =>
              _buildHeader(headerColor, fromDate, toDate, status, reportType),
          build: (context) => [
            pw.SizedBox(height: 10),
            reportType == 'ItemWise'
                ? _buildItemWiseGroupedTable(
                    reportData,
                    tableHeaderColor,
                    groupHeaderColor,
                    textColor,
                  )
                : _buildSiteWiseGroupedTable(
                    reportData,
                    tableHeaderColor,
                    groupHeaderColor,
                    textColor,
                  ),
            pw.SizedBox(height: 20),
            _buildSummary(reportData, textColor),
          ],
          footer: (context) => _buildFooter(context),
        ),
      );

      await _savePdf(pdf, reportType);
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate PDF: $e');
    }
  }

  static pw.Widget _buildHeader(
    PdfColor headerColor,
    String fromDate,
    String toDate,
    String status,
    String reportType,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: headerColor, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INDENT REPORT - $reportType',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: headerColor,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'From: $fromDate   To: $toDate',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Status: $status',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemWiseGroupedTable(
    List<IndentReportDm> data,
    PdfColor headerBgColor,
    PdfColor groupHeaderColor,
    PdfColor textColor,
  ) {
    // Group data by item code
    final Map<String, List<IndentReportDm>> groupedData = {};
    for (var item in data) {
      if (!groupedData.containsKey(item.iCode)) {
        groupedData[item.iCode] = [];
      }
      groupedData[item.iCode]!.add(item);
    }

    final detailHeaders = [
      'Site Name',
      'Req Date',
      'Indent Date',
      'Indent Qty',
      'Indent No',
      'Godown Name',
      'Order Qty',
      'Pending Qty',
      'Ref PO No',
      'Status',
    ];

    final columnWidths = {
      0: const pw.FlexColumnWidth(2.5),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(1.5),
      4: const pw.FlexColumnWidth(2.5),
      5: const pw.FlexColumnWidth(2.5),
      6: const pw.FlexColumnWidth(1.5),
      7: const pw.FlexColumnWidth(1.5),
      8: const pw.FlexColumnWidth(2.0),
      9: const pw.FlexColumnWidth(1.5),
    };

    List<pw.Widget> widgets = [];

    groupedData.forEach((itemCode, items) {
      final firstItem = items.first;
      final totalQty = items.fold(0.0, (sum, item) => sum + item.indentQty);

      // Item header
      widgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: groupHeaderColor,
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Item: ${firstItem.iName} (${firstItem.iCode})',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Total Indent Qty: ${totalQty.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

      // Details table
      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          columnWidths: columnWidths,
          children: [
            // Table header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: headerBgColor),
              children: detailHeaders
                  .map(
                    (h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        h,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            // Detail rows
            ...items.asMap().entries.map((entry) {
              final item = entry.value;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: entry.key.isEven ? PdfColors.white : PdfColors.grey100,
                ),
                children: [
                  _cell(item.siteName, textColor),
                  _cell(
                    convertyyyyMMddToddMMyyyy(item.reqDate),
                    textColor,
                    align: pw.TextAlign.center,
                  ),
                  _cell(
                    convertyyyyMMddToddMMyyyy(item.indentDate),
                    textColor,
                    align: pw.TextAlign.center,
                  ),
                  _cell(
                    item.indentQty.toStringAsFixed(2),
                    textColor,
                    align: pw.TextAlign.right,
                  ),
                  _cell(item.invno, textColor),
                  _cell(item.gdName, textColor),
                  _cell(
                    item.orderQty.toStringAsFixed(2),
                    textColor,
                    align: pw.TextAlign.right,
                  ),
                  _cell(
                    item.pendingQty.toStringAsFixed(2),
                    item.pendingQty > 0 ? PdfColors.red : PdfColors.green,
                    align: pw.TextAlign.right,
                  ),
                  _cell(
                    item.refPOInvNo.isNotEmpty ? item.refPOInvNo : '-',
                    textColor,
                  ),
                  _cell(
                    item.indentStatus,
                    _getStatusColor(item.indentStatus),
                    align: pw.TextAlign.center,
                  ),
                ],
              );
            }),
          ],
        ),
      );

      widgets.add(pw.SizedBox(height: 15));
    });

    return pw.Column(children: widgets);
  }

  static pw.Widget _buildSiteWiseGroupedTable(
    List<IndentReportDm> data,
    PdfColor headerBgColor,
    PdfColor groupHeaderColor,
    PdfColor textColor,
  ) {
    // Group data by site code
    final Map<String, List<IndentReportDm>> groupedData = {};
    for (var item in data) {
      if (!groupedData.containsKey(item.siteCode)) {
        groupedData[item.siteCode] = [];
      }
      groupedData[item.siteCode]!.add(item);
    }

    final detailHeaders = [
      'Item Name',
      'Req Date',
      'Indent Date',
      'Indent Qty',
      'Indent No',
      'Godown Name',
      'Order Qty',
      'Pending Qty',
      'Ref PO No',
      'Status',
    ];

    final columnWidths = {
      0: const pw.FlexColumnWidth(3.0),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(1.5),
      4: const pw.FlexColumnWidth(2.5),
      5: const pw.FlexColumnWidth(2.5),
      6: const pw.FlexColumnWidth(1.5),
      7: const pw.FlexColumnWidth(1.5),
      8: const pw.FlexColumnWidth(2.0),
      9: const pw.FlexColumnWidth(1.5),
    };

    List<pw.Widget> widgets = [];

    groupedData.forEach((siteCode, items) {
      final firstItem = items.first;
      final totalQty = items.fold(0.0, (sum, item) => sum + item.indentQty);

      // Site header
      widgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: groupHeaderColor,
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Site: ${firstItem.siteName} (${firstItem.siteCode})',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Total Indent Qty: ${totalQty.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

      // Details table
      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          columnWidths: columnWidths,
          children: [
            // Table header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: headerBgColor),
              children: detailHeaders
                  .map(
                    (h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        h,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            // Detail rows
            ...items.asMap().entries.map((entry) {
              final item = entry.value;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: entry.key.isEven ? PdfColors.white : PdfColors.grey100,
                ),
                children: [
                  _cell(item.iName, textColor),
                  _cell(
                    convertyyyyMMddToddMMyyyy(item.reqDate),
                    textColor,
                    align: pw.TextAlign.center,
                  ),
                  _cell(
                    convertyyyyMMddToddMMyyyy(item.indentDate),
                    textColor,
                    align: pw.TextAlign.center,
                  ),
                  _cell(
                    item.indentQty.toStringAsFixed(2),
                    textColor,
                    align: pw.TextAlign.right,
                  ),
                  _cell(item.invno, textColor),
                  _cell(item.gdName, textColor),
                  _cell(
                    item.orderQty.toStringAsFixed(2),
                    textColor,
                    align: pw.TextAlign.right,
                  ),
                  _cell(
                    item.pendingQty.toStringAsFixed(2),
                    item.pendingQty > 0 ? PdfColors.red : PdfColors.green,
                    align: pw.TextAlign.right,
                  ),
                  _cell(
                    item.refPOInvNo.isNotEmpty ? item.refPOInvNo : '-',
                    textColor,
                  ),
                  _cell(
                    item.indentStatus,
                    _getStatusColor(item.indentStatus),
                    align: pw.TextAlign.center,
                  ),
                ],
              );
            }),
          ],
        ),
      );

      widgets.add(pw.SizedBox(height: 15));
    });

    return pw.Column(children: widgets);
  }

  static pw.Widget _buildSummary(
    List<IndentReportDm> data,
    PdfColor textColor,
  ) {
    final totalIndentQty = data.fold(0.0, (sum, item) => sum + item.indentQty);
    final totalOrderQty = data.fold(0.0, (sum, item) => sum + item.orderQty);
    final totalPendingQty = totalIndentQty - totalOrderQty;

    final statusCounts = <String, int>{};
    for (var item in data) {
      statusCounts[item.indentStatus] =
          (statusCounts[item.indentStatus] ?? 0) + 1;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey, width: 0.5),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SUMMARY',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: textColor,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _summaryRow(
                    'Total Indent Qty:',
                    totalIndentQty.toStringAsFixed(2),
                  ),
                  _summaryRow(
                    'Total Order Qty:',
                    totalOrderQty.toStringAsFixed(2),
                  ),
                  _summaryRow(
                    'Total Pending Qty:',
                    totalPendingQty.toStringAsFixed(2),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: statusCounts.entries.map((entry) {
                  return _summaryRow(
                    '${entry.key} Indents:',
                    '${entry.value}',
                    color: _getStatusColor(entry.key),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value, {PdfColor? color}) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, color: color ?? PdfColors.black),
        ),
      ],
    );
  }

  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PdfColors.orange;
      case 'complete':
        return PdfColors.green;
      case 'close':
        return PdfColors.blue;
      default:
        return PdfColors.grey;
    }
  }

  static pw.Widget _cell(
    String text,
    PdfColor color, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 8.5, color: color),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Indent Report', style: pw.TextStyle(fontSize: 9)),
          pw.Text(
            'Page ${context.pageNumber}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String reportType) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final file = File('${dir.path}/Indent_Report_${reportType}_$timestamp.pdf');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }
}
