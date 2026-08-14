import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shivay_construction/features/reports/models/dlr_report_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/constants/image_constants.dart';

class _ActivityTotals {
  double daySkill = 0;
  double dayUnSkill = 0;
  double nightSkill = 0;
  double nightUnSkill = 0;

  double get dayTotal => daySkill + dayUnSkill;
  double get nightTotal => nightSkill + nightUnSkill;
  double get grandTotal => dayTotal + nightTotal;
}

class DlrReportPdfScreen {
  static Map<int, pw.TableColumnWidth> _mainTableColumnWidths() => {
    0: const pw.FlexColumnWidth(0.6),
    1: const pw.FlexColumnWidth(1.8),
    2: const pw.FlexColumnWidth(2.6),
    3: const pw.FlexColumnWidth(0.9),
    4: const pw.FlexColumnWidth(1.0),
    5: const pw.FlexColumnWidth(0.9),
    6: const pw.FlexColumnWidth(1.0),
    7: const pw.FlexColumnWidth(0.8),
    8: const pw.FlexColumnWidth(0.8),
    9: const pw.FlexColumnWidth(0.9),
    10: const pw.FlexColumnWidth(1.4),
  };

  static pw.Widget _mainTableHeaderRow(PdfColor headerBlue) {
    final grey = PdfColors.grey;
    final labelStyle = pw.TextStyle(
      fontSize: 7.5,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
      height: 1.1,
    );

    const double totalH = 40;
    const double topH = 24;
    const double botH = 16;

    pw.Widget soloCell(String text) {
      return pw.Container(
        height: totalH,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
        decoration: pw.BoxDecoration(
          color: headerBlue,
          border: pw.Border.all(color: grey, width: 0.5),
        ),
        child: pw.Text(text, textAlign: pw.TextAlign.center, style: labelStyle),
      );
    }

    pw.Widget groupCell(String label, List<MapEntry<String, int>> subs) {
      return pw.Container(
        height: totalH,
        decoration: pw.BoxDecoration(
          color: headerBlue,
          border: pw.Border.all(color: grey, width: 0.5),
        ),
        child: pw.Column(
          children: [
            pw.Container(
              height: topH,
              width: double.infinity,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: grey, width: 0.5),
                ),
              ),
              child: pw.Text(
                label,
                textAlign: pw.TextAlign.center,
                style: labelStyle,
              ),
            ),
            pw.SizedBox(
              height: botH,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: subs
                    .map(
                      (s) => pw.Expanded(
                        flex: s.value,
                        child: pw.Container(
                          alignment: pw.Alignment.center,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              left: pw.BorderSide(color: grey, width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            s.key,
                            textAlign: pw.TextAlign.center,
                            style: labelStyle,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(0.6),
        1: const pw.FlexColumnWidth(1.8),
        2: const pw.FlexColumnWidth(2.6),
        3: const pw.FlexColumnWidth(1.9),
        4: const pw.FlexColumnWidth(1.9),
        5: const pw.FlexColumnWidth(1.6),
        6: const pw.FlexColumnWidth(0.9),
        7: const pw.FlexColumnWidth(1.4),
      },
      children: [
        pw.TableRow(
          children: [
            soloCell('Sr.\nNo'),
            soloCell('Name Of\nAgency'),
            soloCell('Work\nDescription'),
            groupCell('DAY Work', [
              const MapEntry('Skill', 9),
              const MapEntry('Unskilled', 10),
            ]),
            groupCell('Night Work', [
              const MapEntry('Skill', 9),
              const MapEntry('Unskilled', 10),
            ]),
            groupCell('Time Night', [
              const MapEntry('In', 8),
              const MapEntry('Out', 8),
            ]),
            soloCell('Total\n(A+B)'),
            soloCell('Remark'),
          ],
        ),
      ],
    );
  }

  static Future<void> generateSiteWisePdf({
    required List<DlrReportDm> reportData,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      if (reportData.isEmpty) {
        showErrorSnackbar('Error', 'No data found to generate PDF.');
        return;
      }

      final pdf = pw.Document();

      final headerBlue = PdfColor.fromHex('#4472C4');
      final dayNightValueBg = PdfColor.fromHex('#DCE6F1');
      final activityHeaderColor = PdfColor.fromHex('#B4C6E7');
      final subTotalColor = PdfColor.fromHex('#E2EFDA');
      final summaryFooterColor = PdfColor.fromHex('#B4C6E7');
      final textColor = PdfColor.fromHex('#333333');

      final Map<String, List<DlrReportDm>> groupedByDate = {};
      for (var item in reportData) {
        groupedByDate.putIfAbsent(item.date, () => []).add(item);
      }

      final sortedDates = groupedByDate.keys.toList()
        ..sort((a, b) => _parseDate(b).compareTo(_parseDate(a)));

      final Map<int, Uint8List?> logoCache = {};

      for (final currentDate in sortedDates) {
        final dateItems = groupedByDate[currentDate]!;

        final Map<String, List<DlrReportDm>> groupedBySite = {};
        for (var item in dateItems) {
          groupedBySite.putIfAbsent(item.siteCode, () => []).add(item);
        }

        for (final entry in groupedBySite.entries) {
          final siteItems = entry.value;
          final siteName = siteItems.first.siteName;
          final companyName = siteItems.first.coName;
          final coCode = siteItems.first.coCode;

          if (!logoCache.containsKey(coCode)) {
            logoCache[coCode] = await _loadLogoBytes(coCode);
          }
          final logoBytes = logoCache[coCode];

          final Map<String, List<DlrReportDm>> groupedByActivity = {};
          for (var item in siteItems) {
            groupedByActivity.putIfAbsent(item.activity, () => []).add(item);
          }

          final Map<String, _ActivityTotals> activityTotals = {};
          double grandDaySkill = 0, grandDayUnSkill = 0;
          double grandNightSkill = 0, grandNightUnSkill = 0;

          groupedByActivity.forEach((activity, items) {
            final t = _ActivityTotals();
            for (var item in items) {
              if (item.isNight) {
                t.nightSkill += item.skill;
                t.nightUnSkill += item.unSkill;
              } else {
                t.daySkill += item.skill;
                t.dayUnSkill += item.unSkill;
              }
            }
            activityTotals[activity] = t;
            grandDaySkill += t.daySkill;
            grandDayUnSkill += t.dayUnSkill;
            grandNightSkill += t.nightSkill;
            grandNightUnSkill += t.nightUnSkill;
          });

          final double grandDayTotal = grandDaySkill + grandDayUnSkill;
          final double grandNightTotal = grandNightSkill + grandNightUnSkill;

          pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4.landscape,
              margin: const pw.EdgeInsets.all(20),
              header: (context) => _buildPageHeader(
                companyName: companyName,
                siteName: siteName,
                fromDate: currentDate,
                toDate: currentDate,
                logoBytes: logoBytes,
                grandDayTotal: grandDayTotal,
                grandNightTotal: grandNightTotal,
                headerBlue: headerBlue,
                dayNightValueBg: dayNightValueBg,
              ),
              footer: (context) => _buildFooter(context),
              build: (context) => [
                ..._buildSiteWiseMainTableBody(
                  groupedByActivity: groupedByActivity,
                  activityTotals: activityTotals,
                  grandDaySkill: grandDaySkill,
                  grandDayUnSkill: grandDayUnSkill,
                  grandNightSkill: grandNightSkill,
                  grandNightUnSkill: grandNightUnSkill,
                  headerBlue: headerBlue,
                  activityHeaderColor: activityHeaderColor,
                  subTotalColor: subTotalColor,
                  textColor: textColor,
                ),
                pw.SizedBox(height: 12),
                _buildSiteWiseSummaryTable(
                  activities: groupedByActivity.keys.toList(),
                  activityTotals: activityTotals,
                  grandDaySkill: grandDaySkill,
                  grandDayUnSkill: grandDayUnSkill,
                  grandNightSkill: grandNightSkill,
                  grandNightUnSkill: grandNightUnSkill,
                  headerBlue: headerBlue,
                  summaryFooterColor: summaryFooterColor,
                  textColor: textColor,
                ),
              ],
            ),
          );
        }
      }

      await _savePdf(pdf, 'DLR_SiteWise_Report');
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate PDF: $e');
    }
  }

  static DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd-MM-yyyy').parseStrict(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return DateTime(1900);
      }
    }
  }

  static Future<Uint8List?> _loadLogoBytes(int coCode) async {
    String? assetPath;
    switch (coCode) {
      case 1:
        assetPath = kImageSCLogo;
        break;
      case 2:
        assetPath = kImagelogo;
        break;
      default:
        assetPath = null;
    }

    if (assetPath == null) return null;

    try {
      final data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _buildPageHeader({
    required String companyName,
    required String siteName,
    required String fromDate,
    required String toDate,
    required Uint8List? logoBytes,
    required double grandDayTotal,
    required double grandNightTotal,
    required PdfColor headerBlue,
    required PdfColor dayNightValueBg,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        ..._buildSiteWiseHeaderBlock(
          companyName: companyName,
          siteName: siteName,
          fromDate: fromDate,
          toDate: toDate,
          logoBytes: logoBytes,
          grandDayTotal: grandDayTotal,
          grandNightTotal: grandNightTotal,
          headerBlue: headerBlue,
          dayNightValueBg: dayNightValueBg,
        ),
        pw.SizedBox(height: 6),
        _mainTableHeaderRow(headerBlue),
      ],
    );
  }

  static List<pw.Widget> _buildSiteWiseHeaderBlock({
    required String companyName,
    required String siteName,
    required String fromDate,
    required String toDate,
    required Uint8List? logoBytes,
    required double grandDayTotal,
    required double grandNightTotal,
    required PdfColor headerBlue,
    required PdfColor dayNightValueBg,
  }) {
    final dateRangeText = fromDate == toDate
        ? fromDate
        : '$fromDate  -  $toDate';

    return [
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey, width: 0.5),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 5,
              ),
              decoration: pw.BoxDecoration(
                color: headerBlue,
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Text(
                'DLR\nREPORT',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),

            pw.Expanded(
              child: pw.Center(
                child: pw.Text(
                  companyName.toUpperCase(),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),

            pw.SizedBox(
              width: 120,
              height: 34,
              child: logoBytes != null
                  ? pw.Image(
                      pw.MemoryImage(logoBytes),
                      fit: pw.BoxFit.contain,
                      alignment: pw.Alignment.centerRight,
                    )
                  : null,
            ),
          ],
        ),
      ),

      pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(top: 4),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey, width: 0.5),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Row(
                children: [
                  pw.Expanded(child: _infoChip('PROJECT', siteName)),
                  pw.SizedBox(width: 10),
                  pw.Expanded(child: _infoChip('CONTRACTOR', companyName)),
                  pw.SizedBox(width: 10),
                  pw.Expanded(child: _infoChip('DATE', dateRangeText)),
                ],
              ),
            ),
            pw.SizedBox(width: 10),
            _totalPill('DAY', grandDayTotal.toStringAsFixed(1), headerBlue),
            pw.SizedBox(width: 6),
            _totalPill(
              'NIGHT',
              grandNightTotal.toStringAsFixed(1),
              PdfColor.fromHex('#1F3864'),
            ),
          ],
        ),
      ),

      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 2, right: 2),
        child: pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Report generated: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
          ),
        ),
      ),
    ];
  }

  static pw.Widget _infoChip(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 6.5,
            color: PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          maxLines: 1,
          overflow: pw.TextOverflow.clip,
        ),
      ],
    );
  }

  static pw.Widget _totalPill(String label, String value, PdfColor bgColor) {
    return pw.Container(
      width: 62,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 6.5,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildSiteWiseMainTableBody({
    required Map<String, List<DlrReportDm>> groupedByActivity,
    required Map<String, _ActivityTotals> activityTotals,
    required double grandDaySkill,
    required double grandDayUnSkill,
    required double grandNightSkill,
    required double grandNightUnSkill,
    required PdfColor headerBlue,
    required PdfColor activityHeaderColor,
    required PdfColor subTotalColor,
    required PdfColor textColor,
  }) {
    final columnWidths = _mainTableColumnWidths();
    List<pw.Widget> widgets = [];

    // NEW: running counter for Sr. No, continues across all activity groups
    int srNoCounter = 1;

    groupedByActivity.forEach((activity, items) {
      widgets.add(
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            color: activityHeaderColor,
            border: pw.Border(
              left: const pw.BorderSide(color: PdfColors.grey, width: 0.5),
              right: const pw.BorderSide(color: PdfColors.grey, width: 0.5),
              bottom: const pw.BorderSide(color: PdfColors.grey, width: 0.5),
            ),
          ),
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
          child: pw.Text(
            activity,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
      );

      List<pw.TableRow> rows = [];

      for (int i = 0; i < items.length; i++) {
        final item = items[i];

        final daySkillText = item.isNight ? '' : item.skill.toStringAsFixed(1);
        final dayUnSkillText = item.isNight
            ? ''
            : item.unSkill.toStringAsFixed(1);
        final nightSkillText = item.isNight
            ? item.skill.toStringAsFixed(1)
            : '';
        final nightUnSkillText = item.isNight
            ? item.unSkill.toStringAsFixed(1)
            : '';
        final inTimeText = item.isNight && item.inTime.isNotEmpty
            ? item.inTime
            : '';
        final outTimeText = item.isNight && item.outTime.isNotEmpty
            ? item.outTime
            : '';

        rows.add(
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? PdfColors.white : PdfColor.fromHex('#F5F5F5'),
            ),
            children: [
              _cell(
                // CHANGED: use running counter instead of item.srNo
                srNoCounter.toString(),
                textColor,
                align: pw.TextAlign.center,
              ),
              _cell(item.agencyName, textColor),
              _cell(
                item.description.isNotEmpty ? item.description : '-',
                textColor,
              ),
              _cell(daySkillText, textColor, align: pw.TextAlign.center),
              _cell(dayUnSkillText, textColor, align: pw.TextAlign.center),
              _cell(nightSkillText, textColor, align: pw.TextAlign.center),
              _cell(nightUnSkillText, textColor, align: pw.TextAlign.center),
              _cell(inTimeText, textColor, align: pw.TextAlign.center),
              _cell(outTimeText, textColor, align: pw.TextAlign.center),
              _cell(
                (item.skill + item.unSkill).toStringAsFixed(1),
                textColor,
                align: pw.TextAlign.center,
              ),
              _cell(item.remark.isNotEmpty ? item.remark : '-', textColor),
            ],
          ),
        );

        srNoCounter++; // NEW: increment after each row
      }

      final t = activityTotals[activity]!;
      final boldSmall = pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
      );

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: subTotalColor),
          children: [
            _cell('', textColor),
            _cell('Sub Total', textColor, style: boldSmall),
            _cell('', textColor),
            _cell(
              t.daySkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
              style: boldSmall,
            ),
            _cell(
              t.dayUnSkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
              style: boldSmall,
            ),
            _cell(
              t.nightSkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
              style: boldSmall,
            ),
            _cell(
              t.nightUnSkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
              style: boldSmall,
            ),
            _cell(
              'G.',
              textColor,
              align: pw.TextAlign.center,
              style: boldSmall,
            ),
            _cell(
              'Total',
              textColor,
              align: pw.TextAlign.center,
              style: boldSmall,
            ),
            _cell(
              t.grandTotal.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
              style: boldSmall,
            ),
            _cell('', textColor),
          ],
        ),
      );

      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          columnWidths: columnWidths,
          children: rows,
        ),
      );
    });

    final grandBold = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 9,
      color: PdfColors.white,
    );

    widgets.add(
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
        columnWidths: columnWidths,
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: headerBlue),
            children: [
              _cell('', PdfColors.white),
              _cell('Grand Total', PdfColors.white, style: grandBold),
              _cell('', PdfColors.white),
              _cell(
                grandDaySkill.toStringAsFixed(1),
                PdfColors.white,
                align: pw.TextAlign.center,
                style: grandBold,
              ),
              _cell(
                grandDayUnSkill.toStringAsFixed(1),
                PdfColors.white,
                align: pw.TextAlign.center,
                style: grandBold,
              ),
              _cell(
                grandNightSkill.toStringAsFixed(1),
                PdfColors.white,
                align: pw.TextAlign.center,
                style: grandBold,
              ),
              _cell(
                grandNightUnSkill.toStringAsFixed(1),
                PdfColors.white,
                align: pw.TextAlign.center,
                style: grandBold,
              ),
              _cell('', PdfColors.white),
              _cell('', PdfColors.white),
              _cell(
                (grandDaySkill +
                        grandDayUnSkill +
                        grandNightSkill +
                        grandNightUnSkill)
                    .toStringAsFixed(1),
                PdfColors.white,
                align: pw.TextAlign.center,
                style: grandBold,
              ),
              _cell('', PdfColors.white),
            ],
          ),
        ],
      ),
    );

    return widgets;
  }

  static pw.Widget _buildSiteWiseSummaryTable({
    required List<String> activities,
    required Map<String, _ActivityTotals> activityTotals,
    required double grandDaySkill,
    required double grandDayUnSkill,
    required double grandNightSkill,
    required double grandNightUnSkill,
    required PdfColor headerBlue,
    required PdfColor summaryFooterColor,
    required PdfColor textColor,
  }) {
    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(3.5),
      1: const pw.FlexColumnWidth(1.0),
      2: const pw.FlexColumnWidth(1.2),
      3: const pw.FlexColumnWidth(1.0),
      4: const pw.FlexColumnWidth(1.2),
    };

    List<pw.TableRow> rows = [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: headerBlue),
        children: [
          _headerCell('Work Description'),
          _headerCell('Day\nSkill'),
          _headerCell('Day\nUnskilled'),
          _headerCell('Night\nSkill'),
          _headerCell('Night\nUnskilled'),
        ],
      ),
    ];

    for (final activity in activities) {
      final t = activityTotals[activity]!;
      rows.add(
        pw.TableRow(
          children: [
            _cell(activity, textColor),
            _cell(
              t.daySkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
            ),
            _cell(
              t.dayUnSkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
            ),
            _cell(
              t.nightSkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
            ),
            _cell(
              t.nightUnSkill.toStringAsFixed(1),
              textColor,
              align: pw.TextAlign.center,
            ),
          ],
        ),
      );
    }

    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: summaryFooterColor),
        children: [
          _cell(
            'Total Manpower',
            textColor,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
          _cell(
            grandDaySkill.toStringAsFixed(1),
            textColor,
            align: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
          _cell(
            grandDayUnSkill.toStringAsFixed(1),
            textColor,
            align: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
          _cell(
            grandNightSkill.toStringAsFixed(1),
            textColor,
            align: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
          _cell(
            grandNightUnSkill.toStringAsFixed(1),
            textColor,
            align: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: columnWidths,
      children: rows,
    );
  }

  static Future<void> generateSummaryPdf({
    required List<DlrReportDm> reportData,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      if (reportData.isEmpty) {
        showErrorSnackbar('Error', 'No data found to generate PDF.');
        return;
      }

      final pdf = pw.Document();

      final tableHeaderColor = PdfColor.fromHex('#4472C4');
      final reportDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      final Map<String, List<DlrReportDm>> groupedByCompany = {};
      for (var item in reportData) {
        final key = '${item.coCode}_${item.coName}';
        groupedByCompany.putIfAbsent(key, () => []).add(item);
      }

      groupedByCompany.forEach((companyKey, companyItems) {
        final companyName = companyItems.first.coName;

        final List<String> siteNames = [];
        for (var item in companyItems) {
          if (!siteNames.contains(item.siteName)) {
            siteNames.add(item.siteName);
          }
        }

        final Map<String, Map<String, double>> agencyData = {};
        final Map<String, String> agencyActivityMap = {};

        for (var item in companyItems) {
          final key = '${item.agencyName}__${item.activity}';
          agencyActivityMap[key] = item.activity;
          agencyData.putIfAbsent(key, () => {});
          agencyData[key]![item.siteName] =
              (agencyData[key]![item.siteName] ?? 0) + item.total;
        }

        final Map<String, double> siteColumnTotals = {};
        for (var siteMap in agencyData.values) {
          siteMap.forEach((site, val) {
            siteColumnTotals[site] = (siteColumnTotals[site] ?? 0) + val;
          });
        }
        double grandTotal = siteColumnTotals.values.fold(0, (a, b) => a + b);

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.all(20),
            build: (context) => [
              _buildSummaryPage(
                companyName: companyName,
                reportDate: reportDate,
                fromDate: fromDate,
                toDate: toDate,
                siteNames: siteNames,
                agencyData: agencyData,
                siteColumnTotals: siteColumnTotals,
                grandTotal: grandTotal,
                tableHeaderColor: tableHeaderColor,
              ),
            ],
            footer: (context) => _buildFooter(context),
          ),
        );
      });

      await _savePdf(pdf, 'DLR_Summary_Report');
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Summary PDF: $e');
    }
  }

  static pw.Widget _buildSummaryPage({
    required String companyName,
    required String reportDate,
    required String fromDate,
    required String toDate,
    required List<String> siteNames,
    required Map<String, Map<String, double>> agencyData,
    required Map<String, double> siteColumnTotals,
    required double grandTotal,
    required PdfColor tableHeaderColor,
  }) {
    final int fixedCols = 3;

    Map<int, pw.TableColumnWidth> columnWidths = {
      0: const pw.FlexColumnWidth(0.6),
      1: const pw.FlexColumnWidth(2.2),
      2: const pw.FlexColumnWidth(2.5),
    };
    for (int i = 0; i < siteNames.length; i++) {
      columnWidths[fixedCols + i] = const pw.FlexColumnWidth(1.2);
    }
    columnWidths[fixedCols + siteNames.length] = const pw.FlexColumnWidth(1.2);

    List<pw.TableRow> rows = [];

    List<pw.Widget> headerCells = [
      _headerCell('Sr.\nNo.'),
      _headerCell('Name of Agency'),
      _headerCell('Work Description'),
    ];
    for (var site in siteNames) {
      headerCells.add(_headerCell(site, fontSize: 7));
    }
    headerCells.add(_headerCell('Total\nPerson'));

    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: tableHeaderColor),
        children: headerCells,
      ),
    );

    int srNo = 1;
    agencyData.forEach((key, siteMap) {
      final parts = key.split('__');
      final agencyName = parts[0];
      final activity = parts.length > 1 ? parts[1] : '';
      double rowTotal = siteMap.values.fold(0, (a, b) => a + b);

      List<pw.Widget> cells = [
        _dataCell(srNo.toString(), align: pw.TextAlign.center),
        _dataCell(agencyName),
        _dataCell(activity.isNotEmpty ? activity : '-'),
      ];

      for (var site in siteNames) {
        final val = siteMap[site];
        cells.add(
          _dataCell(
            val != null && val > 0 ? val.toStringAsFixed(0) : '-',
            align: pw.TextAlign.center,
          ),
        );
      }
      cells.add(
        _dataCell(
          rowTotal > 0 ? rowTotal.toStringAsFixed(0) : '-',
          align: pw.TextAlign.center,
          bold: true,
        ),
      );

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: srNo.isOdd ? PdfColors.white : PdfColor.fromHex('#F5F5F5'),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.3),
          ),
          children: cells,
        ),
      );
      srNo++;
    });

    List<pw.Widget> totalCells = [
      _dataCell('', align: pw.TextAlign.center),
      _dataCell('', align: pw.TextAlign.center),
      _dataCell('', align: pw.TextAlign.center),
    ];
    for (var site in siteNames) {
      final val = siteColumnTotals[site] ?? 0;
      totalCells.add(
        _dataCell(
          val > 0 ? val.toStringAsFixed(0) : '0',
          align: pw.TextAlign.center,
          bold: true,
        ),
      );
    }
    totalCells.add(
      _dataCell(
        grandTotal.toStringAsFixed(0),
        align: pw.TextAlign.center,
        bold: true,
      ),
    );

    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey, width: 0.5),
        ),
        children: totalCells,
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                companyName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Summary', style: const pw.TextStyle(fontSize: 10)),
              pw.Text(
                'Month : ${DateFormat('MMMM-yyyy').format(DateFormat('dd-MM-yyyy').parse(toDate))}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
          ),
          child: pw.Center(
            child: pw.Text(
              'Day Report - $fromDate to $toDate',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          columnWidths: columnWidths,
          children: rows,
        ),
      ],
    );
  }

  static pw.Widget _headerCell(String text, {double fontSize = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _dataCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _cell(
    String text,
    PdfColor color, {
    pw.TextAlign align = pw.TextAlign.left,
    pw.TextStyle? style,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        textAlign: align,
        style: style ?? pw.TextStyle(fontSize: 8, color: color),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('DLR Entry Report', style: pw.TextStyle(fontSize: 8)),
          pw.Text(
            'Page ${context.pageNumber}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String fileName) async {
    try {
      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final reportDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final file = File('${dir.path}/${fileName}_${reportDate}_$timestamp.pdf');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
      showSuccessSnackbar('Success', 'PDF report generated successfully');
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to save PDF: $e');
    }
  }
}
