import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'task_screen.dart';
import 'landing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<TaskItem> _allTasks = [];
  String _currentUserId = 'guest';
  String _selectedCategory = 'All';
  bool _isLoading = true;

  final List<String> _filters = ['All', 'Assignments', 'Subjects', 'Tasks/Other'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    String? uid = await _storage.getCurrentUserId();
    if (uid != null && uid.isNotEmpty) {
      _currentUserId = uid;
    }
    
    List<TaskItem> tasks = await _storage.getTasks();
    // Filter tasks by current user
    _allTasks = tasks.where((t) => t.userId == _currentUserId).toList();
    
    // Sort logic: incomplete first, then by priority High>Medium>Low, then soonest deadline
    _allTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      int pA = _priorityWeight(a.priority);
      int pB = _priorityWeight(b.priority);
      if (pA != pB) return pB.compareTo(pA);
      return a.deadline.compareTo(b.deadline);
    });

    setState(() => _isLoading = false);
  }

  int _priorityWeight(String p) {
    if (p == 'High') return 3;
    if (p == 'Medium') return 2;
    return 1;
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return AppTheme.priorityHigh;
      case 'Medium': return AppTheme.priorityMedium;
      case 'Low': return AppTheme.priorityLow;
      default: return Colors.grey;
    }
  }

  Future<void> _toggleComplete(TaskItem task) async {
    task.isCompleted = !task.isCompleted;
    await _storage.updateTask(task);
    _loadData();
  }

  Future<void> _deleteTask(TaskItem task) async {
    await _storage.deleteTask(task.id);
    _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  void _logout() async {
    await _storage.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TaskItem> filteredTasks = _selectedCategory == 'All' 
        ? _allTasks 
        : _allTasks.where((t) => t.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('My Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textLight),
            onPressed: _logout,
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: _filters.map((f) {
                    bool isSelected = _selectedCategory == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = f);
                        },
                        selectedColor: AppTheme.primaryBlue,
                        backgroundColor: AppTheme.cardColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textLight,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // List of tasks
              Expanded(
                child: filteredTasks.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: filteredTasks.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return _buildTaskCard(task);
                        },
                      ),
              )
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? reqReload = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskScreen(userId: _currentUserId)),
          );
          if (reqReload == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in, size: 80, color: AppTheme.cardColor),
          const SizedBox(height: 16),
          Text(
            "No tasks found here.",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteTask(task),
      child: GestureDetector(
        onTap: () async {
          bool? reqReload = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskScreen(userId: _currentUserId, existingTask: task),
            ),
          );
          if (reqReload == true) _loadData();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: task.isCompleted ? AppTheme.cardColor.withOpacity(0.5) : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.isCompleted ? Colors.transparent : AppTheme.primaryBlue.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => _toggleComplete(task),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 4, right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted ? AppTheme.primaryBlue : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted ? AppTheme.primaryBlue : AppTheme.textMuted,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted 
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: task.isCompleted ? AppTheme.textMuted : AppTheme.textLight,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Priority Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priority).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.priority,
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.category,
                            style: const TextStyle(
                              color: AppTheme.accentPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Deadline
                        Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, HH:mm').format(task.deadline),
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
