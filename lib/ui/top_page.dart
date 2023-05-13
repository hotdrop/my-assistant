import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/ui/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:assistant_me/ui/template/template_page.dart';
import 'package:assistant_me/ui/setting/settings_page.dart';
import 'package:assistant_me/ui/history/history_page.dart';
import 'package:assistant_me/ui/home/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class TopPage extends ConsumerWidget {
  const TopPage({super.key});

  static const int homeIndex = 0;
  static const int historyIndex = 1;
  static const int templateIndex = 2;
  static const int settingIndex = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIdx = ref.watch(selectPageIndexProvider);
    final isMobileSize = MediaQuery.of(context).size.width < 640;
    if (isMobileSize) {
      return _ViewMobileMode(
        destinations: destinations,
        body: _menuView(currentIdx),
        currentIdx: currentIdx,
        onTap: (index) => ref.read(selectPageIndexProvider.notifier).state = index,
      );
    } else {
      return _ViewWebMode(
        destinations: destinations,
        body: _menuView(currentIdx),
        currentIdx: currentIdx,
        onTap: (index) => ref.read(selectPageIndexProvider.notifier).state = index,
      );
    }
  }

  List<Destination> get destinations => <Destination>[
        Destination('ホーム', LineIcon(LineIcons.home)),
        Destination('履歴', LineIcon(LineIcons.history)),
        Destination('テンプレ', LineIcon(LineIcons.alternateFileAlt)),
        Destination('設定', LineIcon(LineIcons.cog)),
      ];

  Widget _menuView(int index) {
    switch (index) {
      case homeIndex:
        return const HomePage();
      case historyIndex:
        return const HistoryPage();
      case templateIndex:
        return const TemplatePage();
      case settingIndex:
        return const SettingsPage();
      default:
        throw Exception(['不正なIndexです index=$index']);
    }
  }
}

class _ViewWebMode extends StatelessWidget {
  const _ViewWebMode({
    required this.destinations,
    required this.body,
    required this.currentIdx,
    required this.onTap,
  });

  final List<Destination> destinations;
  final Widget body;
  final int currentIdx;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: destinations
                .map((e) => NavigationRailDestination(
                      icon: e.icon,
                      label: AppText.normal(e.title),
                    ))
                .toList(),
            selectedIndex: currentIdx,
            onDestinationSelected: onTap,
            labelType: NavigationRailLabelType.all,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _ViewMobileMode extends StatelessWidget {
  const _ViewMobileMode({
    required this.destinations,
    required this.body,
    required this.currentIdx,
    required this.onTap,
  });

  final List<Destination> destinations;
  final Widget body;
  final int currentIdx;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIdx,
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: destinations
            .map((e) => BottomNavigationBarItem(
                  icon: e.icon,
                  label: e.title,
                ))
            .toList(),
        onTap: onTap,
      ),
    );
  }
}

class Destination {
  const Destination(this.title, this.icon);

  final String title;
  final Widget icon;
}
