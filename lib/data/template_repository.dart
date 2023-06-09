import 'package:assistant_me/data/local/dao/template_dao.dart';
import 'package:assistant_me/model/template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final templateRepositoryProvider = Provider((ref) => TemplateRepository(ref));

class TemplateRepository {
  TemplateRepository(this._ref);

  final Ref _ref;

  Future<List<Template>> findAll() async {
    return await _ref.read(templateDaoProvider).findAll();
  }

  Future<void> saveAll(List<Template> templates) async {
    for (var t in templates) {
      await _ref.read(templateDaoProvider).create(t.title, t.contents);
    }
  }

  Future<Template> create({required String title, required String contents}) async {
    return await _ref.read(templateDaoProvider).create(title, contents);
  }

  Future<void> update(Template template) async {
    await _ref.read(templateDaoProvider).update(template);
  }

  Future<void> delete(int id) async {
    await _ref.read(templateDaoProvider).delete(id);
  }
}
