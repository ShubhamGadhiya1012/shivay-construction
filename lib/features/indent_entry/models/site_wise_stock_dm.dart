class SiteWiseStockDm {
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;
  final String iCode;
  final String iName;
  final String unit;
  final double stockQty;

  SiteWiseStockDm({
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.stockQty,
  });

  factory SiteWiseStockDm.fromJson(Map<String, dynamic> json) {
    return SiteWiseStockDm(
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      stockQty: (json['StockQty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
