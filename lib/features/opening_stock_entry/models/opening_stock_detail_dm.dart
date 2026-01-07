class OpeningStockDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final double qty;
  final double rate;

  OpeningStockDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    required this.qty,
    required this.rate,
  });

  factory OpeningStockDetailDm.fromJson(Map<String, dynamic> json) {
    return OpeningStockDetailDm(
      srNo: json['srNo'] ?? 0,
      iCode: json['iCode'] ?? '',
      iName: json['iName'] ?? '',
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
