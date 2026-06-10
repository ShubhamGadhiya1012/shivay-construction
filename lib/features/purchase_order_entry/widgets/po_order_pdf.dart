import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/constants/image_constants.dart';
import 'package:shivay_construction/features/purchase_order_entry/models/order_print_dm.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';

class PoPdfWidget {
  static Future<void> generatePurchaseOrderPdf({
    required OrderPrintDm pdfData,
  }) async {
    final pdf = pw.Document();

    // Read coCode and pick logo accordingly
    final String? coCode = await SecureStorageHelper.read('coCode');
    final String logoAssetPath = coCode == '1'
        ? kImageSCLogo
        : kImageUrbanspaceLogo;

    pw.ImageProvider? logo;
    try {
      final logoData = await rootBundle.load(logoAssetPath);
      logo = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        header: (context) {
          if (context.pageNumber > 1) {
            return pw.Table(
              border: const pw.TableBorder(
                top: pw.BorderSide(color: PdfColors.black, width: 1),
                left: pw.BorderSide(color: PdfColors.black, width: 1),
                right: pw.BorderSide(color: PdfColors.black, width: 1),
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
              columnWidths: {
                0: const pw.FixedColumnWidth(30), // SR NO
                1: const pw.FlexColumnWidth(), // Item Description
                2: const pw.FixedColumnWidth(40), // Unit
                3: const pw.FixedColumnWidth(40), // Qty
                4: const pw.FixedColumnWidth(50), // Rate
                5: const pw.FixedColumnWidth(60), // Amount
                6: const pw.FixedColumnWidth(40), // Disc
                7: const pw.FixedColumnWidth(70), // Net Amount
              },
              children: [_buildTableHeaderRow()],
            );
          }
          return pw.SizedBox();
        },
        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 6),
            ),
          );
        },
        build: (context) => [
          _buildHeader(pdfData, logo),
          _buildInfoGrid(pdfData),
          _buildItemTitleBar(),
          _buildItemTable(pdfData),
          _buildSummarySection(pdfData),
          _buildNotesSection(pdfData),
          _buildFooterInfo(pdfData),
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(
      '${dir.path}/PurchaseOrder_${pdfData.orderHeader.invNo.replaceAll('/', '_')}_$timestamp.pdf',
    );
    await file.writeAsBytes(bytes);
    await OpenFilex.open(file.path);
  }

  static pw.Widget _buildHeader(OrderPrintDm data, pw.ImageProvider? logo) {
    final company = data.companyData;
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    company.name,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    '${company.address1}, ${company.address2}, ${company.city} - ${company.zip}.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'G.S.T.NO : ${company.gstNumber}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Pan NO : ${company.pan}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Email : ${company.email}, ${company.mgmtEmail}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
          pw.Container(width: 1, height: 75, color: PdfColors.black),
          pw.Expanded(
            flex: 1,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: logo != null
                  ? pw.Center(child: pw.Image(logo, height: 80))
                  : pw.SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoGrid(OrderPrintDm data) {
    final h = data.orderHeader;
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.black, width: 1),
          right: pw.BorderSide(color: PdfColors.black, width: 1),
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(1),
          1: const pw.FlexColumnWidth(1),
        },
        border: const pw.TableBorder(
          verticalInside: pw.BorderSide(color: PdfColors.black, width: 1),
          horizontalInside: pw.BorderSide(color: PdfColors.black, width: 0.5),
        ),
        children: [
          pw.TableRow(
            children: [
              _infoCell('Vendor Detail :', isHeader: true),
              _infoCell('PO No :', value: h.invNo, isHeader: true),
            ],
          ),
          pw.TableRow(
            children: [
              _infoCell(
                'Adress :',
                value: '${h.pAdd1} ${h.pAdd2} ${h.pCity} ${h.pState}',
              ),
              _infoCell('Ship To :', isHeader: true),
            ],
          ),
          pw.TableRow(
            children: [
              _infoCell('Contact person :', value: h.pContactPerson),
              _infoCell('', value: data.companyData.name, isBold: true),
            ],
          ),
          pw.TableRow(
            children: [
              _infoCell('Phone No. :', value: '${h.pPhone} ${h.pMobile}'),
              _infoCell(
                'Site Adress :',
                value:
                    '${h.sAdd1} ${h.sAdd2} ${h.sCity} ${h.sState} ${h.sPinCode}',
              ),
            ],
          ),
          pw.TableRow(
            children: [
              _infoCell('E-Mail :', value: h.pEmail),
              _infoCell('Contact Person :', value: ''),
            ],
          ),
          pw.TableRow(
            children: [
              _infoCell('G.S.T. NO :', value: h.pGst),
              _infoCell('Contact No :', value: h.phone),
            ],
          ),
          pw.TableRow(
            children: [
              _infoCell('PAN NO :', value: h.pPan),
              _infoCell('Date :', value: h.date),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 2,
                ),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 65,
                      child: pw.Text(
                        'Region :',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        '',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'Region name :',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      child: pw.Text(
                        '',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ],
                ),
              ),
              _infoCell('', value: ''),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoCell(
    String label, {
    String value = '',
    bool isHeader = false,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            pw.SizedBox(
              width: 65,
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: (isBold || isHeader)
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemTitleBar() {
    return pw.Container(
      width: double.infinity,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.black, width: 1),
          right: pw.BorderSide(color: PdfColors.black, width: 1),
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: pw.Center(
        child: pw.Text(
          'Purchase Order',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ),
    );
  }

  static pw.Widget _buildItemTable(OrderPrintDm data) {
    return pw.Table(
      border: const pw.TableBorder(
        left: pw.BorderSide(color: PdfColors.black, width: 1),
        right: pw.BorderSide(color: PdfColors.black, width: 1),
        bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        horizontalInside: pw.BorderSide(color: PdfColors.black, width: 0.5),
        verticalInside: pw.BorderSide(color: PdfColors.black, width: 0.5),
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // SR NO
        1: const pw.FlexColumnWidth(), // Item Description
        2: const pw.FixedColumnWidth(40), // Unit
        3: const pw.FixedColumnWidth(40), // Qty
        4: const pw.FixedColumnWidth(50), // Rate
        5: const pw.FixedColumnWidth(60), // Amount
        6: const pw.FixedColumnWidth(40), // Disc
        7: const pw.FixedColumnWidth(70), // Net Amount
      },
      children: [
        _buildTableHeaderRow(),
        ...data.items.asMap().entries.map((e) {
          final i = e.value;
          return pw.TableRow(
            children: [
              _cell((e.key + 1).toString(), align: pw.TextAlign.center),
              _cell(i.iName),
              _cell(i.unit, align: pw.TextAlign.center),
              _cell(i.qty.toStringAsFixed(2), align: pw.TextAlign.right),
              _cell(i.rate.toStringAsFixed(2), align: pw.TextAlign.right),
              _cell(i.amount.toStringAsFixed(2), align: pw.TextAlign.right),
              _cell(i.discA.toStringAsFixed(2), align: pw.TextAlign.right),
              _cell(
                i.gstNetAmount.toStringAsFixed(2),
                align: pw.TextAlign.right,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.TableRow _buildTableHeaderRow() {
    return pw.TableRow(
      children: [
        _headerCell('SR NO'),
        _headerCell('Item Description'),
        _headerCell('Unit'),
        _headerCell('Qty'),
        _headerCell('Rate'),
        _headerCell('Amount'),
        _headerCell('Disc'),
        _headerCell('Net Amount'),
      ],
    );
  }

  static pw.Widget _headerCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      textAlign: pw.TextAlign.center,
    ),
  );

  static pw.Widget _cell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
    child: pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 7),
      textAlign: align,
    ),
  );

  static pw.Widget _buildSummarySection(OrderPrintDm data) {
    final s = data.summary;
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.black, width: 1),
          left: pw.BorderSide(color: PdfColors.black, width: 1),
          right: pw.BorderSide(color: PdfColors.black, width: 1),
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Spacer(),
              pw.Container(
                width: 220,
                child: pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FixedColumnWidth(70),
                  },
                  border: const pw.TableBorder(
                    left: pw.BorderSide(color: PdfColors.black, width: 0.5),
                  ),
                  children: [
                    ...s
                        .where((row) => row.amount != 0)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final row = entry.value;
                          final isLast =
                              index == s.where((r) => r.amount != 0).length - 1;

                          String desc = row.description;
                          if (!desc.contains('@') && !desc.contains('%')) {
                            if (desc.toUpperCase().contains('CGST') &&
                                data.items.isNotEmpty) {
                              desc += ' ${data.items.first.cgstPerc}%';
                            } else if (desc.toUpperCase().contains('SGST') &&
                                data.items.isNotEmpty) {
                              desc += ' ${data.items.first.sgstPerc}%';
                            } else if (desc.toUpperCase().contains('IGST') &&
                                data.items.isNotEmpty) {
                              desc += ' ${data.items.first.igstPerc}%';
                            }
                          }
                          return _summaryTableRow(
                            desc,
                            row.amount,
                            isBold: isLast,
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Row(
              children: [
                pw.Text(
                  'Words : ',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    _numberToWords(data.orderHeader.amount),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.TableRow _summaryTableRow(
    String label,
    double amount, {
    bool isBold = false,
  }) {
    final double fSize = isBold ? 10 : 8;
    final double vPad = isBold ? 6 : 4;
    return pw.TableRow(
      children: [
        pw.Container(
          padding: pw.EdgeInsets.symmetric(vertical: vPad, horizontal: 2),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
            ),
          ),
          child: pw.Text(
            label.isEmpty ? (isBold ? 'Grand Total' : 'Total') : label,
            style: pw.TextStyle(
              fontSize: fSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.symmetric(vertical: vPad, horizontal: 2),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
            ),
          ),
          child: pw.Text(
            amount == 0 ? '-' : amount.toStringAsFixed(2),
            style: pw.TextStyle(
              fontSize: fSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildNotesSection(OrderPrintDm data) {
    return pw.Container(
      width: double.infinity,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.black, width: 1),
          left: pw.BorderSide(color: PdfColors.black, width: 1),
          right: pw.BorderSide(color: PdfColors.black, width: 1),
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      padding: const pw.EdgeInsets.all(5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Please Submit Only Tax Invoice',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Terms & Condition:',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          ...data.notes.asMap().entries.map(
            (e) => pw.Text(
              '${e.key + 1}. ${e.value.description}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooterInfo(OrderPrintDm pdfData) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.black, width: 1),
          right: pw.BorderSide(color: PdfColors.black, width: 1),
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
        color: PdfColors.grey200,
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Site Adress : ${pdfData.orderHeader.sAdd1}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.red,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Contact Person : ${pdfData.orderHeader.pContactPerson}',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Contact No : ${pdfData.orderHeader.phone}',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static String _numberToWords(double amount) {
    if (amount == 0) return 'Rupees Zero Only';

    final int wholePart = amount.toInt();
    final int fractionalPart = ((amount - wholePart) * 100).round();

    String result = _convert(wholePart);
    if (result.isNotEmpty) {
      result = 'Rupees $result';
    }

    if (fractionalPart > 0) {
      if (result.isNotEmpty) result += ' and ';
      result += '${_convert(fractionalPart)} Paise';
    }

    return '$result Only';
  }

  static String _convert(int n) {
    if (n == 0) return '';

    final units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    if (n < 20) return units[n];
    if (n < 100) return '${tens[n ~/ 10]} ${units[n % 10]}'.trim();
    if (n < 1000)
      return '${units[n ~/ 100]} Hundred ${_convert(n % 100)}'.trim();
    if (n < 100000)
      return '${_convert(n ~/ 1000)} Thousand ${_convert(n % 1000)}'.trim();
    if (n < 10000000)
      return '${_convert(n ~/ 100000)} Lakh ${_convert(n % 100000)}'.trim();
    return '${_convert(n ~/ 10000000)} Crore ${_convert(n % 10000000)}'.trim();
  }
}
