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
            reportType == 'PartyWise'
                ? _buildPartyWiseGroupedTable(
                    reportData,
                    tableHeaderColor,
                    groupHeaderColor,
                    textColor,
                  )
                : _buildItemWiseGroupedTable(
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

  // ─── Header ───────────────────────────────────────────────────────────────

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
                'PURCHASE ORDER REPORT - $reportType',
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

  // ─── Party Wise ───────────────────────────────────────────────────────────

  static pw.Widget _buildPartyWiseGroupedTable(
    List<PurchaseOrderReportDm> data,
    PdfColor headerBgColor,
    PdfColor groupHeaderColor,
    PdfColor textColor,
  ) {
    // Group by party code, preserving insertion order
    final Map<String, List<PurchaseOrderReportDm>> groupedData = {};
    for (var item in data) {
      groupedData.putIfAbsent(item.pCode, () => []).add(item);
    }

    const detailHeaders = [
      'PO No',
      'PO Date',
      'Item Name',
      'Unit',
      'PO Qty',
      'Received Qty',
      'Pending Qty',
      'Rate',
      'Amount',
      'Site Name',
      'Req Date',
      'Status',
      'Authorized',
    ];

    const columnWidths = {
      0: pw.FlexColumnWidth(2.0),
      1: pw.FlexColumnWidth(1.5),
      2: pw.FlexColumnWidth(3.0),
      3: pw.FlexColumnWidth(1.0),
      4: pw.FlexColumnWidth(1.2),
      5: pw.FlexColumnWidth(1.2),
      6: pw.FlexColumnWidth(1.2),
      7: pw.FlexColumnWidth(1.2),
      8: pw.FlexColumnWidth(1.5),
      9: pw.FlexColumnWidth(2.0),
      10: pw.FlexColumnWidth(1.5),
      11: pw.FlexColumnWidth(1.2),
      12: pw.FlexColumnWidth(1.2),
    };

    final List<pw.Widget> widgets = [];

    groupedData.forEach((partyCode, items) {
      final partyName = items.first.partyName;

      // ── Group header: Party Name ──────────────────────────────────────────
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
                'Party: ',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1D5B86'),
                ),
              ),
              pw.Text(
                partyName,
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
                  _cell(
                    item.reqDate.isNotEmpty
                        ? convertyyyyMMddToddMMyyyy(item.reqDate)
                        : '-',
                    textColor,
                    align: pw.TextAlign.center,
                  ),
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

            // Sub-total row for this party
            _buildSubTotalRow(items, columnWidths.length),
          ],
        ),
      );

      widgets.add(pw.SizedBox(height: 15));
    });

    return pw.Column(children: widgets);
  }

  // ─── Item Wise ────────────────────────────────────────────────────────────

  static pw.Widget _buildItemWiseGroupedTable(
    List<PurchaseOrderReportDm> data,
    PdfColor headerBgColor,
    PdfColor groupHeaderColor,
    PdfColor textColor,
  ) {
    // Group by item code, preserving insertion order
    final Map<String, List<PurchaseOrderReportDm>> groupedData = {};
    for (var item in data) {
      groupedData.putIfAbsent(item.iCode, () => []).add(item);
    }

    const detailHeaders = [
      'PO No',
      'PO Date',
      'Party Name',
      'Unit',
      'PO Qty',
      'Received Qty',
      'Pending Qty',
      'Rate',
      'Amount',
      'Site Name',
      'Req Date',
      'Status',
      'Authorized',
    ];

    const columnWidths = {
      0: pw.FlexColumnWidth(2.0),
      1: pw.FlexColumnWidth(1.5),
      2: pw.FlexColumnWidth(2.5),
      3: pw.FlexColumnWidth(1.0),
      4: pw.FlexColumnWidth(1.2),
      5: pw.FlexColumnWidth(1.2),
      6: pw.FlexColumnWidth(1.2),
      7: pw.FlexColumnWidth(1.2),
      8: pw.FlexColumnWidth(1.5),
      9: pw.FlexColumnWidth(2.0),
      10: pw.FlexColumnWidth(1.5),
      11: pw.FlexColumnWidth(1.2),
      12: pw.FlexColumnWidth(1.2),
    };

    final List<pw.Widget> widgets = [];

    groupedData.forEach((itemCode, items) {
      final itemName = items.first.iName;
      final unit = items.first.unit;

      // ── Group header: Item Name ───────────────────────────────────────────
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
                'Item: ',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1D5B86'),
                ),
              ),
              pw.Text(
                itemName,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Text(
                'Unit: ',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1D5B86'),
                ),
              ),
              pw.Text(unit, style: const pw.TextStyle(fontSize: 10)),
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
                  _cell(item.poNo, textColor),
                  _cell(
                    convertyyyyMMddToddMMyyyy(item.poDate),
                    textColor,
                    align: pw.TextAlign.center,
                  ),
                  _cell(item.partyName, textColor),
                  _cell(item.unit, textColor, align: pw.TextAlign.center),
                  _cell(
                    item.poQty.toStringAsFixed(2),
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
                  _cell(
                    item.reqDate.isNotEmpty
                        ? convertyyyyMMddToddMMyyyy(item.reqDate)
                        : '-',
                    textColor,
                    align: pw.TextAlign.center,
                  ),
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

            // Sub-total row for this item
            _buildSubTotalRow(items, columnWidths.length),
          ],
        ),
      );

      widgets.add(pw.SizedBox(height: 15));
    });

    return pw.Column(children: widgets);
  }

  // ─── Sub-total row (shared by both views) ─────────────────────────────────

  static pw.TableRow _buildSubTotalRow(
    List<PurchaseOrderReportDm> items,
    int totalColumns,
  ) {
    final subPoQty = items.fold(0.0, (s, i) => s + i.poQty);
    final subReceived = items.fold(0.0, (s, i) => s + i.receivedQty);
    final subPending = items.fold(0.0, (s, i) => s + i.pendingQty);
    final subAmount = items.fold(0.0, (s, i) => s + i.amount);

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
      children: [
        // Col 0: PO No  → "Sub Total"
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            'Sub Total',
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
        emptyCell(), // PO Date
        emptyCell(), // Item/Party Name
        emptyCell(), // Unit
        labelCell(subPoQty.toStringAsFixed(2)), // PO Qty
        labelCell(subReceived.toStringAsFixed(2)), // Received Qty
        labelCell(subPending.toStringAsFixed(2)), // Pending Qty
        emptyCell(), // Rate
        labelCell(subAmount.toStringAsFixed(2)), // Amount
        emptyCell(), // Site Name
        emptyCell(), // Req Date
        emptyCell(), // Status
        emptyCell(), // Authorized
      ],
    );
  }

  // ─── Summary ──────────────────────────────────────────────────────────────

  static pw.Widget _buildSummary(
    List<PurchaseOrderReportDm> data,
    PdfColor textColor,
  ) {
    final totalPOQty = data.fold(0.0, (s, i) => s + i.poQty);
    final totalReceivedQty = data.fold(0.0, (s, i) => s + i.receivedQty);
    final totalPendingQty = data.fold(0.0, (s, i) => s + i.pendingQty);
    final totalAmount = data.fold(0.0, (s, i) => s + i.amount);

    final statusCounts = <String, int>{};
    for (var item in data) {
      statusCounts[item.poStatus] = (statusCounts[item.poStatus] ?? 0) + 1;
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
                  _summaryRow('Total PO Qty:', totalPOQty.toStringAsFixed(2)),
                  _summaryRow(
                    'Total Received Qty:',
                    totalReceivedQty.toStringAsFixed(2),
                  ),
                  _summaryRow(
                    'Total Pending Qty:',
                    totalPendingQty.toStringAsFixed(2),
                  ),
                  _summaryRow('Total Amount:', totalAmount.toStringAsFixed(2)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: statusCounts.entries.map((entry) {
                  return _summaryRow(
                    '${entry.key} POs:',
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

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
      case 'partial':
        return PdfColors.blue;
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
          pw.Text(
            'Purchase Order Report',
            style: const pw.TextStyle(fontSize: 9),
          ),
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
    final file = File(
      '${dir.path}/PurchaseOrder_Report_${reportType}_$timestamp.pdf',
    );
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }
}
