import 'package:assistant_me/model/talk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// ignore: depend_on_referenced_packages
import 'package:markdown/markdown.dart' as md;

class AssistantChatRowWidget extends StatelessWidget {
  const AssistantChatRowWidget({super.key, required this.talk});

  final Talk talk;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 32),
        Flexible(
          child: Card(
            elevation: 1.0,
            color: Theme.of(context).colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _talkContentsView(context),
            ),
          ),
        ),
        Image.asset('assets/images/ic_assistant.png', width: 24, height: 24),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _talkContentsView(BuildContext context) {
    if (talk.isLoading()) {
      return LoadingAnimationWidget.prograssiveDots(color: Colors.white, size: 32);
    } else {
      return Markdown(
        selectable: true,
        data: talk.message,
        shrinkWrap: true,
        builders: {
          'pre': _CustomPreBuilder(),
        },
      );
    }
  }
}

class _CustomPreBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return _PreWidget(text.text);
  }
}

class _PreWidget extends StatelessWidget {
  const _PreWidget(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PreHeaderWidget(text),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              text,
              // ここ本当はシンタックスハイライトにしたい・・
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreHeaderWidget extends StatelessWidget {
  const _PreHeaderWidget(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text('code', style: Theme.of(context).textTheme.bodySmall),
        ),
        IconButton(
          onPressed: () {
            final t = ClipboardData(text: text);
            Clipboard.setData(t);
          },
          tooltip: 'クリップボードにコピーします',
          icon: LineIcon(LineIcons.clipboard, size: 16),
        ),
      ],
    );
  }
}
