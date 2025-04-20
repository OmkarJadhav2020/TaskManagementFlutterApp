import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import 'task_model.dart';
import 'task_details_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(bool) onToggleStatus;
  final VoidCallback onDelete;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onToggleStatus,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailsScreen(taskId: task.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: task.isCompleted ? AppTheme.accentYellow.withOpacity(0.1) : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onDelete(),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.close, size: 16, color: AppTheme.textGrey),
                        ),
                      ),
                    ],
                  ),
                  
                  if (task.details != null && task.details!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        task.details!,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  if (task.teamMembers != null && task.teamMembers!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Text(
                            'Team members',
                            style: TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          for (int i = 0; i < task.teamMembers!.length; i++)
                            if (i < 3)
                              Container(
                                width: 30,
                                height: 30,
                                margin: EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accentYellow.withOpacity(0.7),
                                ),
                                child: Center(
                                  child: Text(
                                    task.teamMembers![i].substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          if ((task.teamMembers?.length ?? 0) > 3)
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.darkBackground,
                              ),
                              child: Center(
                                child: Text(
                                  '+${task.teamMembers!.length - 3}',
                                  style: TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  if (task.dueDate != null)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppTheme.textGrey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Due on: ${DateFormat('d MMMM').format(task.dueDate!)}',
                            style: TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            SizedBox(height: 8),
            
            // Progress bar
            Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackground,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                ),
                Container(
                  height: 4,
                  width: MediaQuery.of(context).size.width * task.progress,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? Colors.green
                        : AppTheme.accentYellow,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            
            // Task completion checkbox
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => onToggleStatus(!task.isCompleted),
                child: Container(
                  margin: EdgeInsets.only(top: 8, right: 16, bottom: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? Colors.green
                        : AppTheme.darkBackground,
                    border: Border.all(
                      color: task.isCompleted
                          ? Colors.green
                          : AppTheme.accentYellow,
                      width: 2,
                    ),
                  ),
                  padding: EdgeInsets.all(2),
                  child: task.isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : SizedBox(width: 16, height: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}