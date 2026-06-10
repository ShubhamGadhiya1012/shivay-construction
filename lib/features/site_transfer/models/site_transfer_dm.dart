class SiteTransferDm {
  final String invNo;
  final String date;
  final String fromSiteCode;
  final String toSiteCode;
  final String fromSiteName;
  final String toSiteName;
  final String remarks;
  final String status;

  SiteTransferDm({
    required this.invNo,
    required this.date,
    required this.fromSiteCode,
    required this.toSiteCode,
    required this.fromSiteName,
    required this.toSiteName,
    required this.remarks,
    required this.status,
  });

  factory SiteTransferDm.fromJson(Map<String, dynamic> json) {
    return SiteTransferDm(
      invNo: json['Invno'] ?? '',
      date: json['Date'] ?? '',
      fromSiteCode: json['FromSiteCode'] ?? '',
      toSiteCode: json['ToSiteCode'] ?? '',
      fromSiteName: json['FromSite'] ?? '',
      toSiteName: json['ToSite'] ?? '',
      remarks: json['Remarks'] ?? '',
      status: json['Status'] ?? '',
    );
  }
}
