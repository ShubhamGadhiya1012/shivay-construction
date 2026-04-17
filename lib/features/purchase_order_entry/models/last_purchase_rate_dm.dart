class LastPurchaseRateDm {
  final String poInvno;
  final String date;
  final String pCode;
  final String pName;
  final String iCode;
  final String iName;
  final double qty;
  final double rate;

  LastPurchaseRateDm({
    required this.poInvno,
    required this.date,
    required this.pCode,
    required this.pName,
    required this.iCode,
    required this.iName,
    required this.qty,
    required this.rate,
  });

  factory LastPurchaseRateDm.fromJson(Map<String, dynamic> json) {
    return LastPurchaseRateDm(
      poInvno: json['Invno'] ?? '',
      date: json['Date'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      qty: (json['Qty'] as num?)?.toDouble() ?? 0.0,
      rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
