import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../services/task_service.dart';
import 'task_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailsScreen({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TextEditingController _subtaskController = TextEditingController();
  bool _isLoading = true;
  late Task _task;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskDetails() async {
    setState(() {
      _isLoading = true;
    });

    final taskService = Provider.of<TaskService>(context, listen: false);
    await taskService.fetchTasks();
    
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildSubtaskTile(SubTask subtask) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              taskService.updateSubTaskStatus(
                widget.taskId,
                subtask.id,
                !subtask.isCompleted,
              );
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subtask.isCompleted
                    ? Colors.green
                    : AppTheme.darkBackground,
                border: Border.all(
                  color: subtask.isCompleted
                      ? Colors.green
                      : AppTheme.accentYellow,
                  width: 2,
                ),
              ),
              child: subtask.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                color: AppTheme.textLight,
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSubtaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: Text(
          'Add Subtask',
          style: TextStyle(color: AppTheme.textLight),
        ),
        content: TextField(
          controller: _subtaskController,
          decoration: InputDecoration(
            hintText: 'Subtask title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _subtaskController.clear();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_subtaskController.text.isNotEmpty) {
                final taskService = Provider.of<TaskService>(context, listen: false);
                taskService.addSubTask(
                  widget.taskId,
                  _subtaskController.text.trim(),
                );
                Navigator.pop(context);
                _subtaskController.clear();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit task screen
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              final taskService = Provider.of<TaskService>(context, listen: false);
              taskService.deleteTask(widget.taskId).then((_) {
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.accentYellow))
          : Consumer<TaskService>(
              builder: (context, taskService, _) {
                final taskIndex = taskService.tasks.indexWhere(
                  (task) => task.id == widget.taskId,
                );
                
                if (taskIndex == -1) {
                  return Center(
                    child: Text(
                      'Task not found',
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                  );
                }
                
                _task = taskService.tasks[taskIndex];
                
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task title
                      Text(
                        _task.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Task status and due date
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _task.isCompleted
                                  ? Colors.green
                                  : AppTheme.accentYellow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _task.isCompleted ? 'Completed' : 'In Progress',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          
                          if (_task.dueDate != null) ...[
                            SizedBox(width: 16),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AppTheme.textGrey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Due on: ${DateFormat('d MMMM').format(_task.dueDate!)}',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Task details
                      if (_task.details != null && _task.details!.isNotEmpty) ...[
                        Text(
                          'Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          _task.details!,
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                      
                      // Team members
                      if (_task.teamMembers != null && _task.teamMembers!.isNotEmpty) ...[
                        Text(
                          'Team Members',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _task.teamMembers!.map((member) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.darkSurface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.accentYellow.withOpacity(0.7),
                                    ),
                                    child: Center(
                                      child: Text(
                                        member.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    member,
                                    style: TextStyle(
                                      color: AppTheme.textLight,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 24),
                      ],
                      
                      // Progress tracking
                      Row(
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${(_task.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: AppTheme.accentYellow,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.darkSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 8,
                            width: MediaQuery.of(context).size.width *
                                _task.progress *
                                0.9, // 90% of the screen width
                            decoration: BoxDecoration(
                              color: _task.isCompleted
                                  ? Colors.green
                                  : AppTheme.accentYellow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 32),
                      
                      // Subtasks
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtasks',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: AppTheme.accentYellow,
                            ),
                            onPressed: _showAddSubtaskDialog,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      if (_task.subTasks == null || _task.subTasks!.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No subtasks yet',
                              style: TextStyle(color: AppTheme.textGrey),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: _task.subTasks!
                              .map((subtask) => _buildSubtaskTile(subtask))
                              .toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}