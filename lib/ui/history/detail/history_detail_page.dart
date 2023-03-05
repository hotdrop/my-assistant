import 'package:assistant_me/ui/history/detail/history_detail_controller.dart';
import 'package:assistant_me/ui/widgets/assistant_chat_row_widget.dart';
import 'package:assistant_me/ui/widgets/user_chat_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HistoryDetailPage extends ConsumerWidget {
  const HistoryDetailPage._({required this.threadId});

  static Future<void> start(BuildContext context, int threadId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryDetailPage._(threadId: threadId)),
    );
  }

  final int threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('履歴')),
      body: ref.watch(historyDetailControllerProvider(threadId)).when(
            data: (_) => const _ViewBody(),
            error: (error, stackTrace) => _ViewOnError('$error'),
            loading: () => const _ViewOnLoading(),
          ),
    );
  }
}

class _ViewOnLoading extends StatelessWidget {
  const _ViewOnLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.dotsTriangle(color: Theme.of(context).primaryColor, size: 32),
    );
  }
}

class _ViewOnError extends StatelessWidget {
  const _ViewOnError(this.errorMessage);

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
    );
  }
}

class _ViewBody extends ConsumerWidget {
  const _ViewBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talks = ref.watch(talksStateProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final isUser = talks[index].isRoleTypeUser();
                if (isUser) {
                  return UserChatRowWidget(talk: talks[index]);
                } else {
                  return AssistantChatRowWidget(talk: talks[index]);
                }
              },
              childCount: talks.length,
            ),
          ),
        ],
      ),
    );
  }
}
