import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:safify/models/assign_task.dart';
import 'package:safify/repositories/assign_tasks_repository.dart';
import 'package:safify/services/snack_bar_service.dart';
import 'package:safify/utils/network_util.dart';

class AssignedTasksProvider with ChangeNotifier {
  final _assignTasksRepository = AssignTasksRepository();
  List<AssignTask>? _tasks;
  List<AssignTask>? get tasks => _tasks;
  bool isLoading = true;
  String? _error;
  String? get error => _error;

  Future<void> fetchAssignedTasks(BuildContext context) async {
    try {
      _error = null;
      isLoading = true;
      _tasks = await _assignTasksRepository.fetchAssignTasksFromDb();
      isLoading = false;

      notifyListeners();
      debugPrint("Fetched assigned tasks from local database.");

      final ping = await ping_google();
      if (ping) {
        SnackBarService.showCustomSnackBar(
            context: context,
            leading: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight * 0.5,
                  width: constraints.maxHeight * 0.5,
                  child: const CircularProgressIndicator(
                    strokeWidth: 1,
                    color: Colors.black,
                  ),
                );
              },
            ),
            content: const Text("Syncing local data with server..."));
        await _assignTasksRepository.syncDb();
        _tasks = await _assignTasksRepository.fetchAssignTasksFromDb();
        isLoading = false;
        notifyListeners();
        debugPrint("Fetched assigned tasks from API.");
      } else {
        SnackBarService.showCustomSnackBar(
            context: context,
            leading: Icon(Icons.perm_scan_wifi_outlined),
            content: const Text("Could not connect to server"));
        debugPrint(
            "No internet connection, could not fetch assigned tasks from API.");
      }
    } catch (e) {
      _error = e.toString();
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
