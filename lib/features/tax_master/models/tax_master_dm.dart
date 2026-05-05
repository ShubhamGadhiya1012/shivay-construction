class TaxMasterDm {
  final String tCode;
  final String taxName;
  final bool igst;
  final bool cgst;
  final bool sgst;

  TaxMasterDm({
    required this.tCode,
    required this.taxName,
    required this.igst,
    required this.cgst,
    required this.sgst,
  });

  factory TaxMasterDm.fromJson(Map<String, dynamic> json) {
    return TaxMasterDm(
      tCode: json['TCode'] ?? '',
      taxName: json['TName'] ?? '',
      igst: json['IGST'] ?? false,
      cgst: json['CGST'] ?? false,
      sgst: json['SGST'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TCode': tCode,
      'TName': taxName,
      'IGST': igst,
      'CGST': cgst,
      'SGST': sgst,
    };
  }
}
