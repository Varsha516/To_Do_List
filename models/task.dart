class TaskItem {
  final String id;
  final String title;
  final String description;
  final String category; // e.g., 'Assignments', 'Subjects', 'Tasks/Other'
  final String priority; // 'Low', 'Medium', 'High'
  final DateTime deadline;
  final DateTime createdAt;
  bool isCompleted;
  final String userId;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.deadline,
    required this.createdAt,
    this.isCompleted = false,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      deadline: DateTime.parse(json['deadline']),
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      userId: json['userId'],
    );
  }
}
