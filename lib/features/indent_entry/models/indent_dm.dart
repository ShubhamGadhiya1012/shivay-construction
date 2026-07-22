class IndentDm {
  final String invNo;
  final String date;
  final String gdCode;
  final String gdName;
  final String siteCode;
  final String siteName;
  final String entryByUserName;
  final bool authorize;
  final bool closeIndent;
  final String attachments;

  IndentDm({
    required this.invNo,
    required this.date,
    required this.gdCode,
    required this.gdName,
    required this.siteCode,
    required this.siteName,
    required this.authorize,
    required this.entryByUserName,
    required this.closeIndent,
    required this.attachments,
  });

  factory IndentDm.fromJson(Map<String, dynamic> json) {
    return IndentDm(
      invNo: json['InvNo'] ?? '',
      date: json['Date'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      entryByUserName: json['EntryByUserName'] ?? '',
      authorize: json['Authorize'] ?? false,
      closeIndent: json['CloseIndent'] ?? false,
      attachments: json['Attachments'] ?? '',
    );
  }
}
