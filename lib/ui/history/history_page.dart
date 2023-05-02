import 'package:assistant_me/common/app_extension.dart';
import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/ui/history/history_card.dart';
import 'package:assistant_me/ui/history/history_controller.dart';
import 'package:assistant_me/ui/widgets/app_text.dart';
import 'package:assistant_me/ui/widgets/assistant_chat_row_widget.dart';
import 'package:assistant_me/ui/widgets/image_chat_row_widget.dart';
import 'package:assistant_me/ui/widgets/user_chat_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.pageTitle('履歴'),
      ),
      body: ref.watch(historyControllerProvider).when(
            data: (_) => const _ViewBody(),
            error: (error, stackTrace) => _ViewOnLoading(errorMessage: '$error'),
            loading: () => const _ViewOnLoading(),
          ),
    );
  }
}

class _ViewOnLoading extends StatelessWidget {
  const _ViewOnLoading({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: AppText.error(errorMessage!),
      );
    }

    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(color: Theme.of(context).primaryColor, size: 32),
    );
  }
}

class _ViewBody extends StatelessWidget {
  const _ViewBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _ViewFilterArea(),
          SizedBox(height: 8),
          Expanded(flex: 3, child: _ViewBodyHistories()),
          _ViewThreadCreateDate(),
          _ViewThreadUsageToken(),
          SizedBox(height: 4),
          _ViewThreadSystemRole(),
          Expanded(flex: 7, child: _ViewBodyHistoryTalks()),
        ],
      ),
    );
  }
}

class _ViewFilterArea extends StatelessWidget {
  const _ViewFilterArea();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _ViewSearchField(),
        SizedBox(width: 32),
        _ViewFilterSortIcon(),
        SizedBox(width: 32),
      ],
    );
  }
}

class _ViewSearchField extends ConsumerWidget {
  const _ViewSearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: TextFormField(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(2),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.search),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
        ),
        style: const TextStyle(fontSize: AppTheme.defaultTextSize),
        onFieldSubmitted: (String? text) {
          ref.read(historyControllerProvider.notifier).inputSearchText(text);
        },
      ),
    );
  }
}

class _ViewFilterSortIcon extends ConsumerWidget {
  const _ViewFilterSortIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAsc = ref.watch(historyCreateAtOrderAscStateProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isAsc ? LineIcon(LineIcons.alternateSortAmountDown) : LineIcon(LineIcons.sortAmountUp),
      ),
      onTap: () {
        ref.read(historyControllerProvider.notifier).changeDateSort();
      },
    );
  }
}

class _ViewBodyHistories extends ConsumerWidget {
  const _ViewBodyHistories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(historyThreadsProvider);
    final selectedThreadId = ref.watch(historySelectedThreadIdProvider);

    if (threads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppText.normal('該当する履歴はありません。'),
      );
    }

    return SingleChildScrollView(
      child: Wrap(
        verticalDirection: VerticalDirection.down,
        children: threads
            .map((t) => ViewHistoryCard(
                  thread: t,
                  isSelected: selectedThreadId == t.id,
                  onTap: (int threadId) => ref.read(historyControllerProvider.notifier).onLoadTalks(threadId),
                  onDelete: (int threadId) {
                    ref.read(historyControllerProvider.notifier).deleteThread(threadId);
                  },
                ))
            .toList(),
      ),
    );
  }
}

class _ViewThreadCreateDate extends ConsumerWidget {
  const _ViewThreadCreateDate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThread = ref.watch(historySelectedThreadProvider);
    if (currentThread == null) {
      return const SizedBox();
    }
    return Center(
      child: AppText.normal(
        currentThread.toDateTimeString(),
        textColor: AppTheme.primaryColor,
      ),
    );
  }
}

class _ViewThreadUsageToken extends ConsumerWidget {
  const _ViewThreadUsageToken();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThread = ref.watch(historySelectedThreadProvider);
    if (currentThread == null) {
      return const SizedBox();
    }
    return Center(
      child: AppText.small('(このスレッドの総消費トークン数: ${currentThread.totalUseTokens.toCommaFormat()})', textColor: Colors.grey),
    );
  }
}

class _ViewThreadSystemRole extends ConsumerWidget {
  const _ViewThreadSystemRole();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThread = ref.watch(historySelectedThreadProvider);
    if (currentThread == null) {
      return const SizedBox();
    }

    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: (currentThread.isSettingSystem) ? AppText.small(currentThread.system!) : AppText.small('この会話のSystemは未設定です。', textColor: Colors.grey),
      ),
    );
  }
}

class _ViewBodyHistoryTalks extends ConsumerWidget {
  const _ViewBodyHistoryTalks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talks = ref.watch(historyTalksStateProvider);

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              switch (talks[index].roleType) {
                case RoleType.user:
                  return UserChatRowWidget(talk: talks[index]);
                case RoleType.assistant:
                  return AssistantChatRowWidget(talk: talks[index]);
                case RoleType.image:
                  return ImageChatRowWidget(talk: talks[index]);
                default:
                  throw UnimplementedError('未実装のRoleTypeです。 index=${talks[index].roleType.index}');
              }
            },
            childCount: talks.length,
          ),
        ),
      ],
    );
  }
}
