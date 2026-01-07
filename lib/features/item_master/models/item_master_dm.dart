class ItemMasterDm {
  final String iCode;
  final String iName;
  final String description;
  final String igCode;
  final String igName;
  final String icCode;
  final String icName;
  final String cCode;
  final String cName;
  final String unit;
  final double rate;

  ItemMasterDm({
    required this.iCode,
    required this.iName,
    required this.description,
    required this.igCode,
    required this.igName,
    required this.icCode,
    required this.icName,
    required this.cCode,
    required this.cName,
    required this.unit,
    required this.rate,
  });

  factory ItemMasterDm.fromJson(Map<String, dynamic> json) {
    return ItemMasterDm(
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      description: json['Description'] ?? '',
      igCode: json['IGCode'] ?? '',
      igName: json['IGName'] ?? '',
      icCode: json['ICCode'] ?? '',
      icName: json['ICName'] ?? '',
      cCode: json['CCode'] ?? '',
      cName: json['CName'] ?? '',
      unit: json['Unit'] ?? '',
      rate: json['Rate'] != null
          ? double.tryParse(json['Rate'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ICode': iCode,
      'IName': iName,
      'Description': description,
      'IGCode': igCode,
      'ICCode': icCode,
      'CCode': cCode,
      'Unit': unit,
      'Rate': rate,
    };
  }
}
