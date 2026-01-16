class GrnDm {
  final String invNo;
  final String date;
  final String pCode;
  final String pName;
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;
  final String remarks;
  final String attachments;

  GrnDm({
    required this.invNo,
    required this.date,
    required this.pCode,
    required this.pName,
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.remarks,
    required this.attachments,
  });

  factory GrnDm.fromJson(Map<String, dynamic> json) {
    return GrnDm(
      invNo: json['InvNo'] ?? '',
      date: json['Date'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      remarks: json['Remarks'] ?? '',
      attachments: json['Attachments'] ?? '',
    );
  }
}
