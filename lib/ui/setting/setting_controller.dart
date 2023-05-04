// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:assistant_me/model/template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setting_controller.g.dart';

@riverpod
class SettingController extends _$SettingController {
  @override
  void build() {}

  Future<void> importTemplate(String rawData) async {
    try {
      await ref.read(templateNotifierProvider.notifier).fromJson(rawData);
      ref.read(templateMessageStateProvider.notifier).state = 'インポートが完了しました。';
    } catch (e) {
      ref.read(templateMessageStateProvider.notifier).state = '$e';
    }
  }

  void exportTemplate() {
    final jsonStr = ref.read(templateNotifierProvider.notifier).toJson();
    final blob = html.Blob([jsonStr], 'application/json');
    final anchorElement = html.AnchorElement(href: html.Url.createObjectUrlFromBlob(blob).toString())..download = 'export_template.json';
    anchorElement.click();
  }

  Future<PackageInfo> getAppVersion() async {
    return await PackageInfo.fromPlatform();
  }
}

final templateCanImportProvider = Provider<bool>((ref) {
  return ref.watch(templateNotifierProvider).isEmpty;
});

final templateCanExportProvider = Provider<bool>((ref) {
  return ref.watch(templateNotifierProvider).isNotEmpty;
});

final templateMessageStateProvider = StateProvider<String?>((_) => null);
