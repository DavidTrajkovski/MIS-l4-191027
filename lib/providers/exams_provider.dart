import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/exam.dart';

class Exams with ChangeNotifier {
  List<Exam> _exams = [];

  final String authToken;
  final String userId;

  Exams(this.authToken, this.userId, this._exams);

  Exam findById(String id) {
    return _exams.firstWhere((prod) => prod.id == id);
  }

  List<Exam> get items {
    return [..._exams];
  }

  Future<void> fetchAndSetExams() async {
    List<Exam> loadedExams = [];
    final url = Uri.parse(
        'https://examplanner-38b10-default-rtdb.firebaseio.com/exams.json?auth=$authToken');
    try {
      final response = await http.get(url);
      if (json.decode(response.body) != null) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        extractedData.forEach((examId, examData) {
          loadedExams.add(Exam(
            id: examId,
            subjectName: examData['subjectName'],
            date: DateTime.parse(examData['date']),
            timeStart: TimeOfDay(
                hour: int.parse(examData['timeStart'].split(":")[0]),
                minute: int.parse(examData['timeStart'].split(":")[1])),
            timeEnd: TimeOfDay(
                hour: int.parse(examData['timeEnd'].split(":")[0]),
                minute: int.parse(examData['timeEnd'].split(":")[1])),
          ));
        });
      }
      _exams = loadedExams;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(String subjectName, DateTime date,
      TimeOfDay timeStart, TimeOfDay timeEnd) async {
    final url = Uri.parse(
        'https://examplanner-38b10-default-rtdb.firebaseio.com/exams.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'subjectName': subjectName,
          'date': date.toIso8601String(),
          'timeStart': timeStart.toString().substring(10, 15),
          'timeEnd': timeEnd.toString().substring(10, 15),
        }),
      );
      final newProduct = Exam(
        subjectName: subjectName,
        date: date,
        timeStart: timeStart,
        timeEnd: timeEnd,
        id: json.decode(response.body)['name'],
      );
      _exams.add(newProduct);
      notifyListeners();
      triggerNotificationExamAdded(newProduct);
    } catch (error) {
      rethrow;
    }
  }

  void triggerNotificationExamAdded(Exam exam) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: exam.hashCode,
            channelKey: 'basic_channel',
            title: 'New Exam Alert',
            body:
                '${exam.subjectName} exam on ${DateFormat.yMMMd().format(exam.date)} '));
  }

  void triggerNotificationExamDeleted(Exam exam) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: exam.hashCode,
            channelKey: 'basic_channel',
            title: 'Exam Deleted Alert',
            body: '${exam.subjectName} exam no longer on your calendar '));
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://examplanner-38b10-default-rtdb.firebaseio.com/exams/$id.json?auth=$authToken');
    final existingExamIndex = _exams.indexWhere((exam) => exam.id == id);
    Exam? existingExam = _exams[existingExamIndex];
    _exams.removeAt(existingExamIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _exams.insert(existingExamIndex, existingExam);
      notifyListeners();
      throw const HttpException('Could not delete product.');
    }
    triggerNotificationExamDeleted(existingExam);
    existingExam = null;
  }
}
