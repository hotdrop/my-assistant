import 'package:intl/intl.dart';

class Talk {
  const Talk({
    required this.dateTime,
    required this.roleType,
    required this.message,
    required this.totalTokenNum,
  });

  factory Talk.create({
    required DateTime dateTime,
    required RoleType roleType,
    required String message,
    required int totalTokenNum,
  }) {
    return Talk(dateTime: dateTime, roleType: roleType, message: message, totalTokenNum: totalTokenNum);
  }

  factory Talk.loading() {
    return Talk(dateTime: DateTime.now(), roleType: RoleType.assistant, message: '', totalTokenNum: 0);
  }

  final DateTime dateTime;
  final RoleType roleType;
  final String message;
  final int totalTokenNum;

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

  // このトークがロード中かを取得する。ロード中状態を別にもつのは嫌だったので既存のフィールドで判別することにした。
  bool isLoading() => (message.isEmpty) && (roleType == RoleType.assistant);

  bool isRoleTypeUser() => roleType == RoleType.user;

  static final _dateFormat = DateFormat('yyyy/MM/dd hh:mm');
  String toDateTimeString() => _dateFormat.format(dateTime);
}

enum RoleType {
  user("user"),
  assistant("assistant");

  final String roleStr;

  const RoleType(this.roleStr);
}
