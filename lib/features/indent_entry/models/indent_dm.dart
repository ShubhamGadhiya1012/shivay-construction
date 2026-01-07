class IndentDm {
  final String invNo;
  final String date;
  final String fromDate;
  final String toDate;
  final String gdCode;
  final String gdName;
  final String siteCode;
  final String siteName;
  final bool authorize;
  final String attachments;

  IndentDm({
    required this.invNo,
    required this.date,
    required this.fromDate,
    required this.toDate,
    required this.gdCode,
    required this.gdName,
    required this.siteCode,
    required this.siteName,
    required this.authorize,
    required this.attachments,
  });

  factory IndentDm.fromJson(Map<String, dynamic> json) {
    return IndentDm(
      invNo: json['InvNo'] ?? '',
      date: json['Date'] ?? '',
      fromDate: json['FromDate'] ?? '',
      toDate: json['ToDate'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      authorize: json['Authorize'] ?? false,
      attachments: json['Attachments'] ?? '',
    );
  }
}
