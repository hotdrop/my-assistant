import 'package:assistant_me/data/local/dao/id_dao.dart';
import 'package:assistant_me/data/local/entities/template_entity.dart';
import 'package:assistant_me/model/app_exception.dart';
import 'package:assistant_me/model/template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final templateDaoProvider = Provider((ref) => TemplateDao(ref));

class TemplateDao {
  const TemplateDao(this._ref);

  final Ref _ref;

  Future<List<Template>> findAll() async {
    final box = await Hive.openBox<TemplateEntity>(TemplateEntity.boxName);
    if (box.isEmpty) {
      return [];
    }
    return box.values.map((e) => Template(id: e.id, title: e.title, contents: e.contents)).toList();
  }

  Future<Template> create(String title, String contents) async {
    final newId = await _ref.read(idDaoProvider).generate();
    final entity = TemplateEntity(id: newId, title: title, contents: contents);
    final box = await Hive.openBox<TemplateEntity>(TemplateEntity.boxName);
    await box.put(newId, entity);
    return Template(id: newId, title: entity.title, contents: entity.contents);
  }

  Future<void> update(Template newTemplate) async {
    final box = await Hive.openBox<TemplateEntity>(TemplateEntity.boxName);
    final currentTemplate = box.get(newTemplate.id);
    if (currentTemplate == null) {
      throw AppException(message: '更新対象のID${newTemplate.id}がありません。プログラムを見直してください。');
    }
    final t = currentTemplate.copyWith(title: newTemplate.title, contents: newTemplate.contents);
    await box.put(t.id, t);
  }

  Future<void> delete(int id) async {
    final box = await Hive.openBox<TemplateEntity>(TemplateEntity.boxName);
    await box.delete(id);
  }
}
