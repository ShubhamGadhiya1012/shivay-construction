class GrnItemForIssueDm {
  final String grnInvNo;
  final String grnDate;
  final String pCode;
  final String pName;
  final String siteCode;
  final String siteName;
  final List<GrnItemDetailDm> items;

  GrnItemForIssueDm({
    required this.grnInvNo,
    required this.grnDate,
    required this.pCode,
    required this.pName,
    required this.siteCode,
    required this.siteName,
    required this.items,
  });

  factory GrnItemForIssueDm.fromJson(Map<String, dynamic> json) {
    return GrnItemForIssueDm(
      grnInvNo: json['grnInvNo'] ?? '',
      grnDate: json['grnDate'] ?? '',
      pCode: json['pCode'] ?? '',
      pName: json['pName'] ?? '',
      siteCode: json['siteCode'] ?? '',
      siteName: json['siteName'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
                .map((e) => GrnItemDetailDm.fromJson(e))
                .toList()
          : [],
    );
  }
}

class GrnItemDetailDm {
  final int grnSrNo;
  final String iCode;
  final String iName;
  final String unit;
  final double rate;
  final double grnQty;
  final double issuedQty;
  final double pendingQty;
  final String gdCode;
  final String gdName;
  final String cpCode;
  final String cpName;

  GrnItemDetailDm({
    required this.grnSrNo,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.rate,
    required this.grnQty,
    required this.issuedQty,
    required this.pendingQty,
    required this.gdCode,
    required this.gdName,
    required this.cpCode,
    required this.cpName,
  });

  factory GrnItemDetailDm.fromJson(Map<String, dynamic> json) {
    return GrnItemDetailDm(
      grnSrNo: json['grnSrNo'] ?? json['SrNo'] ?? 0,
      iCode: json['iCode'] ?? json['ICode'] ?? '',
      iName: json['iName'] ?? json['IName'] ?? '',
      unit: json['unit'] ?? json['Unit'] ?? '',
      rate: (json['rate'] ?? json['Rate'] as num?)?.toDouble() ?? 0.0,
      grnQty: (json['grnQty'] ?? json['GrnQty'] as num?)?.toDouble() ?? 0.0,
      issuedQty:
          (json['issuedQty'] ?? json['IssuedQty'] as num?)?.toDouble() ?? 0.0,
      pendingQty:
          (json['pendingQty'] ?? json['PendingQty'] as num?)?.toDouble() ?? 0.0,
      gdCode: json['gdCode'] ?? json['GDCode'] ?? '',
      gdName: json['gdName'] ?? json['GDName'] ?? '',
      cpCode: json['cpCode'] ?? json['CPCode'] ?? '',
      cpName: json['cpName'] ?? json['CPName'] ?? '',
    );
  }
}
