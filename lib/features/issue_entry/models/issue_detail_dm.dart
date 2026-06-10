class IssueDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final String unit;
  final double qty;
  final double rate;
  final String gdCode;
  final String gdName;
  final String poRemark;
  final String cpCode;
  final String cpName;

  IssueDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.qty,
    required this.rate,
    required this.gdCode,
    required this.gdName,
    this.poRemark = '',
    this.cpCode = '',
    this.cpName = '',
  });

  factory IssueDetailDm.fromJson(Map<String, dynamic> json) {
    return IssueDetailDm(
      srNo: json['SrNo'] ?? 0,
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      qty: (json['Qty'] as num?)?.toDouble() ?? 0.0,
      rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      poRemark: json['PORemark'] ?? '',
      cpCode: json['CPCode'] ?? '',
      cpName: json['CPName'] ?? '',
    );
  }
}
