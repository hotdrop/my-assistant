import 'package:assistant_me/model/talk.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class UserChatRowWidget extends StatelessWidget {
  const UserChatRowWidget({super.key, required this.talk});

  final Talk talk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            LineIcon(LineIcons.userCircle),
            Flexible(
              child: Card(
                elevation: 4.0,
                color: Theme.of(context).colorScheme.background,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SelectableText(talk.message, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ),
            const SizedBox(width: 32),
          ],
        ),
      ],
    );
  }
}
