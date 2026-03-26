import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/task.dart';

class StorageService {
  static const String _usersKey = 'users_json';
  static const String _tasksKey = 'tasks_json';
  static const String _sessionKey = 'current_user_id';

  // --- Users ---

  Future<List<User>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? contents = prefs.getString(_usersKey);
      
      if (contents == null || contents.isEmpty) return [];

      List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print("Error reading users: $e");
      return [];
    }
  }

  Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = users.map((u) => u.toJson()).toList();
    await prefs.setString(_usersKey, jsonEncode(jsonList));
  }

  Future<bool> registerUser(User newUser) async {
    try {
      List<User> users = await getUsers();
      if (users.any((u) => u.username == newUser.username || u.email == newUser.email)) {
        return false; // User exists
      }
      users.add(newUser);
      await saveUsers(users);
      return true;
    } catch (e) {
      print("Error writing user: $e");
      rethrow;
    }
  }

  Future<User?> loginUser(String username, String password) async {
    List<User> users = await getUsers();
    try {
      User user = users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, user.id);
      
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<bool> resetPassword(String username, String passkey, String newPassword) async {
    List<User> users = await getUsers();
    int index = users.indexWhere((u) => u.username == username && u.passkey == passkey);
    if (index != -1) {
      User user = users[index];
      users[index] = User(
        id: user.id,
        name: user.name,
        email: user.email,
        username: user.username,
        password: newPassword,
        passkey: user.passkey,
      );
      await saveUsers(users);
      return true;
    }
    return false;
  }

  // --- Tasks ---

  Future<List<TaskItem>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? contents = prefs.getString(_tasksKey);
      
      if (contents == null || contents.isEmpty) return [];

      List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => TaskItem.fromJson(json)).toList();
    } catch (e) {
      print("Error reading tasks: $e");
      return [];
    }
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(jsonList));
  }

  Future<void> addTask(TaskItem task) async {
    List<TaskItem> tasks = await getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(TaskItem updatedTask) async {
    List<TaskItem> tasks = await getTasks();
    int index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    List<TaskItem> tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await saveTasks(tasks);
  }

  // --- Current User Session ---
  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_sessionKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      print("Error deleting session: $e");
    }
  }
}
