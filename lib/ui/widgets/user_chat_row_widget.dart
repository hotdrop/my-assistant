import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:flutter/material.dart';

class UserChatRowWidget extends StatelessWidget {
  const UserChatRowWidget({super.key, required Talk talk}) : messageTalk = (talk as Message);

  final Message messageTalk;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Icon(Icons.person_pin),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SelectableText(
              messageTalk.getValue(),
              style: const TextStyle(fontSize: AppTheme.defaultTextSize),
            ),
          ),
        ),
        const SizedBox(width: 32),
      ],
    );
  }
}
