class OrderPrintDm {
  final CompanyDataDm companyData;
  final OrderHeaderDm orderHeader;
  final List<OrderItemDm> items;
  final List<OrderNoteDm> notes;
  final List<OrderSummaryDm> summary;

  OrderPrintDm({
    required this.companyData,
    required this.orderHeader,
    required this.items,
    required this.notes,
    required this.summary,
  });

  factory OrderPrintDm.fromJson(Map<String, dynamic> json) {
    final data1 = json['data1'] as List<dynamic>? ?? [];
    final data2 = json['data2'] as List<dynamic>? ?? [];
    final data3 = json['data3'] as List<dynamic>? ?? [];
    final data4 = json['data4'] as List<dynamic>? ?? [];
    final data5 = json['data5'] as List<dynamic>? ?? [];

    return OrderPrintDm(
      companyData: CompanyDataDm.fromJson(
        data1.isNotEmpty ? data1.first : <String, dynamic>{},
      ),
      orderHeader: OrderHeaderDm.fromJson(
        data2.isNotEmpty ? data2.first : <String, dynamic>{},
      ),
      items: data3.map((e) => OrderItemDm.fromJson(e)).toList(),
      notes: data4.map((e) => OrderNoteDm.fromJson(e)).toList(),
      summary: data5.map((e) => OrderSummaryDm.fromJson(e)).toList(),
    );
  }
}

// ─── Company (data1) ────────────────────────────────────────────────────────

class CompanyDataDm {
  final String name;
  final String address1;
  final String address2;
  final String city;
  final String zip;
  final String state;
  final String country;
  final String gstNumber;
  final String pan;
  final String email;
  final String mgmtEmail;

  CompanyDataDm({
    required this.name,
    required this.address1,
    required this.address2,
    required this.city,
    required this.zip,
    required this.state,
    required this.country,
    required this.gstNumber,
    required this.pan,
    required this.email,
    required this.mgmtEmail,
  });

  factory CompanyDataDm.fromJson(Map<String, dynamic> json) {
    return CompanyDataDm(
      name: json['Name'] ?? '',
      address1: json['Address1'] ?? '',
      address2: json['Address2'] ?? '',
      city: json['City'] ?? '',
      zip: json['Zip'] ?? '',
      state: json['State'] ?? '',
      country: json['Country'] ?? '',
      gstNumber: json['GstNumber'] ?? '',
      pan: json['Pan'] ?? '',
      email: json['Email'] ?? '',
      mgmtEmail: json['MgmtEmail'] ?? '',
    );
  }
}

// ─── Order Header (data2) ────────────────────────────────────────────────────

class OrderHeaderDm {
  final String invNo;
  final String date;
  final double amount;
  final String pCode;
  final String pName;
  final String pGst;
  final String pPan;
  final String pContactPerson;
  final String pPhone;
  final String pMobile;
  final String pAdd1;
  final String pAdd2;
  final String pAdd3;
  final String pCity;
  final String pState;
  final String pPinCode;
  final String pEmail;
  final String siteName;
  final String sAdd1;
  final String sAdd2;
  final String sCity;
  final String sState;
  final String phone;
  final String sEmail;
  final String sPinCode;

  OrderHeaderDm({
    required this.invNo,
    required this.date,
    required this.amount,
    required this.pCode,
    required this.pName,
    required this.pGst,
    required this.pPan,
    required this.pContactPerson,
    required this.pPhone,
    required this.pMobile,
    required this.pAdd1,
    required this.pAdd2,
    required this.pAdd3,
    required this.pCity,
    required this.pState,
    required this.pPinCode,
    required this.pEmail,
    required this.siteName,
    required this.sAdd1,
    required this.sAdd2,
    required this.sCity,
    required this.sState,
    required this.phone,
    required this.sEmail,
    required this.sPinCode,
  });

