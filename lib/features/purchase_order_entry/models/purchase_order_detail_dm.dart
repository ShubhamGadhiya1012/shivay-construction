class PurchaseOrderDetailDm {
  final String iCode;
  final String iName;
  final List<IndentDetailDm> indents;

  PurchaseOrderDetailDm({
    required this.iCode,
    required this.iName,
    required this.indents,
  });

  factory PurchaseOrderDetailDm.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetailDm(
      iCode: json['iCode'] ?? '',
      iName: json['iName'] ?? '',
      indents:
          (json['indents'] as List<dynamic>?)
              ?.map((item) => IndentDetailDm.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class IndentDetailDm {
  final String indentInvNo;
  final String unit;
  final double orderQty;

  IndentDetailDm({
    required this.indentInvNo,
    required this.unit,
    required this.orderQty,
  });

  factory IndentDetailDm.fromJson(Map<String, dynamic> json) {
    return IndentDetailDm(
      indentInvNo: json['indentInvnno'] ?? '',
      unit: json['unit'] ?? 'Nos',
      orderQty: (json['orderQty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
