import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../auth/auth_service.dart';
import '../services/task_service.dart';
import 'task_tile.dart';
import 'create_task_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }
  
  Future<void> _loadTasks() async {
    final taskService = Provider.of<TaskService>(context, listen: false);
    try {
      await taskService.init();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _refreshTasks() async {
    final taskService = Provider.of<TaskService>(context, listen: false);
    await taskService.fetchTasks();
  }
  
  void _showAddTaskModal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTaskScreen()),
    ).then((_) => _refreshTasks());
  }
  
  Widget _buildCompletedTasks() {
    final taskService = Provider.of<TaskService>(context);
    final completedTasks = taskService.completedTasks
        .where((task) => 
            _searchQuery.isEmpty || 
            task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
        
    if (completedTasks.isEmpty) {
      return Center(
        child: Text(
          'No completed tasks yet',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: completedTasks.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final task = completedTasks[index];
        return TaskTile(
          task: task,
          onToggleStatus: (value) {
            taskService.updateTaskStatus(task.id, value);
          },
          onDelete: () {
            taskService.deleteTask(task.id);
          },
        );
      },
    );
  }
  
  Widget _buildOngoingTasks() {
    final taskService = Provider.of<TaskService>(context);
    final ongoingTasks = taskService.ongoingTasks
        .where((task) => 
            _searchQuery.isEmpty || 
            task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
        
    if (ongoingTasks.isEmpty) {
      return Center(
        child: Text(
          'No ongoing tasks yet',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: ongoingTasks.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final task = ongoingTasks[index];
        return TaskTile(
          task: task,
          onToggleStatus: (value) {
            taskService.updateTaskStatus(task.id, value);
          },
          onDelete: () {
            taskService.deleteTask(task.id);
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: _currentIndex == 0 
        ? AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome Back!'),
                FutureBuilder<Map<String, dynamic>?>(
                  future: authService.getUserProfile(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    }
                    
                    final profile = snapshot.data;
                    return Text(
                      profile?['full_name'] ?? 'User',
                      style: Theme.of(context).textTheme.headlineLarge,
                    );
                  },
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  // Navigate to settings
                },
              ),
            ],
          )
        : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.accentYellow))
          : Column(
              children: [
                if (_currentIndex == 0) Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tasks',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.textGrey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: AppTheme.accentYellow,
                        ),
                        onPressed: () {
                          // Show filter options
                        },
                      ),
                    ),
                  ),
                ),
                
                if (_currentIndex == 0) ... [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Completed Tasks',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to see all completed tasks
                          },
                          child: Text('See all'),
                        ),
                      ],
                    ),
                  ),
                  
                  Consumer<TaskService>(
                    builder: (context, taskService, _) {
                      final completedTasks = taskService.completedTasks
                          .where((task) => 
                              _searchQuery.isEmpty || 
                              task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                          .toList();
                      
                      return Container(
                        height: 120,
                        child: completedTasks.isEmpty
                            ? Center(
                                child: Text(
                                  'No completed tasks yet',
                                  style: TextStyle(color: AppTheme.textGrey),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: completedTasks.length,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemBuilder: (context, index) {
                                  final task = completedTasks[index];
                                  return Container(
                                    width: 200,
                                    margin: EdgeInsets.only(right: 16),
                                    child: TaskTile(
                                      task: task,
                                      onToggleStatus: (value) {
                                        taskService.updateTaskStatus(task.id, value);
                                      },
                                      onDelete: () {
                                        taskService.deleteTask(task.id);
                                      },
                                    ),
                                  );
                                },
                              ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 24),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ongoing Projects',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to see all ongoing tasks
                          },
                          child: Text('See all'),
                        ),
                      ],
                    ),
                  ),
                ],
                
                Expanded(
                  child: _currentIndex == 0
                      ? Consumer<TaskService>(
                          builder: (context, taskService, _) {
                            final ongoingTasks = taskService.ongoingTasks
                                .where((task) => 
                                    _searchQuery.isEmpty || 
                                    task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                                .toList();
                            
                            return ongoingTasks.isEmpty
                                ? Center(
                                    child: Text(
                                      'No ongoing tasks yet',
                                      style: TextStyle(color: AppTheme.textGrey),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: ongoingTasks.length,
                                    padding: EdgeInsets.all(16),
                                    itemBuilder: (context, index) {
                                      final task = ongoingTasks[index];
                                      return TaskTile(
                                        task: task,
                                        onToggleStatus: (value) {
                                          taskService.updateTaskStatus(task.id, value);
                                        },
                                        onDelete: () {
                                          taskService.deleteTask(task.id);
                                        },
                                      );
                                    },
                                  );
                          },
                        )
                      : _currentIndex == 1
                          ? _buildOngoingTasks()
                          : _buildCompletedTasks(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskModal,
        backgroundColor: AppTheme.accentYellow,
        child: Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppTheme.darkBackground,
        selectedItemColor: AppTheme.accentYellow,
        unselectedItemColor: AppTheme.textGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Container(width: 48), // Placeholder for FAB
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}