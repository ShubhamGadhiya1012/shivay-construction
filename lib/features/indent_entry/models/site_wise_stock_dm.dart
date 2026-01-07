class SiteWiseStockDm {
  final String siteCode;
  final String siteName;
  final String iCode;
  final String iName;
  final String unit;
  final double stockQty;

  SiteWiseStockDm({
    required this.siteCode,
    required this.siteName,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.stockQty,
  });

  factory SiteWiseStockDm.fromJson(Map<String, dynamic> json) {
    return SiteWiseStockDm(
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      stockQty: (json['StockQty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
