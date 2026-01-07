class PurchaseOrderDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final String? unit;
  final double authorizedQty;
  final double orderQty;

  PurchaseOrderDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    this.unit,
    required this.authorizedQty,
    required this.orderQty,
  });

  factory PurchaseOrderDetailDm.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetailDm(
      srNo: json['SrNo'] ?? 0,
      iCode: json['ICODE'] ?? '',
      iName: json['INAME'] ?? '',
      unit: json['Unit'],
      authorizedQty: (json['AuthorizedQty'] as num?)?.toDouble() ?? 0.0,
      orderQty: (json['OrderQty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
