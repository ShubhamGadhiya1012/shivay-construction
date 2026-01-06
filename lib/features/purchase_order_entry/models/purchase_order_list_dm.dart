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
  });

  factory PurchaseOrderListDm.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderListDm(
      invNo: json['InvNo'] ?? '',
      date: json['Date'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      remarks: json['Reamrks'] ?? '', // Note: API has typo "Reamrks"
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      attachments: json['Attachments'] ?? '',
    );
  }
}

class PurchaseOrderDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final String? unit;
  final double authorizedQty;
  final double orderQty;

  PurchaseOrderDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    this.unit,
    required this.authorizedQty,
    required this.orderQty,
  });

  factory PurchaseOrderDetailDm.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetailDm(
      srNo: json['SrNo'] ?? 0,
      iCode: json['ICODE'] ?? '',
      iName: json['INAME'] ?? '',
      unit: json['Unit'],
      authorizedQty: (json['AuthorizedQty'] as num?)?.toDouble() ?? 0.0,
      orderQty: (json['OrderQty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
