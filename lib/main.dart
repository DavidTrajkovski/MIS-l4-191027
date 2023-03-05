import 'package:flutter/material.dart';
import 'package:mis_lab4_191027/models/exam.dart';
import 'package:mis_lab4_191027/screens/calendar_screen.dart';
import 'package:provider/provider.dart';

import '/providers/authentication_provider.dart';
import '/screens/authentication_screen.dart';
import '/screens/exams_screen.dart';
import 'providers/exams_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Exams>(
            create: (context) => Exams(' ', ' ', []),
            update: (ctx, auth, previousExams) => Exams(auth.token, auth.userId,
                (previousExams == null ? [] : previousExams.items))),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: '191027 Exam Planner',
          theme: ThemeData(
            secondaryHeaderColor: Colors.amber,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blueGrey,
              accentColor: Colors.black,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blueGrey,
              iconTheme: IconThemeData(
                color: Colors.amber,
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.amber,
              ),
            ),
          ),
          home: auth.isAuthenticated
              ? const ExamsScreen()
              : const AuthenticationScreen(),
          routes: {
            AuthenticationScreen.routeName: (ctx) =>
                const AuthenticationScreen(),
            ExamsScreen.routeName: (ctx) => const ExamsScreen(),
            CalendarScreen.routeName: (ctx) => const CalendarScreen()
          },
        ),
      ),
    );
  }
}
