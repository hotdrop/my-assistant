import 'package:assistant_me/common/app_theme.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/model/llm_model.dart';
import 'package:assistant_me/model/talk.dart';
import 'package:assistant_me/model/talk_thread.dart';
import 'package:assistant_me/model/template.dart';
import 'package:assistant_me/ui/home/home_controller.dart';
import 'package:assistant_me/ui/widgets/assistant_chat_row_widget.dart';
import 'package:assistant_me/ui/widgets/image_chat_row_widget.dart';
import 'package:assistant_me/ui/widgets/user_chat_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム画面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _ViewHeader(),
            SizedBox(height: 8),
            _ViewSupportRow(),
            SizedBox(height: 8),
            _ViewInputTalk(),
            _ViewErrorLabel(),
            SizedBox(height: 8),
            _ViewNewThreadButton(),
            Divider(),
            Flexible(
              child: _ViewTalkArea(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewHeader extends ConsumerWidget {
  const _ViewHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useToken = ref.watch(currentUseTokenStateProvider);
    final maxToken = ref.watch(appSettingsProvider.select((value) => value.useLlmModel)).maxContext;
    return Text('現在の利用トークン数: $useToken/$maxToken');
  }
}

class _ViewSupportRow extends StatelessWidget {
  const _ViewSupportRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: const [
        _ViewTemplate(),
        SizedBox(width: 16),
        _ViewUseModel(),
      ],
    );
  }
}

class _ViewTemplate extends ConsumerWidget {
  const _ViewTemplate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templateNotifierProvider);
    const double widgetWidth = 300;

    if (templates.isEmpty) {
      return Container(
        width: widgetWidth,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: Border.all(width: 1, color: Colors.grey),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('テンプレートは登録されていません', style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    return SizedBox(
      width: widgetWidth,
      child: ExpansionTile(
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: BorderSide(width: 1, color: Colors.grey),
        ),
        title: Row(
          children: [
            LineIcon(LineIcons.alternateFileAlt),
            const SizedBox(width: 8),
            Text('テンプレートを使う', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: templates.map((t) => _RowTemplate(t, width: widgetWidth)).toList(),
      ),
    );
  }
}

class _RowTemplate extends ConsumerWidget {
  const _RowTemplate(this.template, {required this.width});

  final Template template;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: width,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(template.title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        onTap: () {
          ref.read(homeControllerProvider.notifier).setTemplate(template.contents);
        },
      ),
    );
  }
}

class _ViewUseModel extends ConsumerWidget {
  const _ViewUseModel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 一度会話を始めたらモデルの変更は抑止
    final isStartTalk = ref.watch(currentTalksProvider).isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: DropdownButton<LlmModel>(
        value: ref.watch(appSettingsProvider).useLlmModel,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 8,
        underline: Container(color: Colors.transparent),
        onChanged: isStartTalk
            ? null
            : (LlmModel? selectValue) {
                if (selectValue != null) {
                  ref.read(homeControllerProvider.notifier).selectModel(selectValue);
                }
              },
        items: LlmModel.values.map<DropdownMenuItem<LlmModel>>((m) {
          return DropdownMenuItem<LlmModel>(
            value: m,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(m.name),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ViewInputTalk extends ConsumerWidget {
  const _ViewInputTalk();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cannotTalk = ref.watch(appSettingsProvider).apiKey?.isEmpty ?? true;
    final emptyInputTalk = ref.watch(isInputTextEmpty);

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: ref.watch(talkControllerProvider),
            minLines: 1,
            maxLines: 10,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
        RawMaterialButton(
          onPressed: (cannotTalk || emptyInputTalk) ? null : () => ref.read(homeControllerProvider.notifier).postTalk(),
          padding: const EdgeInsets.all(8),
          fillColor: (cannotTalk || emptyInputTalk) ? Colors.grey : AppTheme.primaryColor,
          shape: const CircleBorder(),
          child: LineIcon(LineIcons.paperPlane, size: 28, color: Colors.white),
        ),
      ],
    );
  }
}

class _ViewErrorLabel extends ConsumerWidget {
  const _ViewErrorLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMsg = ref.watch(errorProvider);
    if (errorMsg == null) {
      return const SizedBox();
    }

    return Center(
      child: Text(
        errorMsg,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

class _ViewNewThreadButton extends ConsumerWidget {
  const _ViewNewThreadButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: OutlinedButton(
        onPressed: () {
          ref.read(homeControllerProvider.notifier).newThread();
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text('新しく会話を始める'),
        ),
      ),
    );
  }
}

class _ViewTalkArea extends ConsumerWidget {
  const _ViewTalkArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talks = ref.watch(currentTalksProvider);

    return CustomScrollView(
      controller: ref.watch(chatScrollControllerProvider),
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
