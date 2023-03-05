import 'package:flutter/material.dart';

class Exam {
  final String id;
  final String subjectName;
  final DateTime date;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;

  Exam({
    required this.id,
    required this.subjectName,
    required this.date,
    required this.timeStart,
    required this.timeEnd
  });

}
