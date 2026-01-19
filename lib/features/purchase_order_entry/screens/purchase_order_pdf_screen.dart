import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_detail_dm.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/purchase_order_list_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';

class PurchaseOrderPdfScreen {
  static Future<void> generatePurchaseOrderPdf({
    required PurchaseOrderListDm order,
    required List<PurchaseOrderDetailDm> orderDetails,
  }) async {
    try {
      if (orderDetails.isEmpty) {
        showErrorSnackbar('Error', 'No order data found to generate PDF.');
        return;
      }

      final pdf = pw.Document();

      final primaryColor = PdfColor.fromHex('#ADD8E6');
      final titleColor = PdfColor.fromHex('#1D5B86');
      final textPrimaryColor = PdfColor.fromHex('#363636');

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(20),
          header: (context) =>
              _buildHeader(titleColor, textPrimaryColor, order),
          build: (context) => [
            pw.SizedBox(height: 15),
            _buildOrderTable(
              orderDetails,
              primaryColor,
              titleColor,
              textPrimaryColor,
            ),
          ],
        ),
      );

      await _savePdf(pdf, order.invNo);
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Purchase Order PDF: $e');
    //  print(e);
    }
  }

  static pw.Widget _buildHeader(
    PdfColor titleColor,
    PdfColor textPrimaryColor,
    PurchaseOrderListDm order,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: titleColor, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PURCHASE ORDER REPORT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'PO No: ${order.invNo}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'DATE: ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: textPrimaryColor),
                  ),
                  pw.Text(
                    'TIME: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: textPrimaryColor),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PO Date: ${convertyyyyMMddToddMMyyyy(order.date)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: textPrimaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Party: ${order.pName}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: textPrimaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Godown: ${order.gdName}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Site: ${order.siteName}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: textPrimaryColor,
                      ),
                    ),
                    if (order.remarks.isNotEmpty) ...[
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Remarks: ${order.remarks}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: textPrimaryColor,
                        ),
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ],
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Status: ${order.authorize ? "Authorized" : "Pending"}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: order.authorize
                            ? PdfColor.fromHex('#4CAF50')
                            : PdfColor.fromHex('#FF9800'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderTable(
    List<PurchaseOrderDetailDm> orderDetails,
    PdfColor primaryColor,
    PdfColor titleColor,
    PdfColor textPrimaryColor,
  ) {
    final headers = ['Sr.', 'Item Name', 'Indent No', 'Unit', 'Order Qty'];

    // Flatten the structure to create rows
    final List<List<String>> rows = [];
    int srNo = 1;

    for (var item in orderDetails) {
      for (var indent in item.indents) {
        rows.add([
          srNo.toString(),
          item.iName,
          indent.indentInvNo,
          indent.unit,
          indent.orderQty.toStringAsFixed(2),
        ]);
        srNo++;
      }
    }

    final columnWidths = {
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(4),
      2: const pw.FlexColumnWidth(2.5),
      3: const pw.FlexColumnWidth(1.5),
      4: const pw.FlexColumnWidth(2),
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primaryColor),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                      color: titleColor,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
        // Data rows
        ...rows.map(
          (r) => pw.TableRow(
            children: r
                .asMap()
                .entries
                .map(
                  (entry) => pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      entry.value,
                      style: pw.TextStyle(fontSize: 9, color: textPrimaryColor),
                      textAlign: entry.key == 0
                          ? pw.TextAlign.center
                          : pw.TextAlign.left,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String invNo) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final cleanInvNo = invNo.replaceAll('/', '_').replaceAll('\\', '_');

    final file = File('${dir.path}/PurchaseOrder_${cleanInvNo}_$timestamp.pdf');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }
}
