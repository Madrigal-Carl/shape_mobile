import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shape_mobile/services/auth_service.dart';
import 'package:shape_mobile/services/loading_modal.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final modalKey = GlobalKey<LoadingModalState>();

    // Show the modal immediately
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          LoadingModal(key: modalKey, initialMessage: "Logging in..."),
    );

    try {
      final success = await _authService
          .loginStudent(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
            onProgress: (msg) => modalKey.currentState?.updateMessage(msg),
          )
          .timeout(const Duration(seconds: 60), onTimeout: () => false);

      Navigator.pop(context); // Close modal

      if (success) {
        if (mounted) {
          toastification.showSuccess(
            context: context,
            title: 'Logged in Successfully!',
            autoCloseDuration: const Duration(seconds: 5),
            padding: const EdgeInsets.all(10),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        toastification.showError(
          context: context,
          title: 'Connection timed out. Please check your internet.',
          autoCloseDuration: const Duration(seconds: 5),
          padding: const EdgeInsets.all(10),
        );
      }
    } on ApiException catch (e) {
      Navigator.pop(context); // Close modal
      toastification.showError(
        context: context,
        title: e.message == "connection_timeout"
            ? 'Connection timed out. Please check your internet.'
            : e.message,
        autoCloseDuration: const Duration(seconds: 5),
        padding: const EdgeInsets.all(10),
      );
    } catch (e) {
      Navigator.pop(context); // Close modal
      toastification.showError(
        context: context,
        title: e.toString(),
        autoCloseDuration: const Duration(seconds: 5),
        padding: const EdgeInsets.all(10),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/flutter/images/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.20),
            Image.asset(
              'assets/flutter/images/shape_logo.png',
              width: MediaQuery.of(context).size.width * 0.5,
              fit: BoxFit.cover,
            ),
            Text(
              'Speech Hearing Autism Personal Education',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor: const Color(0xFFEFF7F8),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 24,
                ),
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.black54),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor: const Color(0xFFEFF7F8),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 24,
                ),
              ),
            ),
            GFButton(
              onPressed: _isLoading ? null : _handleLogin,
              color: Colors.blue, // or your theme color
              shape: GFButtonShape.pills,
              fullWidthButton: true,
              size: GFSize.LARGE,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
