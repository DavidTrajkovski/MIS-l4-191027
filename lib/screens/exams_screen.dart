import 'package:flutter/material.dart';
import 'package:mis_lab4_191027/providers/exams_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../widgets/app_drawer.dart';
import '/widgets/exam_list.dart';
import '/widgets/new_exam.dart';
import '/models/exam.dart';

class ExamsScreen extends StatefulWidget {
  static const String routeName = '/exams';

  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  var _isLoading = false;

  @override
  void initState() {
    _isLoading = true;
    Future.delayed(Duration.zero).then((_) {
      Provider.of<Exams>(context, listen: false).fetchAndSetExams().then((_) {
        setState(() => _isLoading = false);
      });
    });
    super.initState();
  }

  Future<void> _addNewExam(
      String subjectName, DateTime date, TimeOfDay timeStart, TimeOfDay timeEnd) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Exams>(context, listen: false)
          .addProduct(subjectName, date, timeStart, timeEnd);
    } catch (error) {
      rethrow;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showAddExam(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (bCtx) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: NewExam(
            addNewExamHandler: _addNewExam,
          ),
        );
      },
    );
  }

  Future<void> _deleteExam(String id) async {
    try {
      Provider.of<Exams>(context, listen: false).deleteProduct(id);
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    var exams = Provider.of<Exams>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Planner'),
        actions: [
          IconButton(
              onPressed: () => _showAddExam(context),
              icon: Icon(
                Icons.add,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30)),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExamList(
                    exams: exams.items,
                    deleteExamHandler: _deleteExam,
                  ),
                ],
              ),
            ),
    );
  }
}
