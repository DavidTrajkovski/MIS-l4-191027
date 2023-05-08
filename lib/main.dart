import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/authentication_provider.dart';
import '/screens/authentication_screen.dart';
import '/screens/exams_screen.dart';
import '/providers/exams_provider.dart';
import '/models/exam.dart';
import '/screens/calendar_screen.dart';

void main() {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      defaultColor: Colors.amber,
      ledColor: Colors.white,
      playSound: true,
      onlyAlertOnce: true,
    ),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AwesomeNotifications().actionStream.listen((receivedAction) {
      if (receivedAction.channelKey == 'basic_channel') {
         Navigator.of(context).pushReplacementNamed('/calendar');
      }
    });

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
