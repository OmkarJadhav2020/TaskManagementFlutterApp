import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../services/task_service.dart';

class CreateTaskScreen extends StatefulWidget {
  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<String> _teamMembers = [];
  
  bool _isLoading = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentYellow,
              onPrimary: Colors.black,
              surface: AppTheme.darkSurface,
              onSurface: AppTheme.textLight,
            ),
            dialogBackgroundColor: AppTheme.darkBackground,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      // After picking the date, show time picker
      _selectTime();
    }
  }
  
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentYellow,
              onPrimary: Colors.black,
              surface: AppTheme.darkSurface,
              onSurface: AppTheme.textLight,
            ),
            dialogBackgroundColor: AppTheme.darkBackground,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  DateTime? _combineDateAndTime() {
    if (_selectedDate == null) return null;
    
    final now = DateTime.now();
    final time = _selectedTime ?? TimeOfDay.now();
    
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      time.hour,
      time.minute,
    );
  }
  
  void _showTeamMemberDialog() {
    final TextEditingController memberController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: Text(
          'Add Team Member',
          style: TextStyle(color: AppTheme.textLight),
        ),
        content: TextField(
          controller: memberController,
          decoration: InputDecoration(
            hintText: 'Team member name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (memberController.text.isNotEmpty) {
                setState(() {
                  _teamMembers.add(memberController.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final taskService = Provider.of<TaskService>(context, listen: false);
    final dueDate = _combineDateAndTime();
    
    final success = await taskService.addTask(
      _titleController.text.trim(),
      _detailsController.text.trim(),
      dueDate,
      _teamMembers.isEmpty ? null : _teamMembers,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create task. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Task'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task title
              Text(
                'Task Title',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 24),
              
              // Task details
              Text(
                'Task Details',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(
                  hintText: 'Enter task details',
                ),
                maxLines: 5,
              ),
              
              SizedBox(height: 24),
              
              // Team members
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add team members',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                    onPressed: _showTeamMemberDialog,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _teamMembers.map((member) {
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
                          width: 24,
                          height: 24,
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
                                fontSize: 12,
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
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _teamMembers.remove(member);
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: AppTheme.textGrey,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              
              SizedBox(height: 24),
              
              // Due date
              Text(
                'Time & Date',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  // Time picker
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentYellow,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              _selectedTime == null
                                  ? 'Select time'
                                  : _selectedTime!.format(context),
                              style: TextStyle(
                                color: _selectedTime == null
                                    ? AppTheme.textGrey
                                    : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Date picker
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentYellow,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? AppTheme.textGrey
                                    : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 32),
              
              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTask,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black54,
                          ),
                        )
                      : Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}