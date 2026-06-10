class SiteTransferDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final String unit;
  final double qty;
  final double receivedQty;
  final double autoReturnQty;
  final String fromGDCode;
  final String toGDCode;
  final String fromGodown;
  final String toGodown;

  SiteTransferDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.qty,
    required this.receivedQty,
    required this.autoReturnQty,
    required this.fromGDCode,
    required this.toGDCode,
    required this.fromGodown,
    required this.toGodown,
  });

  factory SiteTransferDetailDm.fromJson(Map<String, dynamic> json) {
    return SiteTransferDetailDm(
      srNo: json['SrNo'] ?? 0,
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      qty: (json['IssuedQty'] as num?)?.toDouble() ?? 0.0,
      receivedQty: (json['ReceivedQty'] as num?)?.toDouble() ?? 0.0,
      autoReturnQty: (json['AutoReturnQty'] as num?)?.toDouble() ?? 0.0,
      fromGDCode: json['FromGDCode'] ?? '',
      toGDCode: json['ToGDCode'] ?? '',
      fromGodown: json['FromGodown'] ?? '',
      toGodown: json['ToGodown'] ?? '',
    );
  }
}
