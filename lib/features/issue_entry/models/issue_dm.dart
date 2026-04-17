class IssueDm {
  final String invNo;
  final String date;
  final String pCode;
  final String pName;
  final String siteCode;
  final String siteName;
  final String remark;
  final String refInvNo;

  IssueDm({
    required this.invNo,
    required this.date,
    required this.pCode,
    required this.pName,
    required this.siteCode,
    required this.siteName,
    required this.remark,
    required this.refInvNo,
  });

  factory IssueDm.fromJson(Map<String, dynamic> json) {
    return IssueDm(
      invNo: json['Invno'] ?? '',
      date: json['Date'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      remark: json['Remark'] ?? '',
      refInvNo: json['RefInvno'] ?? '',
    );
  }
}
