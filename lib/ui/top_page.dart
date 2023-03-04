import 'package:assistant_me/service/authentication.dart';
import 'package:assistant_me/ui/account/account_page.dart';
import 'package:assistant_me/ui/history/history_page.dart';
import 'package:assistant_me/ui/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

class TopPage extends ConsumerWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(authenticationProvider).when(
          data: (_) => const _ViewOnBody(),
          error: (error, stackTrace) => const _ViewOnLoading(),
          loading: () => const _ViewOnLoading(),
        );
  }
}

class _ViewOnLoading extends StatelessWidget {
  const _ViewOnLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('認証')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('画面が切り替わるまで少しお待ちください。'),
        ),
      ),
    );
  }
}

class _ViewOnBody extends StatefulWidget {
  const _ViewOnBody();

  @override
  State<_ViewOnBody> createState() => _ViewOnBodyState();
}

class _ViewOnBodyState extends State<_ViewOnBody> {
  int _currentIdx = 0;

  @override
  Widget build(BuildContext context) {
    final isMobileSize = MediaQuery.of(context).size.width < 640;
    if (isMobileSize) {
      return _ViewMobileMode(
        destinations: destinations,
        body: _menuView(_currentIdx),
        currentIdx: _currentIdx,
        onTap: (index) => setState(() => _currentIdx = index),
      );
    } else {
      return _ViewWebMode(
        destinations: destinations,
        body: _menuView(_currentIdx),
        currentIdx: _currentIdx,
        onSelected: (index) => setState(() => _currentIdx = index),
      );
    }
  }

  List<Destination> get destinations => <Destination>[
        Destination('ホーム', LineIcon(LineIcons.home)),
        Destination('履歴', LineIcon(LineIcons.history)),
        Destination('アカウント', LineIcon(LineIcons.userCircle)),
      ];

  Widget _menuView(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const HistoryPage();
      case 2:
        return const AccountPage();
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
    required this.onSelected,
  });

  final List<Destination> destinations;
  final Widget body;
  final int currentIdx;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: destinations
                .map((e) => NavigationRailDestination(
                      icon: e.icon,
                      label: Text(e.title),
                    ))
                .toList(),
            selectedIndex: currentIdx,
            onDestinationSelected: onSelected,
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
