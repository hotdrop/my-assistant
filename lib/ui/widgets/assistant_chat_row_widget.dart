import 'package:assistant_me/model/talk.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AssistantChatRowWidget extends StatelessWidget {
  const AssistantChatRowWidget({super.key, required this.talk});

  final Talk talk;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 32),
        Flexible(
          child: Card(
            elevation: 4.0,
            color: Theme.of(context).colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _talkContentsView(context),
            ),
          ),
        ),
        Image.asset('assets/images/ic_assistant.png', width: 24, height: 24),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _talkContentsView(BuildContext context) {
    if (talk.isLoading()) {
      return LoadingAnimationWidget.prograssiveDots(color: Colors.white, size: 32);
    } else {
      return SelectableText(talk.message, style: const TextStyle(fontSize: 12));
    }
  }
}
