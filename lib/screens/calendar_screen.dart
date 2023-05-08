import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../providers/exams_provider.dart';
import '../models/exam.dart';
import '../widgets/app_drawer.dart';

class CalendarScreen extends StatefulWidget {
  static const String routeName = '/calendar';

  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Appointment> _getAppointmentsFromExams(List<Exam> exams) {
    return exams
        .map((e) => Appointment(
            startTime: DateTime(e.date.year, e.date.month, e.date.day,
                e.timeStart.hour, e.timeStart.minute),
            endTime: DateTime(e.date.year, e.date.month, e.date.day,
                e.timeEnd.hour, e.timeEnd.minute),
            subject: e.subjectName,
            color: const Color.fromARGB(255, 211, 166, 33)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var exams = Provider.of<Exams>(context);
    final List<Appointment> appointments =
        _getAppointmentsFromExams(exams.items);
    for (var a in appointments) {
      a.toString();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('My Calendar'),
        ),
        drawer: AppDrawer(),
        body: SfCalendar(
            //view: CalendarView.week,
            allowedViews: const <CalendarView>[
              CalendarView.day,
              CalendarView.week,
              CalendarView.workWeek,
              CalendarView.month,
              CalendarView.timelineDay,
              CalendarView.timelineWeek,
              CalendarView.timelineWorkWeek,
              CalendarView.timelineMonth,
              CalendarView.schedule,
            ],
            showDatePickerButton: true,
            allowViewNavigation: true,
            dataSource: TermDataSource([
              ...appointments,
            ])));
  }
}

class TermDataSource extends CalendarDataSource {
  TermDataSource(List<Appointment> source) {
    appointments = source;
  }
}
