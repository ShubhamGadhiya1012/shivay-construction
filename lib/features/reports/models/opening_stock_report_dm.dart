class OpeningStockReportDm {
  final String invNo;
  final String date;
  final String iCode;
  final String iName;
  final String unit;
  final double qty;
  final double rate;
  final double amount;
  final String gdCode;
  final String siteCode;
  final String siteName;
  final String gdName;

  OpeningStockReportDm({
    required this.invNo,
    required this.date,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.gdCode,
    required this.siteCode,
    required this.siteName,
    required this.gdName,
  });

  factory OpeningStockReportDm.fromJson(Map<String, dynamic> json) {
    return OpeningStockReportDm(
      invNo: json['InvNo'] ?? '',
      date: json['Date'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      qty: (json['Qty'] ?? 0).toDouble(),
      rate: (json['Rate'] ?? 0).toDouble(),
      amount: (json['Amount'] ?? 0).toDouble(),
      gdCode: json['GDCode'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdName: json['GDName'] ?? '',
    );
  }
}
