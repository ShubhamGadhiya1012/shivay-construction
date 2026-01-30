class SiteTransferDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final double qty;
  final double receivedQty;
  final double autoReturnQty;

  SiteTransferDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    required this.qty,
    required this.receivedQty,
    required this.autoReturnQty,
  });

  factory SiteTransferDetailDm.fromJson(Map<String, dynamic> json) {
    return SiteTransferDetailDm(
      srNo: json['SrNo'] ?? 0,
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      qty: (json['IssuedQty'] as num?)?.toDouble() ?? 0.0,
      receivedQty: (json['ReceivedQty'] as num?)?.toDouble() ?? 0.0,
      autoReturnQty: (json['AutoReturnQty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
