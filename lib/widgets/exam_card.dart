import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mis_lab4_191027/providers/exams_provider.dart';
import 'package:provider/provider.dart';

import '/models/exam.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final Function deleteExamHandler;

  const ExamCard({
    super.key,
    required this.exam,
    required this.deleteExamHandler,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ListTile(
        title: Text(
          exam.subjectName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${DateFormat.yMMMd().format(exam.date)} '
            '${exam.timeStart.format(context)} - '
            '${exam.timeEnd.format(context)}' ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          color: Theme.of(context).colorScheme.error,
          //onPressed: () => deleteExamHandler(exam.id),
          onPressed: () async {
            try {
              await Provider.of<Exams>(context, listen: false)
                  .deleteProduct(exam.id);
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Deleting failed!',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
