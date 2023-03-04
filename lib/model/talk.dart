class Talk {
  const Talk({required this.id, required this.roleType, required this.message, required this.totalTokenNum});

  factory Talk.create({required int id, required RoleType roleType, required String message, required int totalTokenNum}) {
    return Talk(id: id, roleType: roleType, message: message, totalTokenNum: totalTokenNum);
  }

  factory Talk.loading() {
    return const Talk(id: _loadingId, roleType: RoleType.assistant, message: '', totalTokenNum: 0);
  }

  // このIDはAPIのものではなくアプリ側で管理するID
  final int id;
  final RoleType roleType;
  final String message;
  final int totalTokenNum;

  static const int _loadingId = -100;

  static RoleType toRoleType(String roleName) {
    if (roleName == RoleType.user.roleStr) {
      return RoleType.user;
    } else {
      return RoleType.assistant;
    }
  }

  // このトークがロード中かを取得する。ロード中状態を別にもつのは嫌だったので既存のフィールドで判別することにした。
  bool isLoading() => (id == _loadingId) && (message.isEmpty) && (totalTokenNum == 0) && (roleType == RoleType.assistant);

  bool isRoleTypeUser() => roleType == RoleType.user;
}

enum RoleType {
  user("user"),
  assistant("assistant");

  final String roleStr;

  const RoleType(this.roleStr);
}
