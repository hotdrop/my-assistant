import 'package:assistant_me/data/template_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final templateNotifierProvider = NotifierProvider<TemplateNotifier, List<Template>>(TemplateNotifier.new);

class TemplateNotifier extends Notifier<List<Template>> {
  @override
  List<Template> build() {
    return [];
  }

  Future<void> onLoad() async {
    state = await ref.read(templateRepositoryProvider).findAll();
  }

  Future<void> add({required String title, required String contents}) async {
    final template = await ref.read(templateRepositoryProvider).create(
          title: title,
          contents: contents,
        );
    state = [...state, template];
  }

  Future<void> update(Template newTemplate) async {
    await ref.read(templateRepositoryProvider).update(newTemplate);
    final idx = state.indexWhere((t) => t.id == newTemplate.id);
    state = List.of(state)..[idx] = newTemplate;
  }

  Future<void> delete(Template template) async {
    await ref.read(templateRepositoryProvider).delete(template.id);
    final l = state;
    l.remove(template);
    state = [...l];
  }
}

class Template {
  const Template({
    required this.id,
    required this.title,
    required this.contents,
  });

  final int id;
  final String title;
  final String contents;
}
