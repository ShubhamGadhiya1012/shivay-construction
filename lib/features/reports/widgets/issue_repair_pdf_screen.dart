import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/reports/models/issue_repair_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class IssueRepairPdfScreen {
  static Future<void> generateIssueRepairPdf({
    required List<IssueRepairReportDm> reportData,
    required String fromDate,
    required String toDate,
    required String status,
  }) async {
    try {
      if (reportData.isEmpty) {
        showErrorSnackbar('Error', 'No data found to generate PDF.');
        return;
      }

      final pdf = pw.Document();

      final headerColor = PdfColor.fromHex('#1D5B86');
      final tableHeaderColor = PdfColor.fromHex('#E3F2FD');
      final textColor = PdfColor.fromHex('#333333');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          header: (context) =>
              _buildHeader(headerColor, fromDate, toDate, status),
          build: (context) => [
            pw.SizedBox(height: 10),
            _buildTable(reportData, tableHeaderColor, textColor),
            pw.SizedBox(height: 20),
            _buildSummary(reportData, textColor),
          ],
          footer: (context) => _buildFooter(context),
        ),
      );

      await _savePdf(pdf);
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate PDF: $e');
    //  print('PDF Generation Error: $e');
    }
  }

  static pw.Widget _buildHeader(
    PdfColor headerColor,
    String fromDate,
    String toDate,
    String status,
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
                'ISSUE REPAIR REPORT',
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

  static pw.Widget _buildTable(
    List<IssueRepairReportDm> data,
    PdfColor headerBgColor,
    PdfColor textColor,
  ) {
    final headers = [
      'Issue No',
      'Issue Date',
      'Party Name',
      'Site Name',
      'Godown Name',
      'Description',
      'Issued Qty',
      'Received Qty',
      'Pending Qty',
      'Status',
      'Remarks',
    ];

    final columnWidths = {
      0: const pw.FlexColumnWidth(2.5),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(2.5),
      3: const pw.FlexColumnWidth(2),
      4: const pw.FlexColumnWidth(2),
      5: const pw.FlexColumnWidth(3),
      6: const pw.FlexColumnWidth(1.5),
      7: const pw.FlexColumnWidth(1.5),
      8: const pw.FlexColumnWidth(1.5),
      9: const pw.FlexColumnWidth(1.5),
      10: const pw.FlexColumnWidth(2),
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: columnWidths,
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerBgColor),
          children: headers
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

        ...data.asMap().entries.map((entry) {
          final item = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: entry.key.isEven ? PdfColors.white : PdfColors.grey100,
            ),
            children: [
              _cell(item.issueInvNo, textColor),
              _cell(
                _formatDate(item.issueDate),
                textColor,
                align: pw.TextAlign.center,
              ),
              _cell(item.pName, textColor),
              _cell(item.siteName, textColor),
              _cell(item.gdName, textColor),
              _cell(item.description, textColor),
              _cell(
                item.issuedQty.toStringAsFixed(2),
                textColor,
                align: pw.TextAlign.right,
              ),
              _cell(
                item.receivedQty.toStringAsFixed(2),
                textColor,
                align: pw.TextAlign.right,
              ),
              _cell(
                item.pendingQty.toStringAsFixed(2),
                item.pendingQty > 0 ? PdfColors.red : PdfColors.green,
                align: pw.TextAlign.right,
              ),
              _cell(
                item.status,
                _getStatusColor(item.status),
                align: pw.TextAlign.center,
              ),
              _cell(item.remarks.isNotEmpty ? item.remarks : '-', textColor),
            ],
          );
        }),
      ],
    );
  }

  static String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final inputFormat = DateFormat('yyyy-MM-dd');
      final outputFormat = DateFormat('dd-MM-yyyy');
      final date = inputFormat.parse(dateStr);
      return outputFormat.format(date);
    } catch (e) {
      return dateStr;
    }
  }

  static pw.Widget _buildSummary(
    List<IssueRepairReportDm> data,
    PdfColor textColor,
  ) {
    final totalIssues = data.length;
    final totalIssuedQty = data.fold(0.0, (sum, item) => sum + item.issuedQty);
    final totalReceivedQty = data.fold(
      0.0,
      (sum, item) => sum + item.receivedQty,
    );
    final totalPendingQty = data.fold(
      0.0,
      (sum, item) => sum + item.pendingQty,
    );

    final statusCounts = <String, int>{};
    for (var item in data) {
      statusCounts[item.status] = (statusCounts[item.status] ?? 0) + 1;
    }

    final uniqueParties = data.map((e) => e.pName).toSet().length;
    final uniqueSites = data.map((e) => e.siteName).toSet().length;

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
                  _summaryRow('Total Issues:', '$totalIssues'),
                  _summaryRow(
                    'Total Issued Qty:',
                    totalIssuedQty.toStringAsFixed(2),
                  ),
                  _summaryRow(
                    'Total Received Qty:',
                    totalReceivedQty.toStringAsFixed(2),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _summaryRow(
                    'Total Pending Qty:',
                    totalPendingQty.toStringAsFixed(2),
                  ),
                  _summaryRow('Unique Parties:', '$uniqueParties'),
                  _summaryRow('Unique Sites:', '$uniqueSites'),
                  ...statusCounts.entries.map((entry) {
                    return _summaryRow(
                      '${entry.key}:',
                      '${entry.value}',
                      color: _getStatusColor(entry.key),
                    );
                  }),
                ],
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
      case 'received':
        return PdfColors.green;
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
          pw.Text('Issue Repair Report', style: pw.TextStyle(fontSize: 9)),
          pw.Text(
            'Page ${context.pageNumber}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final file = File('${dir.path}/IssueRepair_Report_$timestamp.pdf');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }
}
