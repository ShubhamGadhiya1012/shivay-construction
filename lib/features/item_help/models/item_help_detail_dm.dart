class ItemHelpDetailDm {
  final String iCode;
  final String iName;
  final String unit;
  final String description;
  final double avgRate;
  final double poPendingQty;
  final double stockQty;

  ItemHelpDetailDm({
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.description,
    required this.avgRate,
    required this.poPendingQty,
    required this.stockQty,
  });

  factory ItemHelpDetailDm.fromJson(Map<String, dynamic> json) {
    return ItemHelpDetailDm(
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      description: json['Description'] ?? '',
      avgRate: json['AvgRate'] != null
          ? double.tryParse(json['AvgRate'].toString()) ?? 0.0
          : 0.0,
      poPendingQty: json['POPendingQty'] != null
          ? double.tryParse(json['POPendingQty'].toString()) ?? 0.0
          : 0.0,
      stockQty: json['StockQty'] != null
          ? double.tryParse(json['StockQty'].toString()) ?? 0.0
          : 0.0,
    );
  }
}
