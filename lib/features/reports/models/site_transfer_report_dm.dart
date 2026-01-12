class SiteTransferReportDm {
  final String transferNo;
  final String transferDate;
  final String fromSite;
  final String fromSiteName;
  final String toSite;
  final String toSiteName;
  final String fromGDCode;
  final String fromGDName;
  final String toGDCode;
  final String toGDName;
  final String iCode;
  final String iName;
  final double qty;
  final String remarks;

  SiteTransferReportDm({
    required this.transferNo,
    required this.transferDate,
    required this.fromSite,
    required this.fromSiteName,
    required this.toSite,
    required this.toSiteName,
    required this.fromGDCode,
    required this.fromGDName,
    required this.toGDCode,
    required this.toGDName,
    required this.iCode,
    required this.iName,
    required this.qty,
    required this.remarks,
  });

  factory SiteTransferReportDm.fromJson(Map<String, dynamic> json) {
    return SiteTransferReportDm(
      transferNo: json['TransferNo'] ?? '',
      transferDate: json['TransferDate'] ?? '',
      fromSite: json['FromSite'] ?? '',
      fromSiteName: json['FromSiteName'] ?? '',
      toSite: json['ToSite'] ?? '',
      toSiteName: json['ToSiteName'] ?? '',
      fromGDCode: json['FromGDCode'] ?? '',
      fromGDName: json['FromGDName'] ?? '',
      toGDCode: json['ToGDCode'] ?? '',
      toGDName: json['ToGDName'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      qty: (json['Qty'] ?? 0).toDouble(),
      remarks: json['Remarks'] ?? '',
    );
  }
}
