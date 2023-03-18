import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class ViewHistoryCard extends StatelessWidget {
  const ViewHistoryCard({super.key, required this.thread, required this.isSelected, required this.onTap, required this.onDelete});

  final TalkThread thread;
  final bool isSelected;
  final void Function(int) onTap;
  final void Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 100,
      child: Card(
        elevation: 4,
        color: isSelected ? AppTheme.selectedCardColor : null,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ViewContents(thread, onDelete),
                _ViewThreadInfo(thread),
              ],
            ),
          ),
          onTap: () => onTap(thread.id),
        ),
      ),
    );
  }
}

class _ViewContents extends StatelessWidget {
  const _ViewContents(this.thread, this.onDelete);

  final TalkThread thread;
  final void Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    final title = thread.title;
    final titleNoneLine = title.replaceAll('\n', '');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: Text(titleNoneLine, style: Theme.of(context).textTheme.bodySmall)),
        InkWell(
          child: LineIcon(LineIcons.times, color: Colors.grey),
          onLongPress: () => onDelete(thread.id),
        ),
      ],
    );
  }
}

class _ViewThreadInfo extends StatelessWidget {
  const _ViewThreadInfo(this.thread);

  final TalkThread thread;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('トークン数: ${thread.totalTalkTokenNum}', style: Theme.of(context).textTheme.bodySmall),
        Row(
          children: [
            LineIcon(LineIcons.comment, size: 16),
            const SizedBox(width: 4),
            Text(thread.talkNum.toString(), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
