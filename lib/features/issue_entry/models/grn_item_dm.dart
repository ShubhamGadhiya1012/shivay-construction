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
  });

  factory GrnItemDetailDm.fromJson(Map<String, dynamic> json) {
    return GrnItemDetailDm(
      grnSrNo: json['grnSrNo'] ?? 0,
      iCode: json['iCode'] ?? '',
      iName: json['iName'] ?? '',
      unit: json['unit'] ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      grnQty: (json['grnQty'] as num?)?.toDouble() ?? 0.0,
      issuedQty: (json['issuedQty'] as num?)?.toDouble() ?? 0.0,
      pendingQty: (json['pendingQty'] as num?)?.toDouble() ?? 0.0,
      gdCode: json['gdCode'] ?? '',
      gdName: json['gdName'] ?? '',
    );
  }
}
