import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/ui/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// ignore: depend_on_referenced_packages
import 'package:markdown/markdown.dart' as md;

class AssistantChatRowWidget extends StatelessWidget {
  const AssistantChatRowWidget({super.key, required Talk talk}) : messageTalk = (talk as Message);

  final Message messageTalk;

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
        InkWell(
          onTap: () {
            final t = ClipboardData(text: messageTalk.getValue());
            Clipboard.setData(t);
          },
          child: Image.asset('assets/images/ic_assistant.png', width: 24, height: 24),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _talkContentsView(BuildContext context) {
    if (messageTalk.isLoading()) {
      return LoadingAnimationWidget.prograssiveDots(color: Colors.white, size: 32);
    } else {
      return Markdown(
        selectable: true,
        data: messageTalk.getValue(),
        shrinkWrap: true,
        builders: {
          'code': _CodeElementBuilder(),
        },
      );
    }
  }
}

class _CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String? codeClass = element.attributes['class'];
    if (codeClass == null) {
      return AppText.normal(element.textContent, textColor: Colors.orange);
    }

    final lang = codeClass.substring(9);
    return Column(
      children: [
        _HeaderWidget(language: lang, textContents: element.textContent),
        _ContentsWidget(language: lang, textContents: element.textContent),
      ],
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({required this.language, required this.textContents});

  final String language;
  final String textContents;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: AppText.normal(language),
        ),
        IconButton(
          onPressed: () {
            final t = ClipboardData(text: textContents);
            Clipboard.setData(t);
          },
          tooltip: 'クリップボードにコピーします',
          icon: LineIcon(LineIcons.clipboard),
        ),
      ],
    );
  }
}

class _ContentsWidget extends StatelessWidget {
  const _ContentsWidget({required this.language, required this.textContents});

  final String language;
  final String textContents;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: HighlightView(
        textContents,
        language: language,
        padding: const EdgeInsets.all(8),
        theme: atomOneDarkTheme,
        textStyle: const TextStyle(fontSize: AppTheme.defaultTextSize),
      ),
    );
  }
}
