class SiteMasterDm {
  final String siteCode;
  final String siteName;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String pinCode;
  final String phone;
  final String fax;
  final String email;
  final String pan;
  final String gstNumber;

  SiteMasterDm({
    required this.siteCode,
    required this.siteName,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.phone,
    required this.fax,
    required this.email,
    required this.pan,
    required this.gstNumber,
  });

  factory SiteMasterDm.fromJson(Map<String, dynamic> json) {
    return SiteMasterDm(
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      address1: json['Address1'] ?? '',
      address2: json['Address2'] ?? '',
      city: json['City'] ?? '',
      state: json['State'] ?? '',
      pinCode: json['PinCode'] ?? '',
      phone: json['Phone'] ?? '',
      fax: json['Fax'] ?? '',
      email: json['Email'] ?? '',
      pan: json['Pan'] ?? '',
      gstNumber: json['GSTNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SiteCode': siteCode,
      'SiteName': siteName,
      'Address1': address1,
      'Address2': address2,
      'City': city,
      'State': state,
      'PinCode': pinCode,
      'Phone': phone,
      'Fax': fax,
      'Email': email,
      'Pan': pan,
      'GSTNumber': gstNumber,
    };
  }
}
