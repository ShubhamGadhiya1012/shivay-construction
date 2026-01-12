import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/reports/models/grn_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';

class GrnReportPdfScreen {
  static Future<void> generateGrnReportPdf({
    required List<GrnReportDm> reportData,
    required String fromDate,
    required String toDate,
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
          header: (context) => _buildHeader(headerColor, fromDate, toDate),
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
    }
  }

  static pw.Widget _buildHeader(
    PdfColor headerColor,
    String fromDate,
    String toDate,
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
                'GRN REPORT',
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
    List<GrnReportDm> data,
    PdfColor headerBgColor,
    PdfColor textColor,
  ) {
    final headers = [
      'GRN No',
      'GRN Date',
      'Party Name',
      'Site Name',
      'Godown Name',
      'Item Name',
      'Unit',
      'GRN Qty',
      'PO No',
      'Remark',
    ];

    final columnWidths = {
      0: const pw.FlexColumnWidth(2.5),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(2.5),
      3: const pw.FlexColumnWidth(2),
      4: const pw.FlexColumnWidth(2),
      5: const pw.FlexColumnWidth(3),
      6: const pw.FlexColumnWidth(1),
      7: const pw.FlexColumnWidth(1.5),
      8: const pw.FlexColumnWidth(2.5),
      9: const pw.FlexColumnWidth(2),
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
              _cell(item.grnNo, textColor),
              _cell(
                convertyyyyMMddToddMMyyyy(item.grnDate),
                textColor,
                align: pw.TextAlign.center,
              ),
              _cell(item.pName, textColor),
              _cell(item.siteName, textColor),
              _cell(item.gdName, textColor),
              _cell(item.iName, textColor),
              _cell(item.unit, textColor, align: pw.TextAlign.center),
              _cell(
                item.grnQty.toStringAsFixed(2),
                textColor,
                align: pw.TextAlign.right,
              ),
              _cell(item.poInvNo, textColor),
              _cell(item.remark.isNotEmpty ? item.remark : '-', textColor),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildSummary(List<GrnReportDm> data, PdfColor textColor) {
    final totalGRNs = data.map((e) => e.grnNo).toSet().length;
    final totalQuantity = data.fold(0.0, (sum, item) => sum + item.grnQty);
    final uniqueItems = data.map((e) => e.iCode).toSet().length;
    final uniqueParties = data.map((e) => e.pName).toSet().length;
    final uniquePOs = data
        .map((e) => e.poInvNo)
        .where((po) => po.isNotEmpty)
        .toSet()
        .length;

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
                  _summaryRow('Total GRNs:', '$totalGRNs'),
                  _summaryRow(
                    'Total Quantity:',
                    totalQuantity.toStringAsFixed(2),
                  ),
                  _summaryRow('Unique Items:', '$uniqueItems'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _summaryRow('Unique Parties:', '$uniqueParties'),
                  _summaryRow('Unique POs:', '$uniquePOs'),
                  _summaryRow('Total Records:', '${data.length}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(width: 5),
        pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
      ],
    );
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
          pw.Text('GRN Report', style: pw.TextStyle(fontSize: 9)),
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

    final file = File('${dir.path}/GRN_Report_$timestamp.pdf');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }
}
