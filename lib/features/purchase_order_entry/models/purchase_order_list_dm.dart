class PurchaseOrderListDm {
  final String invNo;
  final String date;
  final String pCode;
  final String pName;
  final String remarks;
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;
  final String attachments;
  final bool authorize;
  final double amount;
  final String poStatus;

  PurchaseOrderListDm({
    required this.invNo,
    required this.date,
    required this.pCode,
    required this.pName,
    required this.remarks,
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.attachments,
    required this.authorize,
    required this.amount,
    required this.poStatus,
  });

  factory PurchaseOrderListDm.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderListDm(
      invNo: json['InvNo'] ?? '',
      date: json['Date'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      remarks: json['Reamrks'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      attachments: json['Attachments'] ?? '',
      authorize: json['Authorize'] ?? false,
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      poStatus: json['POStatus'] ?? '',
    );
  }
}
