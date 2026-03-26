import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class TaskScreen extends StatefulWidget {
  final TaskItem? existingTask;
  final String userId;

  const TaskScreen({Key? key, this.existingTask, required this.userId}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final StorageService _storage = StorageService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  String _selectedCategory = 'Tasks/Other';
  String _selectedPriority = 'Medium';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  final List<String> _categories = ['Assignments', 'Subjects', 'Tasks/Other'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _descController.text = widget.existingTask!.description;
      _selectedCategory = widget.existingTask!.category;
      _selectedPriority = widget.existingTask!.priority;
      _selectedDate = widget.existingTask!.deadline;
    }
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute
          );
        });
      }
    }
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final task = TaskItem(
      id: widget.existingTask?.id ?? Uuid().v4(),        
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      deadline: _selectedDate,
      createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
      isCompleted: widget.existingTask?.isCompleted ?? false,
      userId: widget.userId,
    );

    if (widget.existingTask == null) {
      await _storage.addTask(task);
    } else {
      await _storage.updateTask(task);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingTask != null;
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
              style: const TextStyle(color: AppTheme.textLight, fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textLight),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: AppTheme.cardColor,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(color: AppTheme.textLight)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    dropdownColor: AppTheme.cardColor,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: _priorities.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(p, style: const TextStyle(color: AppTheme.textLight)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPriority = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.accentPurple),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deadline', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text(
                          DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDate),
                          style: const TextStyle(color: AppTheme.textLight, fontSize: 16),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(isEditing ? 'Update Task' : 'Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
