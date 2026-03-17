class IndentDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final String unit;
  final double authorizedQty;
  final double indentQty;
  final String reqDate;
  final String remark;
  final String gdCode; // ADD
  final String gdName;

  IndentDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.authorizedQty,
    required this.indentQty,
    required this.reqDate,
    required this.remark,
    required this.gdCode, // ADD
    required this.gdName,
  });

  factory IndentDetailDm.fromJson(Map<String, dynamic> json) {
    return IndentDetailDm(
      srNo: json['SrNo'] ?? 0,
      iCode: json['ICODE'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      authorizedQty: (json['AuthorizedQty'] as num?)?.toDouble() ?? 0.0,
      indentQty: (json['IndentQty'] as num?)?.toDouble() ?? 0.0,
      reqDate: json['ReqDate'] ?? '',
      remark: json['Remark'] ?? '',
      gdCode: json['GDCode'] ?? '', // ADD
      gdName: json['GDName'] ?? '', // ADD
    );
  }
}
