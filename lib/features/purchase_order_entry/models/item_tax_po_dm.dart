class PurchaseOrderItemTaxDm {
  final String iCode;
  final String iName;
  final String desc;
  final String unit;
  final String? hsnNo;
  final double igst;
  final double cgst;
  final double sgst;

  PurchaseOrderItemTaxDm({
    required this.iCode,
    required this.iName,
    required this.desc,
    required this.unit,
    this.hsnNo,
    required this.igst,
    required this.cgst,
    required this.sgst,
  });

  factory PurchaseOrderItemTaxDm.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItemTaxDm(
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      desc: json['Desc'] ?? '',
      unit: json['Unit'] ?? '',
      hsnNo: json['HSNNO'],
      igst: (json['IGST'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['CGST'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['SGST'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
