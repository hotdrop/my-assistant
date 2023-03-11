import 'package:assistant_me/model/talk.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class UserChatRowWidget extends StatelessWidget {
  const UserChatRowWidget({super.key, required this.talk});

  final Talk talk;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: LineIcon(LineIcons.userCircle),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SelectableText(talk.message),
          ),
        ),
        const SizedBox(width: 32),
      ],
    );
  }
}
