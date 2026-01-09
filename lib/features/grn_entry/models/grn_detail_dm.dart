class GrnDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final String unit;
  final double qty;

  GrnDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.qty,
  });

  factory GrnDetailDm.fromJson(Map<String, dynamic> json) {
    return GrnDetailDm(
      srNo: json['SrNo'] ?? 0,
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      qty: (json['Qty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
