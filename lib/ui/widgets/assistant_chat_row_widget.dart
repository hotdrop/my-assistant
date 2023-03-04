import 'package:assistant_me/model/talk.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class AssistantChatRowWidget extends StatelessWidget {
  const AssistantChatRowWidget({super.key, required this.talk});

  final Talk talk;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          elevation: 4.0,
          color: Theme.of(context).colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(talk.message),
          ),
        ),
        LineIcon(LineIcons.robot),
        const SizedBox(width: 4),
      ],
    );
  }
}
