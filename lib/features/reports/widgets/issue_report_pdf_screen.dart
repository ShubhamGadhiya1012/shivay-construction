// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/reports/models/issue_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:universal_html/html.dart' as html;

class IssueReportPdfScreen {
  static Future<void> generateIssueReportPdf({
    required List<IssueReportDm> reportData,
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
      final groupHeaderColor = PdfColor.fromHex('#BBDEFB');
      final textColor = PdfColor.fromHex('#333333');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          header: (context) => _buildHeader(headerColor, fromDate, toDate),
          build: (context) => [
            pw.SizedBox(height: 10),
            _buildGroupedTable(
              reportData,
              tableHeaderColor,
              groupHeaderColor,
              textColor,
            ),
            // pw.SizedBox(height: 20),
            // _buildSummary(reportData, textColor),
          ],
          footer: (context) => _buildFooter(context),
        ),
      );

      await _savePdf(pdf);
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate PDF: $e');
    }
  }

  // ─── Header ───────────────────────────────────────────────────────────────

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
                'ISSUE REPORT',
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

  // ─── Grouped Table by Invoice ─────────────────────────────────────────────

  static pw.Widget _buildGroupedTable(
    List<IssueReportDm> data,
    PdfColor headerBgColor,
    PdfColor groupHeaderColor,
    PdfColor textColor,
  ) {
    // Group by invoice number
    final Map<String, List<IssueReportDm>> groupedData = {};
    for (var item in data) {
      groupedData.putIfAbsent(item.invno, () => []).add(item);
    }

    const detailHeaders = [
      'Item Name',
      'Qty',
      'Total Issue Qty',
      'Contractor Name',
      'Issue Date',
      'GRN Date',
      'Head (Godown)',
    ];

    const columnWidths = {
      0: pw.FlexColumnWidth(3.0),
      1: pw.FlexColumnWidth(1.2),
      2: pw.FlexColumnWidth(1.5),
      3: pw.FlexColumnWidth(2.5),
      4: pw.FlexColumnWidth(1.5),
      5: pw.FlexColumnWidth(1.5),
      6: pw.FlexColumnWidth(2.0),
    };

    final List<pw.Widget> widgets = [];

    groupedData.forEach((invNo, items) {
      // ── Group header: Invoice Number ───────────────────────────────────────
      widgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: groupHeaderColor,
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            children: [
              pw.Text(
                'Issue No: ',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1D5B86'),
                ),
              ),
              pw.Text(
                invNo,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ),
      );

      widgets.add(pw.SizedBox(height: 4));

      // ── Detail table ──────────────────────────────────────────────────────
      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          columnWidths: columnWidths,
          children: [
            // Column header row
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

            // Data rows
            ...items.asMap().entries.map((entry) {
              final item = entry.value;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: entry.key.isEven ? PdfColors.white : PdfColors.grey100,
                ),
                children: [
                  _cell(item.iName, textColor),
                  _cell(
                    item.qty.toStringAsFixed(2),
                    textColor,
                    align: pw.TextAlign.right,
                  ),
                  _cell(
                    item.totalIssueQty.toStringAsFixed(2),
                    textColor,
                    align: pw.TextAlign.right,
                  ),
                  _cell(item.pName, textColor),
                  // FIX: API returns 'dd-MM-yyyy', use correct formatter
                  _cell(
                    _formatApiDate(item.issueDate),
                    textColor,
                    align: pw.TextAlign.center,
                  ),
                  _cell(
                    _formatApiDate(item.grnDate),
                    textColor,
                    align: pw.TextAlign.center,
                  ),
                  // FIX: Display gdName correctly
                  _cell(item.gdName, textColor),
                ],
              );
            }),

            // Sub-total row for this invoice
            _buildSubTotalRow(items),
          ],
        ),
      );

      widgets.add(pw.SizedBox(height: 15));
    });

    return pw.Column(children: widgets);
  }

  // ─── Date Formatter ───────────────────────────────────────────────────────
  // API returns dates as 'dd-MM-yyyy' (e.g. "04-06-2026")
  // This safely parses and reformats to 'dd-MM-yyyy' for display.
  // If format ever changes, only this method needs updating.
  static String _formatApiDate(String date) {
    if (date.isEmpty) return '';
    try {
      // API returns 'dd-MM-yyyy' format directly — just return as-is,
      // or parse and reformat to ensure consistency.
      final parsed = DateFormat('dd-MM-yyyy').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsed);
    } catch (_) {
      // Fallback: try 'yyyy-MM-dd' in case format changes
      try {
        final parsed = DateFormat('yyyy-MM-dd').parse(date);
        return DateFormat('dd-MM-yyyy').format(parsed);
      } catch (_) {
        return date; // Return raw if all parsing fails
      }
    }
  }

  // ─── Sub-total row ────────────────────────────────────────────────────────

  static pw.TableRow _buildSubTotalRow(List<IssueReportDm> items) {
    final subQty = items.fold(0.0, (s, i) => s + i.qty);
    final subTotalIssueQty = items.fold(0.0, (s, i) => s + i.totalIssueQty);

    pw.Widget labelCell(String text) => pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );

    pw.Widget emptyCell() =>
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(''));

    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            'Sub Total',
            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
          ),
        ),
        labelCell(subQty.toStringAsFixed(2)), // Qty
        labelCell(subTotalIssueQty.toStringAsFixed(2)), // Total Issue Qty
        emptyCell(), // Party Name
        emptyCell(), // Issue Date
        emptyCell(), // GRN Date
        emptyCell(), // Head
      ],
    );
  }

  // ─── Summary ──────────────────────────────────────────────────────────────

  // static pw.Widget _buildSummary(List<IssueReportDm> data, PdfColor textColor) {
  //   final totalQty = data.fold(0.0, (s, i) => s + i.qty);
  //   final totalIssueQty = data.fold(0.0, (s, i) => s + i.totalIssueQty);
  //   final uniqueInvoices = <String>{};
  //   final uniqueParties = <String>{};
  //   final uniqueGodowns = <String>{};

  //   for (var item in data) {
  //     uniqueInvoices.add(item.invno);
  //     uniqueParties.add(item.pName);
  //     if (item.gdName.isNotEmpty) {
  //       uniqueGodowns.add(item.gdName);
  //     }
  //   }

  //   return pw.Container(
  //     padding: const pw.EdgeInsets.all(10),
  //     decoration: pw.BoxDecoration(
  //       border: pw.Border.all(color: PdfColors.grey, width: 0.5),
  //       borderRadius: pw.BorderRadius.circular(5),
  //     ),
  //     child: pw.Column(
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         pw.Text(
  //           'SUMMARY',
  //           style: pw.TextStyle(
  //             fontSize: 12,
  //             fontWeight: pw.FontWeight.bold,
  //             color: textColor,
  //           ),
  //         ),
  //         pw.SizedBox(height: 8),
  //         pw.Row(
  //           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //           children: [
  //             pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 _summaryRow('Total Qty Issued:', totalQty.toStringAsFixed(2)),
  //                 _summaryRow(
  //                   'Total Issue Qty:',
  //                   totalIssueQty.toStringAsFixed(2),
  //                 ),
  //                 _summaryRow('Total Invoices:', '${uniqueInvoices.length}'),
  //                 _summaryRow('Total Parties:', '${uniqueParties.length}'),
  //               ],
  //             ),
  //             pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 _summaryRow('Total Heads:', '${uniqueGodowns.length}'),
  //                 _summaryRow('Total Items:', '${data.length}'),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  // static pw.Widget _summaryRow(String label, String value, {PdfColor? color}) {
  //   return pw.Row(
  //     children: [
  //       pw.Text(
  //         label,
  //         style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
  //       ),
  //       pw.SizedBox(width: 5),
  //       pw.Text(
  //         value,
  //         style: pw.TextStyle(fontSize: 9, color: color ?? PdfColors.black),
  //       ),
  //     ],
  //   );
  // }

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
        maxLines: 2,
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
          pw.Text('Issue Report', style: const pw.TextStyle(fontSize: 9)),
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

    if (AppScreenUtils.isWeb) {
      final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..target = '_blank'
        ..click();

      Future.delayed(const Duration(seconds: 2), () {
        html.Url.revokeObjectUrl(url);
      });
    } else {
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/IssueReport_$timestamp.pdf');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    }
  }
}
