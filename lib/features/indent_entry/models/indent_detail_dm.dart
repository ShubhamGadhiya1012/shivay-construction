class IndentDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final String unit;
  final double authorizedQty;
  final double indentQty;
  final String reqDate;

  IndentDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.authorizedQty,
    required this.indentQty,
    required this.reqDate,
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
    );
  }
}
