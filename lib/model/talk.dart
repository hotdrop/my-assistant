class Talk {
  const Talk({
    required this.roleType,
    required this.message,
    required this.totalTokenNum,
  });

  factory Talk.create({
    required RoleType roleType,
    required String message,
    required int totalTokenNum,
  }) {
    return Talk(roleType: roleType, message: message, totalTokenNum: totalTokenNum);
  }

  factory Talk.loading() {
    return const Talk(roleType: RoleType.assistant, message: '', totalTokenNum: 0);
  }

  final RoleType roleType;
  final String message;
  final int totalTokenNum;

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
