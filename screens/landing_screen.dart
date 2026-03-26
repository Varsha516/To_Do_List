import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.darkBackground,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            // Logo / Icon
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: AppTheme.accentPurple,
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome to TaskFlow",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 10),
            Text(
              "Manage your time beautifully.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
            const Spacer(flex: 1),
            // Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(color: AppTheme.accentPurple, fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
