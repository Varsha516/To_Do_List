import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final StorageService _storage = StorageService();
  final _usernameController = TextEditingController();
  final _passkeyController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  bool _isLoading = false;

  void _resetPassword() async {
    setState(() => _isLoading = true);
    
    bool success = await _storage.resetPassword(
      _usernameController.text.trim(),
      _passkeyController.text.trim(),
      _newPasswordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or passkey')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.key, size: 80, color: AppTheme.primaryBlue),
            const SizedBox(height: 32),
            Text(
              "Recover Account",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Enter your username and the recovery passkey you set during signup.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              style: const TextStyle(color: AppTheme.textLight),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passkeyController,
              decoration: const InputDecoration(labelText: 'Recovery Passkey'),
              obscureText: true,
              style: const TextStyle(color: AppTheme.textLight),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
              style: const TextStyle(color: AppTheme.textLight),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Set New Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
