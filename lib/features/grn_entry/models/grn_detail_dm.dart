class GrnDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final String unit;
  final double qty;
  final double poSrnNo;
  final String poInvNo;
  final String poDate;
  final double poQty;
  final double pendingQty;
  final double rate;
  final String gdCode; // ADD
  final String gdName; // ADD
  final String poRemark;

  GrnDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.qty,
    required this.poSrnNo,
    required this.poInvNo,
    required this.poQty,
    required this.poDate,
    required this.pendingQty,
    required this.rate,
    this.gdCode = '', // ADD
    this.gdName = '', // ADD
    this.poRemark = '',
  });

  factory GrnDetailDm.fromJson(Map<String, dynamic> json) {
    return GrnDetailDm(
      srNo: json['SrNo'] ?? 0,
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      qty: (json['Qty'] as num?)?.toDouble() ?? 0.0,
      poInvNo: json['POInvNo'] ?? '',
      poDate: json['PODate'] ?? '',
      poSrnNo: (json['POSrNo'] as num?)?.toDouble() ?? 0.0,
      poQty: (json['POQty'] as num?)?.toDouble() ?? 0.0,
      pendingQty: (json['PendingQty'] as num?)?.toDouble() ?? 0.0,
      rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,
      gdCode: json['GDCode'] ?? '', // ADD
      gdName: json['GDName'] ?? '', // ADD
      poRemark: json['PORemark'] ?? '', // ADD
    );
  }
}
