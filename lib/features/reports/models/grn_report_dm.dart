class GrnReportDm {
  final String grnNo;
  final String grnDate;
  final String pCode;
  final String pName;
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;
  final String iCode;
  final String iName;
  final String unit;
  final double grnQty;
  final String poInvNo;
  final String remark;

  GrnReportDm({
    required this.grnNo,
    required this.grnDate,
    required this.pCode,
    required this.pName,
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.grnQty,
    required this.poInvNo,
    required this.remark,
  });

  factory GrnReportDm.fromJson(Map<String, dynamic> json) {
    return GrnReportDm(
      grnNo: json['GRNNo'] ?? '',
      grnDate: json['GRNDate'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      grnQty: (json['GRNQty'] ?? 0).toDouble(),
      poInvNo: json['POInvNo'] ?? '',
      remark: json['Remark'] ?? '',
    );
  }
}
