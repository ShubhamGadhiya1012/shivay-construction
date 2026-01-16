import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/reports/models/purchase_order_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';

class PurchaseOrderPdfScreen {
  static Future<void> generatePurchaseOrderPdf({
    required List<PurchaseOrderReportDm> reportData,
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
          ],
          footer: (context) => _buildFooter(context),
        ),
      );

      await _savePdf(pdf);
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate PDF: $e');
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
                'PURCHASE ORDER REPORT',
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
    List<PurchaseOrderReportDm> data,
    PdfColor headerBgColor,
    PdfColor textColor,
  ) {
    final headers = [
      'PO No',
      'PO Date',
      'Item Name',
      'Unit',
      'PO Qty',
      'Rate',
      'Amount',
      'Site Name',
      'Party Name',
      'Status',
      'Authorized',
    ];

    final columnWidths = {
      0: const pw.FlexColumnWidth(2.5),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(3.5),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(1.2),
      5: const pw.FlexColumnWidth(1.2),
      6: const pw.FlexColumnWidth(1.8),
      7: const pw.FlexColumnWidth(2.5),
      8: const pw.FlexColumnWidth(2.5),
      9: const pw.FlexColumnWidth(1.5),
      10: const pw.FlexColumnWidth(1.5),
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
              _cell(item.poNo, textColor),
              _cell(
                convertyyyyMMddToddMMyyyy(item.poDate),
                textColor,
                align: pw.TextAlign.center,
              ),
              _cell(item.iName, textColor),
              _cell(item.unit, textColor, align: pw.TextAlign.center),
              _cell(
                item.poQty.toStringAsFixed(2),
                textColor,
                align: pw.TextAlign.right,
              ),
              _cell(
                item.rate.toStringAsFixed(2),
                textColor,
                align: pw.TextAlign.right,
              ),
              _cell(
                item.amount.toStringAsFixed(2),
                textColor,
                align: pw.TextAlign.right,
              ),
              _cell(item.siteName, textColor),
              _cell(item.partyName, textColor),
              _cell(
                item.poStatus,
                _getStatusColor(item.poStatus),
                align: pw.TextAlign.center,
              ),
              _cell(
                item.authorize ? 'Yes' : 'No',
                item.authorize ? PdfColors.green : PdfColors.red,
                align: pw.TextAlign.center,
              ),
            ],
          );
        }),
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
        return PdfColors.red;
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
          pw.Text('Purchase Order Report', style: pw.TextStyle(fontSize: 9)),
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

    final file = File('${dir.path}/PurchaseOrder_Report_$timestamp.pdf');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }
}
