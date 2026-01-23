class AuthIndentItemDm {
  final String iCode;
  final String iName;
  final double rate;
  final List<IndentDm> indents;

  AuthIndentItemDm({
    required this.iCode,
    required this.iName,
    required this.rate,
    required this.indents,
  });

  factory AuthIndentItemDm.fromJson(Map<String, dynamic> json) {
    return AuthIndentItemDm(
      iCode: json['iCode'] ?? '',
      iName: json['iName'] ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      indents:
          (json['indents'] as List<dynamic>?)
              ?.map((item) => IndentDm.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class IndentDm {
  final int srNo;
  final int indentSrNo;
  final String indentNo;
  final double authoriseQty;
  final double indentQty;
  final String siteCode;
  final String siteName;
  final String gCode;
  final String gdName;
  final String date;
  bool isSelected;

  IndentDm({
    required this.srNo,
    required this.indentSrNo,
    required this.indentNo,
    required this.authoriseQty,
    required this.indentQty,
    required this.siteCode,
    required this.siteName,
    required this.gCode,
    required this.gdName,
    required this.date,
    this.isSelected = false,
  });

  factory IndentDm.fromJson(Map<String, dynamic> json) {
    return IndentDm(
      srNo: json['srNo'] ?? 0,
      indentSrNo: json['indentSrNo'] ?? 0,
      indentNo: json['indentNo'] ?? '',
      authoriseQty: (json['authoriseQty'] as num?)?.toDouble() ?? 0.0,
      indentQty: (json['indentQty'] as num?)?.toDouble() ?? 0.0,
      siteCode: json['siteCode'] ?? '',
      siteName: json['siteName'] ?? '',
      gCode: json['gCode'] ?? '',
      gdName: json['gdName'] ?? '',
      date: json['date'] ?? '',
      isSelected: false,
    );
  }
}
