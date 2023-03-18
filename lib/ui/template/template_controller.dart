import 'package:assistant_me/data/template_repository.dart';
import 'package:assistant_me/model/template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'template_controller.g.dart';

@riverpod
class TemplateController extends _$TemplateController {
  static const int unselecId = 0;

  @override
  Future<void> build() async {
    await _refresh();
  }

  void select(int id) {
    final selectedId = ref.read(selectTemplateIdStateProvider);

    // 同じ行を選択したら解除する
    if (selectedId == id) {
      _clear();
      return;
    }

    ref.read(selectTemplateIdStateProvider.notifier).state = id;
    final target = ref.read(templatesStateProvider).where((t) => t.id == id).first;
    ref.read(titleControllerStateProvider).text = target.title;
    ref.read(contentsControllerStateProvider).text = target.contents;
  }

  ///
  /// テンプレートを新規登録する
  ///
  Future<void> createTemplate() async {
    final inputTitle = ref.read(titleControllerStateProvider).text;
    final inputContents = ref.read(contentsControllerStateProvider).text;
    if (inputTitle.isEmpty || inputContents.isEmpty) {
      return;
    }

    await ref.read(templateRepositoryProvider).create(
          title: inputTitle,
          contents: inputContents,
        );
    await _refresh();
  }

  ///
  /// 既存のテンプレートを更新する
  ///
  Future<void> updateTemplate() async {
    final inputTitle = ref.read(titleControllerStateProvider).text;
    final inputContents = ref.read(contentsControllerStateProvider).text;
    if (inputTitle.isEmpty || inputContents.isEmpty) {
      return;
    }

    // 同じ値であれば無視
    final selectId = ref.read(selectTemplateIdStateProvider);
    final t = ref.watch(templatesStateProvider).where((t) => t.id == selectId).first;
    if (t.title == inputTitle && t.contents == inputContents) {
      return;
    }

    final updateTemplate = Template(
      id: ref.read(selectTemplateIdStateProvider),
      title: inputTitle,
      contents: inputContents,
    );
    await ref.read(templateRepositoryProvider).update(updateTemplate);
    await _refresh();
  }

  ///
  /// テンプレートを削除する
  ///
  Future<void> deleteTemplate(Template template) async {
    await ref.read(templateRepositoryProvider).delete(template);
    await _refresh();
  }

  Future<void> _refresh() async {
    final templates = await ref.read(templateRepositoryProvider).findAll();
    ref.read(templatesStateProvider.notifier).state = templates;
    _clear();
  }

  void _clear() {
    ref.read(selectTemplateIdStateProvider.notifier).state = unselecId;
    ref.read(titleControllerStateProvider).clear();
    ref.read(contentsControllerStateProvider).clear();
  }
}

// テンプレートのリスト
final templatesStateProvider = StateProvider<List<Template>>((_) => []);

// 選択中のテンプレートID
final selectTemplateIdStateProvider = StateProvider<int>((_) => TemplateController.unselecId);

// タイトルの入力フォームコントローラ
final titleControllerStateProvider = StateProvider((_) => TextEditingController());

// テンプレートの入力フォームコントローラ
final contentsControllerStateProvider = StateProvider((_) => TextEditingController());
