class PoOrderDm {
  final int srNo;
  final String poInvNo;
  final int poSrNo;
  final String poDate;
  final double poQty;
  final double receivedQty;
  final double pendingQty;
  final String pCode;
  final String pName;
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;

  PoOrderDm({
    required this.srNo,
    required this.poInvNo,
    required this.poSrNo,
    required this.poDate,
    required this.poQty,
    required this.receivedQty,
    required this.pendingQty,
    required this.pCode,
    required this.pName,
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
  });

  factory PoOrderDm.fromJson(Map<String, dynamic> json) {
    return PoOrderDm(
      srNo: json['srNo'] ?? 0,
      poInvNo: json['poInvNo'] ?? '',
      poSrNo: json['poSrNo'] ?? 0,
      poDate: json['poDate'] ?? '',
      poQty: (json['poQty'] as num?)?.toDouble() ?? 0.0,
      receivedQty: (json['receivedQty'] as num?)?.toDouble() ?? 0.0,
      pendingQty: (json['pendingQty'] as num?)?.toDouble() ?? 0.0,
      pCode: json['pCode'] ?? '',
      pName: json['pName'] ?? '',
      siteCode: json['siteCode'] ?? '',
      siteName: json['siteName'] ?? '',
      gdCode: json['gdCode'] ?? '',
      gdName: json['gdName'] ?? '',
    );
  }
}

class PoAuthItemDm {
  final String iCode;
  final String iName;
  final String unit;
  final List<PoOrderDm> orders;

  PoAuthItemDm({
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.orders,
  });

  factory PoAuthItemDm.fromJson(Map<String, dynamic> json) {
    return PoAuthItemDm(
      iCode: json['iCode'] ?? '',
      iName: json['iName'] ?? '',
      unit: json['unit'] ?? '',
      orders: json['orders'] != null
          ? (json['orders'] as List<dynamic>)
                .map((order) => PoOrderDm.fromJson(order))
                .toList()
          : [],
    );
  }
}
