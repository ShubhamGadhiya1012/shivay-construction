class StockReportDm {
  final String? iCode;
  final String? iName;
  final String? unit;
  final String? igName;
  final String? icName;
  final double? openQty;
  final double? inQty;
  final double? outQty;
  final double? closeQty;
  final double? rate;
  final double? closeValue;

  // For Stock Ledger
  final String? date;
  final String? siteName;
  final String? gdName;
  final String? invNo;
  final String? dbc;
  final String? desc;
  final String? pName;
  final double? receiptQty;
  final double? issueQty;
  final double? balanceQty;
  final String? refInvNo;

  // For Group Stock Report
  final double? stockQty;

  // For Site Stock Report
  final String? siteCode;
  final String? gdCode;

  StockReportDm({
    this.iCode,
    this.iName,
    this.unit,
    this.igName,
    this.icName,
    this.openQty,
    this.inQty,
    this.outQty,
    this.closeQty,
    this.rate,
    this.closeValue,
    this.date,
    this.siteName,
    this.gdName,
    this.invNo,
    this.dbc,
    this.desc,
    this.pName,
    this.receiptQty,
    this.issueQty,
    this.balanceQty,
    this.refInvNo,
    this.stockQty,
    this.siteCode,
    this.gdCode,
  });

  factory StockReportDm.fromJson(Map<String, dynamic> json) {
    return StockReportDm(
      iCode: json['ICode'],
      iName: json['IName'],
      unit: json['Unit'],
      igName: json['IGName'],
      icName: json['ICName'],
      openQty: _parseDouble(json['OpenQty']),
      inQty: _parseDouble(json['InQty']),
      outQty: _parseDouble(json['OutQty']),
      closeQty: _parseDouble(json['CloseQty']),
      rate: _parseDouble(json['Rate']),
      closeValue: _parseDouble(json['CloseValue']),
      date: json['Date'],
      siteName: json['SiteName'],
      gdName: json['GDName'],
      invNo: json['InvNo'],
      dbc: json['DBC'],
      desc: json['Desc'],
      pName: json['PName'],
      receiptQty: _parseDouble(json['ReceiptQty']),
      issueQty: _parseDouble(json['IssueQty']),
      balanceQty: _parseDouble(json['BalanceQty']),
      refInvNo: json['RefInvNo'],
      stockQty: _parseDouble(json['StockQty']),
      siteCode: json['SiteCode'],
      gdCode: json['GDCode'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool get isGrandTotal =>
      iCode?.toUpperCase() == 'TOTAL' ||
      iName?.toUpperCase().contains('GRAND TOTAL') == true;

  bool get isOpeningClosing =>
      desc?.contains('Opening Stock') == true ||
      desc?.contains('Closing Stock') == true;
}
