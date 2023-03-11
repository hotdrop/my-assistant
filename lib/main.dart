import 'package:assistant_me/firebase_options.dart';
import 'package:assistant_me/model/app_settings.dart';
import 'package:assistant_me/ui/top_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', '')],
      title: 'マイアシスト',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Note Sans JP',
        primaryColor: Colors.purple,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: ref.watch(appInitFutureProvider).when(
            data: (_) => const TopPage(),
            error: (error, s) => _ViewOnLoading(errorMessage: '$error'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイアシスト'),
      ),
      body: Center(
        child: LoadingAnimationWidget.threeArchedCircle(color: Theme.of(context).primaryColor, size: 32),
      ),
    );
  }
}
