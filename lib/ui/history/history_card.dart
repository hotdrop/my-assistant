import 'package:assistant_me/model/talk_thread.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class ViewHistoryCard extends StatelessWidget {
  const ViewHistoryCard({super.key, required this.thread, required this.isSelected, required this.onTap});

  final TalkThread thread;
  final bool isSelected;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 100,
      child: Card(
        elevation: 4,
        color: isSelected ? const Color.fromARGB(255, 117, 116, 116) : null,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(thread.title, style: Theme.of(context).textTheme.bodySmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('トークン数: ${thread.totalTokenNum}', style: Theme.of(context).textTheme.bodySmall),
                    _ViewRowTalks(talkNum: thread.talkNum),
                  ],
                ),
              ],
            ),
          ),
          onTap: () => onTap(thread.id),
        ),
      ),
    );
  }
}

class _ViewRowTalks extends StatelessWidget {
  const _ViewRowTalks({required this.talkNum});

  final int talkNum;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LineIcon(LineIcons.comment, size: 16),
        const SizedBox(width: 4),
        Text(talkNum.toString(), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
