import 'package:flutter/material.dart';

import '/models/exam.dart';
import '/widgets/exam_card.dart';

class ExamList extends StatelessWidget {
  final List<Exam> exams;
  final Function deleteExamHandler;

  const ExamList({
    super.key,
    required this.exams,
    required this.deleteExamHandler,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: exams.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No exams planned in near future',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return ExamCard(
                  exam: exams[index],
                  deleteExamHandler: deleteExamHandler,
                );
              },
              itemCount: exams.length,
            ),
    );
  }
}
