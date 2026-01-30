class SiteTransferDm {
  final String invNo;
  final String date;
  final String fromSiteCode;
  final String toSiteCode;
  final String fromGDCode;
  final String toGDCode;
  final String fromSiteName;
  final String toSiteName;
  final String fromGodown;
  final String toGodown;
  final String remarks;
  final String status;

  SiteTransferDm({
    required this.invNo,
    required this.date,
    required this.fromSiteCode,
    required this.toSiteCode,
    required this.fromGDCode,
    required this.toGDCode,
    required this.fromSiteName,
    required this.toSiteName,
    required this.fromGodown,
    required this.toGodown,
    required this.remarks,
    required this.status,
  });

  factory SiteTransferDm.fromJson(Map<String, dynamic> json) {
    return SiteTransferDm(
      invNo: json['Invno'] ?? '',
      date: json['Date'] ?? '',
      fromSiteCode: json['FromSiteCode'] ?? '',
      toSiteCode: json['ToSiteCode'] ?? '',
      fromGDCode: json['FromGDCode'] ?? '',
      toGDCode: json['ToGDCode'] ?? '',
      fromSiteName: json['FromSite'] ?? '',
      toSiteName: json['ToSite'] ?? '',
      fromGodown: json['FromGodown'] ?? '',
      toGodown: json['ToGodown'] ?? '',
      remarks: json['Remarks'] ?? '',
      status: json['Status'] ?? '',
    );
  }
}
