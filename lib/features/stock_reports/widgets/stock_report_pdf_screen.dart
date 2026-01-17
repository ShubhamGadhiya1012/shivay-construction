import 'dart:io';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/stock_reports/models/stock_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:universal_html/html.dart' as html;

class StockReportPdfScreen {
  static Future<void> generateStockReportPdf({
    required List<StockReportDm> reportData,
    required String reportTitle,
    required String reportName,
    required String fromDate,
    required String toDate,
    StockReportDm? grandTotal,
    StockReportDm? openingStock,
    StockReportDm? closingStock,
  }) async {
    if (reportData.isEmpty && openingStock == null && closingStock == null) {
      showErrorSnackbar("Error", "No data available to generate PDF");
      return;
    }

    try {
      final pdf = pw.Document();
      final primaryColor = PdfColor.fromHex('#0A1F44');
      final secondaryColor = PdfColor.fromHex('#FFA726');
      final lightYellow = PdfColor.fromHex('#D3D3D3');
      final lightBlue = PdfColor.fromHex('#E3F2FD');

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(10),
          pageFormat: PdfPageFormat.a4.landscape,
          maxPages: 1000,
          build: (context) {
            final widgets = <pw.Widget>[];

            // Header
            widgets.add(
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    reportTitle,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 10));
            widgets.add(
              pw.Text(
                'Period: $fromDate to $toDate',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));

            // Opening Stock for Ledger
            if (openingStock != null && reportName == 'LEDGER') {
              widgets.add(
                _buildOpeningClosingTable(
                  'OPENING STOCK',
                  openingStock,
                  primaryColor,
                  lightBlue,
                ),
              );
              widgets.add(pw.SizedBox(height: 15));
            }

            // Main Report Table
            if (reportData.isNotEmpty) {
              widgets.add(
                _buildReportTable(reportData, reportName, primaryColor),
              );
              widgets.add(pw.SizedBox(height: 15));
            }

            // Closing Stock for Ledger
            if (closingStock != null && reportName == 'LEDGER') {
              widgets.add(
                _buildOpeningClosingTable(
                  'CLOSING STOCK',
                  closingStock,
                  secondaryColor,
                  lightYellow,
                ),
              );
            }

            // Grand Total for other reports
            if (grandTotal != null && reportName != 'LEDGER') {
              widgets.add(
                _buildGrandTotalTable(
                  grandTotal,
                  reportName,
                  secondaryColor,
                  lightYellow,
                ),
              );
            }

            return widgets;
          },
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            padding: const pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Text(
              "Page ${context.pageNumber} of ${context.pagesCount}",
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      final bytes = await pdf.save();
      await _savePdfAndOpen(bytes, reportTitle.replaceAll(' ', '_'));
    } catch (e) {
      showErrorSnackbar("Error", "Failed to generate PDF: ${e.toString()}");
    }
  }

