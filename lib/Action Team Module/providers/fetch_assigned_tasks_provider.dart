import 'package:flutter/material.dart';

import '../../services/ReportServices.dart';
import '../../models/assign_task.dart';

class AssignedTaskProvider with ChangeNotifier {
  List<AssignTask> _tasks = [];
  List<AssignTask> get tasks => _tasks;
  bool isLoading = false;
  String? _error;
  String? get error => _error;

  Future<void> fetchAssignedTasks(BuildContext context) async {
    try {
      _error = null;
      isLoading = true;
      _tasks = await ReportServices(context).fetchAssignedReports();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
