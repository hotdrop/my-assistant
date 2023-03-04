class Talk {
  const Talk({required this.id, required this.roleType, required this.talk, required this.totalTokenNum});

  final String id;
  final RoleType roleType;
  final String talk;
  final int totalTokenNum;

  static RoleType toRoleType(String roleName) {
    if (roleName == RoleType.user.roleStr) {
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
