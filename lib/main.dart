import 'package:assistant_me/resource/strings.dart';
import 'package:assistant_me/ui/top_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', '')],
      title: Strings.appName,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Note Sans JP',
        primaryColor: Colors.green,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const TopPage(),
    );
  }
}
