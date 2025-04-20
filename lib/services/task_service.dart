import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard/task_model.dart';

class TaskService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Task> _tasks = [];
  
  List<Task> get tasks => _tasks;
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get ongoingTasks => _tasks.where((task) => !task.isCompleted).toList();
  
  // Initialize and fetch tasks
  Future<void> init() async {
    await fetchTasks();
  }
  
  // Fetch all tasks for the current user
  Future<void> fetchTasks() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      _tasks = response.map((data) => Task.fromJson(data)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }
  
  // Add a new task
  Future<bool> addTask(String title, String? details, DateTime? dueDate, List<String>? teamMembers) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;
      
      final newTask = {
        'title': title,
        'details': details,
        'due_date': dueDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'progress': 0.0,
        'is_completed': false,
        'user_id': userId,
        'team_members': teamMembers,
      };
      
      final response = await _supabase.from('tasks').insert(newTask).select();
      
      if (response.isNotEmpty) {
        final addedTask = Task.fromJson(response.first);
        _tasks.insert(0, addedTask);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding task: $e');
      return false;
    }
  }
  
  // Update task status
  Future<bool> updateTaskStatus(String taskId, bool isCompleted) async {
    try {
      await _supabase
          .from('tasks')
          .update({'is_completed': isCompleted})
          .eq('id', taskId);
      
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating task status: $e');
      return false;
    }
  }
  
  // Update task progress
  Future<bool> updateTaskProgress(String taskId, double progress) async {
    try {
      await _supabase
          .from('tasks')
          .update({'progress': progress})
          .eq('id', taskId);
      
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(progress: progress);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating task progress: $e');
      return false;
    }
  }
  
  // Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
      
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }
  
  // Add subtask to a task
  Future<bool> addSubTask(String taskId, String title) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) return false;
      
      final task = _tasks[taskIndex];
      
      final newSubTask = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'is_completed': false,
      };
      
      List<Map<String, dynamic>> subTasksJson = [];
      if (task.subTasks != null) {
        subTasksJson = task.subTasks!.map((st) => st.toJson()).toList();
      }
      subTasksJson.add(newSubTask);
      
      await _supabase
          .from('tasks')
          .update({'sub_tasks': subTasksJson})
          .eq('id', taskId);
      
      final updatedSubTasks = [
        if (task.subTasks != null) ...task.subTasks!,
        SubTask.fromJson(newSubTask),
      ];
      
      _tasks[taskIndex] = task.copyWith(subTasks: updatedSubTasks);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding subtask: $e');
      return false;
    }
  }
  
  // Update subtask status
  Future<bool> updateSubTaskStatus(String taskId, String subTaskId, bool isCompleted) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) return false;
      
      final task = _tasks[taskIndex];
      if (task.subTasks == null) return false;
      
      final updatedSubTasks = task.subTasks!.map((subTask) {
        if (subTask.id == subTaskId) {
          return subTask.copyWith(isCompleted: isCompleted);
        }
        return subTask;
      }).toList();
      
      final subTasksJson = updatedSubTasks.map((st) => st.toJson()).toList();
      
      await _supabase
          .from('tasks')
          .update({'sub_tasks': subTasksJson})
          .eq('id', taskId);
      
      _tasks[taskIndex] = task.copyWith(subTasks: updatedSubTasks);
      
      // Update task progress based on subtasks completion
      final completedCount = updatedSubTasks.where((st) => st.isCompleted).length;
      final progress = updatedSubTasks.isEmpty ? 0.0 : completedCount / updatedSubTasks.length;
      
      await updateTaskProgress(taskId, progress);
      return true;
    } catch (e) {
      print('Error updating subtask status: $e');
      return false;
    }
  }
}