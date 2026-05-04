class TermMasterDm {
  final String termCode;
  final String termName;
  final String termType;
  final bool isFix;

  TermMasterDm({
    required this.termCode,
    required this.termName,
    required this.termType,
    required this.isFix,
  });

  factory TermMasterDm.fromJson(Map<String, dynamic> json) {
    return TermMasterDm(
      termCode: json['TermCode'] ?? '',
      termName: json['TermName'] ?? '',
      termType: json['TermType'] ?? '',
      isFix: json['IsFix'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TermCode': termCode,
      'TermName': termName,
      'TermType': termType,
      'IsFix': isFix,
    };
  }
}
