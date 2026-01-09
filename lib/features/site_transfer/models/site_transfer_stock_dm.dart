// models/site_transfer_stock_dm.dart
class SiteTransferStockDm {
  final String iCode;
  final String iName;
  final String unit;
  final double stockQty;

  SiteTransferStockDm({
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.stockQty,
  });

  factory SiteTransferStockDm.fromJson(Map<String, dynamic> json) {
    return SiteTransferStockDm(
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      stockQty: (json['StockQty'] ?? 0).toDouble(),
    );
  }
}
