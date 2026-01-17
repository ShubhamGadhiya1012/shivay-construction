import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/indent_entry/models/indent_dm.dart';
import 'package:shivay_construction/features/indent_entry/models/indent_detail_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/date_format_helper.dart';

class IndentPdfScreen {
  static Future<void> generateIndentPdf({
    required IndentDm indent,
    required List<IndentDetailDm> indentDetails,
  }) async {
    try {
      if (indentDetails.isEmpty) {
        showErrorSnackbar('Error', 'No indent data found to generate PDF.');
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
              _buildHeader(titleColor, textPrimaryColor, indent),
          build: (context) => [
            pw.SizedBox(height: 15),
            _buildIndentTable(
              indentDetails,
              primaryColor,
              titleColor,
              textPrimaryColor,
              indent.authorize,
            ),
          ],
        ),
      );

      await _savePdf(pdf, indent.invNo);
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Indent PDF: $e');
      print(e);
    }
  }

  static pw.Widget _buildHeader(
    PdfColor titleColor,
    PdfColor textPrimaryColor,
    IndentDm indent,
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
                    'INDENT REPORT',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Indent No: ${indent.invNo}',
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
                      'Indent Date: ${convertyyyyMMddToddMMyyyy(indent.date)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: textPrimaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Godown: ${indent.gdName}',
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
                      'Site: ${indent.siteName}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: textPrimaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Status: ${indent.authorize
                          ? "Authorized"
                          : indent.closeIndent
                          ? "Closed"
                          : "Pending"}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: indent.authorize
                            ? PdfColor.fromHex('#4CAF50')
                            : indent.closeIndent
                            ? PdfColor.fromHex('#F44336')
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

  static pw.Widget _buildIndentTable(
    List<IndentDetailDm> indentDetails,
    PdfColor primaryColor,
    PdfColor titleColor,
    PdfColor textPrimaryColor,
    bool isAuthorized,
  ) {
    final headers = isAuthorized
        ? ['Sr.', 'Item Name', 'Unit', 'Indent Qty', 'Auth. Qty', 'Req. Date']
        : ['Sr.', 'Item Name', 'Unit', 'Indent Qty', 'Req. Date'];

    final rows = indentDetails.map((item) {
      final baseRow = [
        item.srNo.toString(),
        item.iName,
        item.unit,
        item.indentQty.toStringAsFixed(2),
      ];

      if (isAuthorized) {
        baseRow.add(item.authorizedQty.toStringAsFixed(2));
      }

      baseRow.add(convertyyyyMMddToddMMyyyy(item.reqDate));

      return baseRow;
    }).toList();

    final columnWidths = isAuthorized
        ? {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(4),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(2),
            5: const pw.FlexColumnWidth(2),
          }
        : {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(4),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(2),
          };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: columnWidths,
      children: [
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

    final file = File('${dir.path}/Indent_${cleanInvNo}_$timestamp.pdf');
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }
}
