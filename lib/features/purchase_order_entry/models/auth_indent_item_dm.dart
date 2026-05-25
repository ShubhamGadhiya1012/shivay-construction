class AuthIndentItemDm {
  final String indentNo;
  final List<IndentDm> items;

  AuthIndentItemDm({required this.indentNo, required this.items});

  factory AuthIndentItemDm.fromJson(Map<String, dynamic> json) {
    return AuthIndentItemDm(
      indentNo: json['indentNo'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => IndentDm.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class IndentDm {
  final int srNo;
  final int indentSrNo;
  final String iCode;
  final String iName;
  final double rate;
  final double authoriseQty;
  final double indentQty;
  final String siteCode;
  final String siteName;
  final String gCode;
  final String gdName;
  final String reqDate;
  final String indentRemark;
  final String hsnNo;
  final double igst;
  final double sgst;
  final double cgst;
  bool isSelected;

  IndentDm({
    required this.srNo,
    required this.indentSrNo,
    required this.iCode,
    required this.iName,
    required this.rate,
    required this.authoriseQty,
    required this.indentQty,
    required this.siteCode,
    required this.siteName,
    required this.gCode,
    required this.gdName,
    required this.reqDate,
    this.indentRemark = '',
    this.hsnNo = '',
    this.igst = 0.0,
    this.sgst = 0.0,
    this.cgst = 0.0,
    this.isSelected = false,
  });

  factory IndentDm.fromJson(Map<String, dynamic> json) {
    return IndentDm(
      srNo: json['srNo'] ?? 0,
      indentSrNo: json['indentSrNo'] ?? 0,
      iCode: json['iCode'] ?? '',
      iName: json['iName'] ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      authoriseQty: (json['authoriseQty'] as num?)?.toDouble() ?? 0.0,
      indentQty: (json['indentQty'] as num?)?.toDouble() ?? 0.0,
      siteCode: json['siteCode'] ?? '',
      siteName: json['siteName'] ?? '',
      gCode: json['gCode'] ?? '',
      gdName: json['gdName'] ?? '',
      reqDate: json['reqDate'] ?? '',
      indentRemark: json['indentRemark'] ?? '',
      hsnNo: json['hsnNo'] ?? '',
      igst: (json['igst'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      isSelected: false,
    );
  }
}