  static pw.Widget _buildOpeningClosingTable(
    String title,
    StockReportDm data,
    PdfColor headerColor,
    PdfColor rowColor,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: [
            _buildHeaderCell(title),
            _buildHeaderCell('Receipt Qty'),
            _buildHeaderCell('Issue Qty'),
            _buildHeaderCell('Balance Qty'),
          ],
        ),
        pw.TableRow(
          decoration: pw.BoxDecoration(color: rowColor),
          children: [
            _buildDataCell(data.desc ?? ''),
            _buildDataCell((data.receiptQty ?? 0).toStringAsFixed(2)),
            _buildDataCell((data.issueQty ?? 0).toStringAsFixed(2)),
            _buildDataCell((data.balanceQty ?? 0).toStringAsFixed(2)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildReportTable(
    List<StockReportDm> reportData,
    String reportName,
    PdfColor primaryColor,
  ) {
    List<String> headers;
    List<List<String>> rows;

    switch (reportName) {
      case 'STATEMENT':
        headers = [
          'Item Name',
          'Unit',
          'Group',
          'Open Qty',
          'In Qty',
          'Out Qty',
          'Close Qty',
        ];
        rows = reportData
            .map(
              (item) => [
                item.iName ?? '',
                item.unit ?? '',
                item.igName ?? '',
                (item.openQty ?? 0).toStringAsFixed(2),
                (item.inQty ?? 0).toStringAsFixed(2),
                (item.outQty ?? 0).toStringAsFixed(2),
                (item.closeQty ?? 0).toStringAsFixed(2),
              ],
            )
            .toList();
        break;

      case 'FIFO':
      case 'LIFO':
      case 'LP':
        headers = ['Item Name', 'Unit', 'Close Qty', 'Rate', 'Close Value'];
        rows = reportData
            .map(
              (item) => [
                item.iName ?? '',
                item.unit ?? '',
                (item.closeQty ?? 0).toStringAsFixed(2),
                (item.rate ?? 0).toStringAsFixed(2),
                (item.closeValue ?? 0).toStringAsFixed(2),
              ],
            )
            .toList();
        break;

      case 'LEDGER':
        headers = [
          'Date',
          'Site',
          'Godown',
          'Inv No',
          'DBC',
          'Party',
          'Receipt',
          'Issue',
        ];
        rows = reportData
            .map(
              (item) => [
                item.date ?? '',
                item.siteName ?? '',
                item.gdName ?? '',
                item.invNo ?? '',
                item.dbc ?? '',
                item.pName ?? '',
                (item.receiptQty ?? 0).toStringAsFixed(2),
                (item.issueQty ?? 0).toStringAsFixed(2),
              ],
            )
            .toList();
        break;

      case 'GROUPSTOCK':
        headers = [
          'Group',
          'Item Name',
          'Unit',
          'Open Qty',
          'In Qty',
          'Out Qty',
          'Close Qty',
          'Rate',
          'Close Value',
        ];
        rows = reportData
            .map(
              (item) => [
                item.igName ?? '',
                item.iName ?? '',
                item.unit ?? '',
                (item.openQty ?? 0).toStringAsFixed(2),
                (item.inQty ?? 0).toStringAsFixed(2),
                (item.outQty ?? 0).toStringAsFixed(2),
                (item.closeQty ?? 0).toStringAsFixed(2),
                (item.rate ?? 0).toStringAsFixed(2),
                (item.closeValue ?? 0).toStringAsFixed(2),
              ],
            )
            .toList();
        break;
      case 'SITESTOCK':
        headers = ['Site', 'Godown', 'Item Name', 'Unit', 'Stock Qty'];
        rows = reportData
            .map(
              (item) => [
                item.siteName ?? '',
                item.gdName ?? '',
                item.iName ?? '',
                item.unit ?? '',
                (item.stockQty ?? 0).toStringAsFixed(2),
              ],
            )
            .toList();
        break;

      default:
        headers = ['Item Name'];
        rows = [
          ['No Data'],
        ];
    }

    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerDecoration: pw.BoxDecoration(color: primaryColor),
      headerHeight: 28,
      cellHeight: 22,
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      headers: headers,
      data: rows,
    );
  }

  static pw.Widget _buildGrandTotalTable(
    StockReportDm grandTotal,
    String reportName,
    PdfColor headerColor,
    PdfColor rowColor,
  ) {
    List<String> headers;
    List<String> values;

    if (reportName == 'STATEMENT') {
      headers = ['GRAND TOTAL', 'Open Qty', 'In Qty', 'Out Qty', 'Close Qty'];
      values = [
        'Total',
        (grandTotal.openQty ?? 0).toStringAsFixed(2),
        (grandTotal.inQty ?? 0).toStringAsFixed(2),
        (grandTotal.outQty ?? 0).toStringAsFixed(2),
        (grandTotal.closeQty ?? 0).toStringAsFixed(2),
      ];
    } else if (reportName == 'GROUPSTOCK') {
      headers = [
        'GRAND TOTAL',
        'Open Qty',
        'In Qty',
        'Out Qty',
        'Close Qty',
        'Close Value',
      ];
      values = [
        'Total',
        (grandTotal.openQty ?? 0).toStringAsFixed(2),
        (grandTotal.inQty ?? 0).toStringAsFixed(2),
        (grandTotal.outQty ?? 0).toStringAsFixed(2),
        (grandTotal.closeQty ?? 0).toStringAsFixed(2),
        (grandTotal.closeValue ?? 0).toStringAsFixed(2),
      ];
    } else {
      headers = ['GRAND TOTAL', 'Close Qty', 'Close Value'];
      values = [
        'Total',
        (grandTotal.closeQty ?? 0).toStringAsFixed(2),
        (grandTotal.closeValue ?? 0).toStringAsFixed(2),
      ];
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: headers.map((h) => _buildHeaderCell(h)).toList(),
        ),
        pw.TableRow(
          decoration: pw.BoxDecoration(color: rowColor),
          children: values.map((v) => _buildDataCell(v, true)).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildDataCell(String text, [bool bold = false]) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static Future<void> _savePdfAndOpen(
    List<int> pdfBytes,
    String fileName,
  ) async {
    try {
      if (AppScreenUtils.isWeb) {
        final blob = html.Blob([
          Uint8List.fromList(pdfBytes),
        ], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.AnchorElement(href: url)
          ..target = '_blank'
          ..click();

        Future.delayed(const Duration(seconds: 2), () {
          html.Url.revokeObjectUrl(url);
        });
      } else {
        final sanitizedFileName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '_');
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath =
            '${directory.path}/${sanitizedFileName}_$timestamp.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes, flush: true);
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      showErrorSnackbar(
        'Error',
        'Failed to save and open PDF: ${e.toString()}',
      );
    }
  }
}
