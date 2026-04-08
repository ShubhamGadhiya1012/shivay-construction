import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/grn_entry/models/grn_detail_dm.dart';
import 'package:shivay_construction/features/grn_entry/models/grn_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';

class GrnPdfScreen {
  static Future<void> generateGrnPdf({
    required GrnDm grn,
    required List<GrnDetailDm> grnDetails,
  }) async {
    try {
      if (grnDetails.isEmpty) {
        showErrorSnackbar('Error', 'No GRN data found to generate PDF.');
        return;
      }
      final pdf = pw.Document();
      final primaryColor = PdfColor.fromHex('#ADD8E6');
      final titleColor = PdfColor.fromHex('#1D5B86');
      final textPrimaryColor = PdfColor.fromHex('#363636');

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(20),
          header: (context) => _buildHeader(titleColor, textPrimaryColor, grn),
          build: (context) => [
            pw.SizedBox(height: 15),
            _buildGrnTable(
              grnDetails,
              primaryColor,
              titleColor,
              textPrimaryColor,
              grn.type == 'Direct',
            ),
          ],
        ),
      );

      await _savePdf(pdf, grn.invNo);
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate GRN PDF: $e');
    }
  }

  static pw.Widget _buildHeader(
    PdfColor titleColor,
    PdfColor textPrimaryColor,
    GrnDm grn,
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
                    'GRN REPORT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'GRN No: ${grn.invNo}',
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
                      'GRN Date: ${convertyyyyMMddToddMMyyyy(grn.date)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: textPrimaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Party: ${grn.pName}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: textPrimaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Godown: ${grn.gdName}',
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
                      'Site: ${grn.siteName}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: textPrimaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Type: ${grn.type} GRN',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: grn.type == 'Direct'
                            ? PdfColor.fromHex('#FF6B35')
                            : titleColor,
                      ),
                    ),
                    if (grn.remarks.isNotEmpty) ...[
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Remarks: ${grn.remarks}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: textPrimaryColor,
                        ),
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildGrnTable(
    List<GrnDetailDm> grnDetails,
    PdfColor primaryColor,
    PdfColor titleColor,
    PdfColor textPrimaryColor,
    bool isDirectGrn,
  ) {
    // ── Direct GRN: Sr | Item Name | Unit | Rate | Qty | Amount
    // ── Against PO: Sr | Item Name | PO No | Head | Remark | Unit | Qty
    final headers = isDirectGrn
        ? ['Sr.', 'Item Name', 'Unit', 'Rate', 'Quantity', 'Amount']
        : ['Sr.', 'Item Name', 'PO No', 'Head', 'Remark', 'Unit', 'Qty'];

    final List<List<String>> rows = [];
    int srNo = 1;
    double grandTotal = 0;

    for (var detail in grnDetails) {
      if (isDirectGrn) {
        final amount = detail.qty * detail.rate;
        grandTotal += amount;
        rows.add([
          srNo.toString(),
          detail.iName,
          detail.unit,
          detail.rate.toStringAsFixed(2),
          detail.qty.toStringAsFixed(2),
          amount.toStringAsFixed(2),
        ]);
      } else {
        rows.add([
          srNo.toString(),
          detail.iName,
          detail.poInvNo,
          detail.gdName, // Head
          detail.poRemark, // Remark
          detail.unit,
          detail.qty.toStringAsFixed(2),
        ]);
      }
      srNo++;
    }

    // Column widths
    final columnWidths = isDirectGrn
        ? {
            0: const pw.FlexColumnWidth(1), // Sr
            1: const pw.FlexColumnWidth(4), // Item Name
            2: const pw.FlexColumnWidth(1.5), // Unit
            3: const pw.FlexColumnWidth(2), // Rate
            4: const pw.FlexColumnWidth(2), // Qty
            5: const pw.FlexColumnWidth(2), // Amount
          }
        : {
            0: const pw.FlexColumnWidth(0.8), // Sr
            1: const pw.FlexColumnWidth(3.5), // Item Name
            2: const pw.FlexColumnWidth(2), // PO No
            3: const pw.FlexColumnWidth(2), // Head
            4: const pw.FlexColumnWidth(2.5), // Remark
            5: const pw.FlexColumnWidth(1.2), // Unit
            6: const pw.FlexColumnWidth(1.5), // Qty
          };

    // Right-align numeric columns
    pw.TextAlign align(bool isDirect, int colIndex) {
      if (isDirect) {
        return colIndex == 0
            ? pw.TextAlign.center
            : (colIndex >= 3)
            ? pw.TextAlign.right
            : pw.TextAlign.left;
      }
      // Against PO: right-align qty (col 6)
      return colIndex == 0
          ? pw.TextAlign.center
          : colIndex == 6
          ? pw.TextAlign.right
          : pw.TextAlign.left;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Table(
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
                          fontSize: 9,
                          color: titleColor,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),

            // Data rows
            ...rows.asMap().entries.map(
              (rowEntry) => pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: rowEntry.key.isOdd
                      ? PdfColor.fromHex('#F5F9FF')
                      : PdfColors.white,
                ),
                children: rowEntry.value
                    .asMap()
                    .entries
                    .map(
                      (cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          cell.value,
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            color: textPrimaryColor,
                          ),
                          textAlign: align(isDirectGrn, cell.key),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),

        // Grand total for Direct GRN
        if (isDirectGrn) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Grand Total: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: titleColor,
                  ),
                ),
                pw.Text(
                  grandTotal.toStringAsFixed(2),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String invNo) async {
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanInvNo = invNo.replaceAll('/', '_').replaceAll('\\', '_');
    final file = File('${dir.path}/GRN_${cleanInvNo}_$timestamp.pdf');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }
}
