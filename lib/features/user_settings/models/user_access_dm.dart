class UserAccessDm {
  final List<MenuAccessDm> menuAccess;
  final LedgerDateDm ledgerDate;

  UserAccessDm({required this.menuAccess, required this.ledgerDate});

  factory UserAccessDm.fromJson(Map<String, dynamic> json) {
    return UserAccessDm(
      menuAccess: (json['menuAceess'] as List)
          .map((item) => MenuAccessDm.fromJson(item))
          .toList(),
      ledgerDate: LedgerDateDm.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuAceess': menuAccess.map((menu) => menu.toJson()).toList(),
      'data': ledgerDate.toJson(),
    };
  }
}

class MenuAccessDm {
  final int menuId;
  final String menuName;
  bool access;
  final List<SubMenuAccessDm> subMenu;

  MenuAccessDm({
    required this.menuId,
    required this.menuName,
    required this.access,
    required this.subMenu,
  });

  factory MenuAccessDm.fromJson(Map<String, dynamic> json) {
    return MenuAccessDm(
      menuId: json['menuid'] ?? 0,
      menuName: json['menuname'] ?? '',
      access: json['access'] ?? false,
      subMenu: json['subMenu'] != null
          ? (json['subMenu'] as List)
                .map((item) => SubMenuAccessDm.fromJson(item))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuid': menuId,
      'menuname': menuName,
      'access': access,
      'subMenu': subMenu.map((subMenu) => subMenu.toJson()).toList(),
    };
  }
}

class SubMenuAccessDm {
  final int subMenuId;
  final String subMenuName;
  bool subMenuAccess;

  SubMenuAccessDm({
    required this.subMenuId,
    required this.subMenuName,
    required this.subMenuAccess,
  });

  factory SubMenuAccessDm.fromJson(Map<String, dynamic> json) {
    return SubMenuAccessDm(
      subMenuId: json['submenuid'] ?? 0,
      subMenuName: json['submenuname'] ?? '',
      subMenuAccess: json['subMenuAccess'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'submenuid': subMenuId,
      'submenuname': subMenuName,
      'subMenuAccess': subMenuAccess,
    };
  }
}

class LedgerDateDm {
  final String ledgerStart;
  final String ledgerEnd;

  LedgerDateDm({required this.ledgerStart, required this.ledgerEnd});

  factory LedgerDateDm.fromJson(Map<String, dynamic> json) {
    return LedgerDateDm(
      ledgerStart: json['LedgerStart'] ?? '',
      ledgerEnd: json['LedgerEnd'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'LedgerStart': ledgerStart, 'LedgerEnd': ledgerEnd};
  }
}
