class UserDm {
  final int userId;
  final String fullName;
  final bool appAccess;
  final bool indentAuth;
  final bool poAuth;
  final String mobileNo;
  final int userType;
  final String seCodes;
  final String pCodes;
  final String gdCodes;
  final String coCodes;

  UserDm({
    required this.userId,
    required this.fullName,
    required this.appAccess,
    required this.indentAuth,
    required this.poAuth,
    required this.mobileNo,
    required this.userType,
    required this.seCodes,
    required this.pCodes,
    required this.gdCodes,
    required this.coCodes,
  });

  factory UserDm.fromJson(Map<String, dynamic> json) {
    return UserDm(
      userId: int.tryParse(json['UserId']?.toString() ?? '') ?? 0,

      fullName: json['FULLNAME']?.toString() ?? '',

      appAccess:
          json['AppAccess'] == true ||
          json['AppAccess']?.toString() == 'true' ||
          json['AppAccess']?.toString() == '1',

      indentAuth:
          json['IndentAuth'] == true ||
          json['IndentAuth']?.toString() == 'true' ||
          json['IndentAuth']?.toString() == '1',

      poAuth:
          json['POAuth'] == true ||
          json['POAuth']?.toString() == 'true' ||
          json['POAuth']?.toString() == '1',

      mobileNo: json['MOBILENO']?.toString() ?? '',

      userType: int.tryParse(json['USERTYPE']?.toString() ?? '') ?? 0,

      seCodes: json['SECODEs']?.toString() ?? '',

      pCodes: json['PCODEs']?.toString() ?? '',

      gdCodes: json['GDCODEs']?.toString() ?? '',

      coCodes: json['CoCodes']?.toString() ?? '',
    );
  }
}
