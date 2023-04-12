abstract class Talk {
  // このトークがロード中か？
  // ロード中状態を別にもつのは嫌だったので既存のフィールドで判別することにした。
  bool isLoading();

  RoleType get roleType;

  Object getValue();

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
    } else if (RoleType.assistant.index == index) {
      return RoleType.assistant;
    } else if (RoleType.image.index == index) {
      return RoleType.image;
    } else {
      throw UnimplementedError('未実装のindex $index');
    }
  }
}

class Message extends Talk {
  Message(this._roleType, this._value, this.tokenNum);

  factory Message.create({required RoleType roleType, required String value, required int tokenNum}) {
    return Message(roleType, value, tokenNum);
  }

  factory Message.loading() {
    return Message(RoleType.assistant, '', 0);
  }

  final RoleType _roleType;
  final String _value;
  final int tokenNum;

  @override
  String getValue() => _value;

  @override
  bool isLoading() => (_value.isEmpty) && (_roleType != RoleType.assistant);

  @override
  RoleType get roleType => _roleType;
}

class ImageTalk extends Talk {
  ImageTalk._(this._urls);

  factory ImageTalk.create({required List<String> urls}) {
    return ImageTalk._(urls);
  }

  final List<String> _urls;
  static const String urlJoinStringSeparate = ',';

  @override
  List<String> getValue() => _urls;

  // Image Talkはロード中にはしない
  @override
  bool isLoading() => false;

  @override
  RoleType get roleType => RoleType.image;
}

enum RoleType {
  user('user'),
  assistant('assistant'),
  image('image');

  final String roleStr;

  const RoleType(this.roleStr);
}
