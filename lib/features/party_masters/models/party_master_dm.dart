class PartyMasterDm {
  final String pCode;
  final String accountName;
  final String printName;
  final String location;
  final String addressLine1;
  final String addressLine2;
  final String addressLine3;
  final String city;
  final String state;
  final String pinCode;
  final String personName;
  final String phone1;
  final String phone2;
  final String mobile;
  final String gstNumber;
  final String pan;

  PartyMasterDm({
    required this.pCode,
    required this.accountName,
    required this.printName,
    required this.location,
    required this.addressLine1,
    required this.addressLine2,
    required this.addressLine3,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.personName,
    required this.phone1,
    required this.phone2,
    required this.mobile,
    required this.gstNumber,
    required this.pan,
  });

  factory PartyMasterDm.fromJson(Map<String, dynamic> json) {
    return PartyMasterDm(
      pCode: json['PCode'] ?? '',
      accountName: json['AccountName'] ?? '',
      printName: json['PrintName'] ?? '',
      location: json['Location'] ?? '',
      addressLine1: json['AddressLine1'] ?? '',
      addressLine2: json['AddressLine2'] ?? '',
      addressLine3: json['AddressLine3'] ?? '',
      city: json['City'] ?? '',
      state: json['State'] ?? '',
      pinCode: json['PinCode'] ?? '',
      personName: json['PersonName'] ?? '',
      phone1: json['Phone1'] ?? '',
      phone2: json['Phone2'] ?? '',
      mobile: json['Mobile'] ?? '',
      gstNumber: json['GSTNumber'] ?? '',
      pan: json['Pan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PCode': pCode,
      'AccountName': accountName,
      'PrintName': printName,
      'Location': location,
      'AddressLine1': addressLine1,
      'AddressLine2': addressLine2,
      'AddressLine3': addressLine3,
      'City': city,
      'State': state,
      'PinCode': pinCode,
      'PersonName': personName,
      'Phone1': phone1,
      'Phone2': phone2,
      'Mobile': mobile,
      'GSTNumber': gstNumber,
      'PANNumber': pan,
    };
  }
}
