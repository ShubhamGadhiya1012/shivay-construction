class CompanyMasterDm {
  final int coCode;
  final String name;
  final String address1;
  final String address2;
  final String city;
  final String zip;
  final String state;
  final String country;
  final String pan;
  final String phone;
  final String fax;
  final String email;
  final String url;
  final String gstNumber;
  final String cinNo;
  final String msmeNo;
  final String uan;
  final String ptCode;
  final String estCode;
  final String pfCode;
  final String esiCode;
  final String mgmtEmail;
  final String coBankName1;
  final String coBankBranch1;
  final String coBankAcNo1;
  final String coBankIfsc1;
  final String coBankName2;
  final String coBankBranch2;
  final String coBankAcNo2;
  final String coBankIfsc2;

  CompanyMasterDm({
    required this.coCode,
    required this.name,
    required this.address1,
    required this.address2,
    required this.city,
    required this.zip,
    required this.state,
    required this.country,
    required this.pan,
    required this.phone,
    required this.fax,
    required this.email,
    required this.url,
    required this.gstNumber,
    required this.cinNo,
    required this.msmeNo,
    required this.uan,
    required this.ptCode,
    required this.estCode,
    required this.pfCode,
    required this.esiCode,
    required this.mgmtEmail,
    required this.coBankName1,
    required this.coBankBranch1,
    required this.coBankAcNo1,
    required this.coBankIfsc1,
    required this.coBankName2,
    required this.coBankBranch2,
    required this.coBankAcNo2,
    required this.coBankIfsc2,
  });

  factory CompanyMasterDm.fromJson(Map<String, dynamic> json) {
    return CompanyMasterDm(
      coCode: json['CoCode'] ?? 0,
      name: json['Name'] ?? '',
      address1: json['Address1'] ?? '',
      address2: json['Address2'] ?? '',
      city: json['City'] ?? '',
      zip: json['Zip'] ?? '',
      state: json['State'] ?? '',
      country: json['Country'] ?? '',
      pan: json['PAN'] ?? '',
      phone: json['Phone'] ?? '',
      fax: json['Fax'] ?? '',
      email: json['Email'] ?? '',
      url: json['URL'] ?? '',
      gstNumber: json['GSTNumber'] ?? '',
      cinNo: json['CINNo'] ?? '',
      msmeNo: json['MSMENo'] ?? '',
      uan: json['UAN'] ?? '',
      ptCode: json['PTCode'] ?? '',
      estCode: json['ESTCode'] ?? '',
      pfCode: json['PFCode'] ?? '',
      esiCode: json['ESICode'] ?? '',
      mgmtEmail: json['MgmtEMail'] ?? '',
      coBankName1: json['CoBankName1'] ?? '',
      coBankBranch1: json['CoBankBranch1'] ?? '',
      coBankAcNo1: json['CoBankAcNo1'] ?? '',
      coBankIfsc1: json['CoBankIFSC1'] ?? '',
      coBankName2: json['CoBankName2'] ?? '',
      coBankBranch2: json['CoBankBranch2'] ?? '',
      coBankAcNo2: json['CoBankAcNo2'] ?? '',
      coBankIfsc2: json['CoBankIFSC2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CoCode': coCode,
      'Name': name,
      'Address1': address1,
      'Address2': address2,
      'City': city,
      'Zip': zip,
      'State': state,
      'Country': country,
      'PAN': pan,
      'Phone': phone,
      'Fax': fax,
      'Email': email,
      'URL': url,
      'GSTNumber': gstNumber,
      'CINNo': cinNo,
      'MSMENo': msmeNo,
      'UAN': uan,
      'PTCode': ptCode,
      'ESTCode': estCode,
      'PFCode': pfCode,
      'ESICode': esiCode,
      'MgmtEMail': mgmtEmail,
      'CoBankName1': coBankName1,
      'CoBankBranch1': coBankBranch1,
      'CoBankAcNo1': coBankAcNo1,
      'CoBankIFSC1': coBankIfsc1,
      'CoBankName2': coBankName2,
      'CoBankBranch2': coBankBranch2,
      'CoBankAcNo2': coBankAcNo2,
      'CoBankIFSC2': coBankIfsc2,
    };
  }
}
