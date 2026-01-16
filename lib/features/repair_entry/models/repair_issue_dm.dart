class RepairIssueDm {
  final String invNo;
  final String issueDate;
  final String pCode;
  final String pName;
  final String description;
  final String site;
  final String siteName;
  final String gdCode;
  final String gdName;
  final String remarks;
  final String status;

  RepairIssueDm({
    required this.invNo,
    required this.issueDate,
    required this.pCode,
    required this.pName,
    required this.description,
    required this.site,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.remarks,
    required this.status,
  });

  factory RepairIssueDm.fromJson(Map<String, dynamic> json) {
    return RepairIssueDm(
      invNo: json['InvNo'] ?? '',
      issueDate: json['IssueDate'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      description: json['Description'] ?? '',
      site: json['Site'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      remarks: json['Remarks'] ?? '',
      status: json['Status'] ?? '',
    );
  }
}
