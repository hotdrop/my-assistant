class Talk {
  const Talk({
    required this.roleType,
    required this.message,
    required this.tokenNum,
  });

  factory Talk.create({
    required RoleType roleType,
    required String message,
    required int tokenNum,
  }) {
    return Talk(roleType: roleType, message: message, tokenNum: tokenNum);
  }

  factory Talk.loading() {
    return const Talk(roleType: RoleType.assistant, message: '', tokenNum: 0);
  }

  final RoleType roleType;
  final String message;
  final int tokenNum;

  // このトークがロード中か？
  // ロード中状態を別にもつのは嫌だったので既存のフィールドで判別することにした。
  bool isLoading() => (message.isEmpty) && (roleType == RoleType.assistant);

  bool isRoleTypeUser() => roleType == RoleType.user;

  static RoleType toRoleType(String roleName) {
    if (roleName == RoleType.user.roleStr) {
      return RoleType.user;
    } else {
      return RoleType.assistant;
    }
  }

  static RoleType toRole(int index) {
    if (RoleType.user.index == index) {
      return RoleType.user;
    } else {
      return RoleType.assistant;
    }
  }
}

enum RoleType {
  user("user"),
  assistant("assistant");

  final String roleStr;

  const RoleType(this.roleStr);
}