  factory OrderHeaderDm.fromJson(Map<String, dynamic> json) {
    return OrderHeaderDm(
      invNo: json['Invno'] ?? '',
      date: json['Date'] ?? '',
      amount: (json['Amount'] ?? 0).toDouble(),
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      pGst: json['PGST'] ?? '',
      pPan: json['PPan'] ?? '',
      pContactPerson: json['PContactPerson'] ?? '',
      pPhone: json['PPhone'] ?? '',
      pMobile: json['PMobile'] ?? '',
      pAdd1: json['PAdd1'] ?? '',
      pAdd2: json['PAdd2'] ?? '',
      pAdd3: json['PAdd3'] ?? '',
      pCity: json['PCity'] ?? '',
      pState: json['PState'] ?? '',
      pPinCode: json['PPinCode'] ?? '',
      pEmail: json['PEmail'] ?? '',
      siteName: json['SiteName'] ?? '',
      sAdd1: json['SAdd1'] ?? '',
      sAdd2: json['SAdd2'] ?? '',
      sCity: json['SCity'] ?? '',
      sState: json['SState'] ?? '',
      phone: json['PHone'] ?? '',
      sEmail: json['SEmail'] ?? '',
      sPinCode: json['SPinCode'] ?? '',
    );
  }
}

// ─── Order Item (data3) ──────────────────────────────────────────────────────

class OrderItemDm {
  final String iCode;
  final String iName;
  final double qty;
  final String unit;
  final double rate;
  final double amount;
  final double discA;
  final double discP;
  final double gstNetAmount;
  final double valueOfGoods;
  final double valueOfRate;
  final double igstPerc;
  final double igstAmt;
  final double sgstPerc;
  final double sgstAmt;
  final double cgstPerc;
  final double cgstAmt;

  OrderItemDm({
    required this.iCode,
    required this.iName,
    required this.qty,
    required this.unit,
    required this.rate,
    required this.amount,
    required this.discA,
    required this.discP,
    required this.gstNetAmount,
    required this.valueOfGoods,
    required this.valueOfRate,
    required this.igstPerc,
    required this.igstAmt,
    required this.sgstPerc,
    required this.sgstAmt,
    required this.cgstPerc,
    required this.cgstAmt,
  });

  factory OrderItemDm.fromJson(Map<String, dynamic> json) {
    return OrderItemDm(
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      qty: (json['Qty'] ?? 0).toDouble(),
      unit: json['Unit'] ?? '',
      rate: (json['Rate'] ?? 0).toDouble(),
      amount: (json['AMOUNT'] ?? 0).toDouble(),
      discA: (json['Disc_A'] ?? 0).toDouble(),
      discP: (json['Disc_P'] ?? 0).toDouble(),
      gstNetAmount: (json['GSTNetAmount'] ?? 0).toDouble(),
      valueOfGoods: (json['ValueOfGoods'] ?? 0).toDouble(),
      valueOfRate: (json['ValueOfRate'] ?? 0).toDouble(),
      igstPerc: (json['IGSTPERC'] ?? 0).toDouble(),
      igstAmt: (json['IGSTAMT'] ?? 0).toDouble(),
      sgstPerc: (json['SGSTPERC'] ?? 0).toDouble(),
      sgstAmt: (json['SGSTAMT'] ?? 0).toDouble(),
      cgstPerc: (json['CGSTPERC'] ?? 0).toDouble(),
      cgstAmt: (json['CGSTAMT'] ?? 0).toDouble(),
    );
  }
}

// ─── Order Note (data4) ──────────────────────────────────────────────────────

class OrderNoteDm {
  final String description;

  OrderNoteDm({required this.description});

  factory OrderNoteDm.fromJson(Map<String, dynamic> json) {
    return OrderNoteDm(description: json['Description'] ?? '');
  }
}

// ─── Order Summary (data5) ───────────────────────────────────────────────────

class OrderSummaryDm {
  final String description;
  final double amount;

  OrderSummaryDm({required this.description, required this.amount});

  factory OrderSummaryDm.fromJson(Map<String, dynamic> json) {
    return OrderSummaryDm(
      description: json['Description'] ?? '',
      amount: (json['Amount'] ?? 0).toDouble(),
    );
  }
}
