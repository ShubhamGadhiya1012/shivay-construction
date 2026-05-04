class HsnMasterDetailDm {
  final String hsnNo;
  final double igst;
  final double sgst;
  final double cgst;
  final String effectDate;
  final String tCode;
  final String tName; // ADD THIS
  final double lgst;

  HsnMasterDetailDm({
    required this.hsnNo,
    required this.igst,
    required this.sgst,
    required this.cgst,
    required this.effectDate,
    required this.tCode,
    required this.tName, // ADD THIS
    required this.lgst,
  });

  factory HsnMasterDetailDm.fromJson(Map<String, dynamic> json) {
    return HsnMasterDetailDm(
      hsnNo: json['HSNNO'] ?? '',
      igst: (json['IGST'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['SGST'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['CGST'] as num?)?.toDouble() ?? 0.0,
      effectDate: json['EffectDate'] ?? '',
      tCode: json['TCode'] ?? '',
      tName: json['TName'] ?? '', // ADD THIS
      lgst: (json['LGST'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
